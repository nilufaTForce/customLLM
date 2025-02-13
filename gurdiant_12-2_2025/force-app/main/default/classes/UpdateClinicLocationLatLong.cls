public without sharing class UpdateClinicLocationLatLong implements Queueable, Database.AllowsCallouts {
    
    private List<String> addresses;

    // Constructor
    public UpdateClinicLocationLatLong(List<String> addresses) {
        this.addresses = addresses;
    }

    public void execute(QueueableContext context) {
       
        List<Clinic_Location__c> locationsToUpdate = new List<Clinic_Location__c>();

      
        for (String address : addresses) {
           
            Map<String, Double> latLng = DistanceService.getLatLong(address);

            if (!latLng.isEmpty()) {
                
                Clinic_Location__c location = [SELECT Id, Address__c FROM Clinic_Location__c WHERE Address_Text__c = :address LIMIT 1];

                location.Geolocation__Latitude__s = latLng.get('lat');
                location.Geolocation__Longitude__s = latLng.get('lng');
                
             
                locationsToUpdate.add(location);
            }
        }

      
        if (!locationsToUpdate.isEmpty()) {
            update locationsToUpdate;
        }
    }
}