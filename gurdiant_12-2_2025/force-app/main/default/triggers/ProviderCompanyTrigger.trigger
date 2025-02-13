trigger ProviderCompanyTrigger on Provider_Company__c (before insert, after insert, before update, after update, before delete, after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        
        /*Provider_Company__c pc = Trigger.new[0];
        // System.debug('Trigger.new[0]-->' + Trigger.new[0]);
        
        String addressInString = pc.Address__Street__s + ' ' + pc.Address__City__s + ', ' +  pc.Address__StateCode__s + ' ' + pc.Address__PostalCode__s + ' ' + pc.Address__CountryCode__s;
        // System.debug('Address-->' + addressInString);
        
        Map<String, Double> originCoords = DistanceService.getLatLong(addressInString);
        
        Decimal latitude = originCoords.get('lat');
        Decimal longitude = originCoords.get('lng');
        
        
        Location loc = Location.newInstance(latitude, longitude);
        
        // pc.Geolocation__c = loc;
        pc.Geolocation__Latitude__s = loc.getLatitude();
        pc.Geolocation__Longitude__s = loc.getLongitude();
        
        System.debug('PC-->' + pc);
        pc.addError('Stop!');
        */
    }
}