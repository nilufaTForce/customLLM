public without sharing class DistanceService {
    //DistanceService.findClosestAddress();


    public static Map<String, Double> getLatLong(String address) {
        Google_Map_API__mdt apiConfig = [SELECT API_Key__c, Geocoding_URL__c , Distance_Matrix_Url__c FROM Google_Map_API__mdt LIMIT 1];
        // Build the geocoding URL
        String apiKey = apiConfig.API_Key__c;
        String geocodingUrl=apiConfig.Geocoding_URL__c+ EncodingUtil.urlEncode(address, 'UTF-8') + '&key=' + apiKey;
        //do not delete
        // String apiKey = [SELECT API_Key__c FROM Google_Map_API__mdt LIMIT 1].API_Key__c;
        // String geocodingUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + EncodingUtil.urlEncode(address, 'UTF-8') + '&key=' + apiKey;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(geocodingUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);
        Map<String, Double> latLng = new Map<String, Double>();

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (result.containsKey('results')) {
                List<Object> results = (List<Object>) result.get('results');
                if (!results.isEmpty()) {
                    Map<String, Object> location = (Map<String, Object>) ((Map<String, Object>) ((Map<String, Object>) results[0]).get('geometry')).get('location');
                    latLng.put('lat', (Double) location.get('lat'));
                    latLng.put('lng', (Double) location.get('lng'));
                }
            }
        }
        System.debug('The closest address is: ' + latLng + '  and the address you passed in: ' + address + '\n\n');
        return latLng;
    }


    @AuraEnabled
    public static Id getClosestClinicLocationId(String originAddress, String categoryId) {
        Google_Map_API__mdt apiConfig = [SELECT API_Key__c, Geocoding_URL__c , Distance_Matrix_Url__c FROM Google_Map_API__mdt LIMIT 1];
        // Build the geocoding URL
        String apiKey = apiConfig.API_Key__c;
        // String apiKey = [SELECT API_Key__c FROM Google_Map_API__mdt LIMIT 1].API_Key__c;
        Map<String, Double> originCoords = getLatLong(originAddress);
        
        List<Category_Location_Map__c> categoryLocationMaps = [
            SELECT Id, Group_Location__c 
            FROM Category_Location_Map__c 
            WHERE Care_Category__c = :categoryId
        ];

        // Extract Group_Location__c IDs into a Set
        Set<Id> locationIds = new Set<Id>();
        for (Category_Location_Map__c mapRecord : categoryLocationMaps) {
            if (mapRecord.Group_Location__c != null) {
                locationIds.add(mapRecord.Group_Location__c);
            }
        }

        // Query Clinic_Location__c using extracted IDs
        List<Clinic_Location__c> companyList = new List<Clinic_Location__c>();
        if (!locationIds.isEmpty()) {
            companyList = [
                SELECT Id, Provider_Company__c, Name, Address__c, 
                    Geolocation__latitude__s, Geolocation__longitude__s, Geolocation__c 
                FROM Clinic_Location__c 
                WHERE Id IN :locationIds
            ];
        }

        // Debugging output
        System.debug('Retrieved Company List: ' + companyList);
        // street + ' ' + city + ', ' +  state + ' ' + postalCode + ' ' + country;

        if(companyList.isEmpty()){
            return null;
        }

        List<String> destinationAddresses = new List<String>();
        List<String> destinationLatLngs = new List<String>();

        Address tempAddress = null;
        String address = null;

        for (Clinic_Location__c company : companyList) {
            tempAddress = company.Address__c;
            address = tempAddress.street + ' ' + tempAddress.city + ', ' +  tempAddress.state + ' ' + tempAddress.postalCode + ' ' + tempAddress.country;
            destinationAddresses.add(address);
            destinationLatLngs.add(company.Geolocation__latitude__s + ',' + company.Geolocation__longitude__s);
        }


        String destinations = String.join(destinationLatLngs, '|');
        String origin = originCoords.get('lat') + ',' + originCoords.get('lng');
     
     
      
        String distanceMatrixUrl = apiConfig.Distance_Matrix_Url__c+ origin + '&destinations=' + destinations + '&key=' + apiKey;

        //do not delete
        //String distanceMatrixUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=' + origin + '&destinations=' + destinations + '&key=' + apiKey;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(distanceMatrixUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        Integer closestIndex = -1;
        system.debug('i m miss ');
        system.debug(response.getBody()+response.getStatusCode() );
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
         system.debug('i m result \n'+JSON.serializePretty(result));

            List<Object> rows = (List<Object>) result.get('rows');
            if (!rows.isEmpty()) {
                List<Object> elements = (List<Object>) ((Map<String, Object>) rows[0]).get('elements');
                
                Integer minDistance = 2147483645;
                Integer distValue = 0;
                
                for (Integer i = 0; i < elements.size(); i++) {
                    Map<String, Object> element = (Map<String, Object>) elements[i];
                    if (element.containsKey('distance') && element.get('distance') != null) {
                        Map<String, Object> distance = (Map<String, Object>) element.get('distance');
                        if (distance.containsKey('value') && distance.get('value') != null) {
                            distValue = (Integer) distance.get('value');
                            if (distValue < minDistance) {
                                minDistance = distValue;
                                closestIndex = i;
                            }
                        }
                    }
                }
                System.debug('4');
                
                if (closestIndex != -1) {
                    // List<AppointmentWrapper> wrapper = getAvailableAppointments(companyList[closestIndex].Id);
                    System.debug('5');
                    System.debug(companyList[closestIndex].Id);
                    return companyList[closestIndex].Id;
                }
            }
        }

        return null;
    }
    

    @AuraEnabled
    public static Map<String, String> getClinicLocationNameById(String clinicLocationId) {
        if (String.isEmpty(clinicLocationId)) {
            return null;
        }
    
        // Fetch both Name and Address_Text__c fields
        Clinic_Location__c clinicLocation = [SELECT Name, Address_Text__c FROM Clinic_Location__c WHERE Id = :clinicLocationId LIMIT 1];
    
        // Return a map with both Name and Address_Text__c
        if (clinicLocation != null) {
            Map<String, String> result = new Map<String, String>();
            result.put('Name', clinicLocation.Name);
            result.put('Address', clinicLocation.Address_Text__c);
            return result;
        }
        return null;
    }
    

    public class AppointmentWrapper{
        public Date currentDate;
        public List<Time> appointments;
        // public List<Time> appointmentTimes;
    }

}