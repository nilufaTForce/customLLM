public with sharing class DistanceCalculationHandler {

    //DistanceCalculationHandler.findClosestAddress();

    public static void findClosestAddress() {
        String originAddress = '1600 Amphitheatre Parkway, Mountain View, CA';
        List<String> destinationAddresses = new List<String>{
            'Times Square, New York, NY',
            'Hollywood, Los Angeles, CA',
            'Eiffel Tower, Paris'
        };

        String closestAddress = findClosestAddress(originAddress, destinationAddresses);

        if (closestAddress != null) {
            System.debug('The closest address is: ' + closestAddress);
        } else {
            System.debug('No closest address found.');
        }
    }


    public static Map<String, Double> getLatLong(String address) {
        // String apiKey = [SELECT API_Key__c FROM Google_Map_API__mdt LIMIT 1].API_Key__c;
        Google_Map_API__mdt apiConfig = [SELECT API_Key__c, Geocoding_URL__c , Distance_Matrix_Url__c FROM Google_Map_API__mdt LIMIT 1];

        // Build the geocoding URL
        String apiKey = apiConfig.API_Key__c;
        String geocodingUrl = apiConfig.Geocoding_URL__c +  EncodingUtil.urlEncode(address, 'UTF-8') + '&key=' + apiKey;
        //Do not delete
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
        return latLng;
    }


    public static String findClosestAddress(String originAddress, List<String> destinationAddresses) {
        // String apiKey = [SELECT API_Key__c FROM Google_Map_API__mdt LIMIT 1].API_Key__c;
        Google_Map_API__mdt apiConfig = [SELECT API_Key__c, Geocoding_URL__c , Distance_Matrix_Url__c FROM Google_Map_API__mdt LIMIT 1];

        // Build the geocoding URL
        String apiKey = apiConfig.API_Key__c;
     
        
        Map<String, Double> originCoords = getLatLong(originAddress);

        List<String> destinationLatLngs = new List<String>();
        for (String destinationAddress : destinationAddresses) {
            Map<String, Double> destCoords = getLatLong(destinationAddress);
            destinationLatLngs.add(destCoords.get('lat') + ',' + destCoords.get('lng'));
        }

        String destinations = String.join(destinationLatLngs, '|');
        String origin = originCoords.get('lat') + ',' + originCoords.get('lng');
        String distanceMatrixUrl = apiConfig.Distance_Matrix_Url__c+ origin + '&destinations=' + destinations + '&key=' + apiKey;
        //Do not delete
        // String distanceMatrixUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=' + origin + '&destinations=' + destinations + '&key=' + apiKey;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(distanceMatrixUrl);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> rows = (List<Object>) result.get('rows');
            if (!rows.isEmpty()) {
                List<Object> elements = (List<Object>) ((Map<String, Object>) rows[0]).get('elements');

                Integer minDistance = 999999;
                Integer closestIndex = -1;

                Integer distValue = 0;
                for (Integer i = 0; i < elements.size(); i++) {
                    Map<String, Object> element = (Map<String, Object>) elements[i];
                    if (element.containsKey('distance') && element.get('distance') != null) {
                        Map<String, Object> distance = (Map<String, Object>) element.get('distance');
                        if (distance.containsKey('value') && distance.get('value') != null) {
                            distValue = (Integer) distance.get('value'); // Distance in meters

                            if (distValue < minDistance) {
                                minDistance = distValue;
                                closestIndex = i;
                            }
                        }
                    }
                }

                if (closestIndex != -1) {
                    return destinationAddresses[closestIndex];
                }
            }
        }

        return null;
    }


    /*public static String getDistanceBetweenAddresses(String originAddress, String destinationAddress) {
        String encodedOrigin = EncodingUtil.urlEncode(originAddress, 'UTF-8');
        String encodedDestination = EncodingUtil.urlEncode(destinationAddress, 'UTF-8');
        
        String api_key = [SELECT API_Key__c FROM Google_Map_API__mdt LIMIT 1].API_Key__c;
        String apiUrl = 'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=' + encodedOrigin + '&destinations=' + encodedDestination + '&key=' + api_key;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {

            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            if (results.containsKey('rows') && ((List<Object>) results.get('rows')).size() > 0) {
                Map<String, Object> row = (Map<String, Object>) ((List<Object>) results.get('rows'))[0];
                Map<String, Object> element = (Map<String, Object>) ((List<Object>) row.get('elements'))[0];
                
                if (element.containsKey('distance')) {
                    Map<String, Object> distance = (Map<String, Object>) element.get('distance');
                    return (String) distance.get('text');
                }
            }
        } else {
            System.debug('Error from Google API: ' + response.getBody());
            throw new CalloutException('Failed to get distance from Google Maps API.');
        }
        
        return null;
    }*/

}