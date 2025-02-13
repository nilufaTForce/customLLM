trigger ClinicLocationAfterInsert on Clinic_Location__c (after insert, after update) {
    List<String> addresses = new List<String>();
    
  
    for (Clinic_Location__c clinicLocation : Trigger.new) {
        if (clinicLocation.Address_Text__c != null) {
            addresses.add(clinicLocation.Address_Text__c);
        }
    }

 
    if (!addresses.isEmpty()) {
        System.enqueueJob(new UpdateClinicLocationLatLong(addresses));
    }
}