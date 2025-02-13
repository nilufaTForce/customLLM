public without sharing class CustomCalendarController{



    @AuraEnabled(cacheable = true)
    public static List<Appointment__c> getAppointmentsByProvider(Id providerId) {
        if (String.isBlank(providerId)) {
            throw new IllegalArgumentException('Provider ID cannot be null or blank.');
        }

        try {
            // Query appointments linked to the provider
            List<Appointment__c> appointments = [
                SELECT Id, Name, Appointed_Date__c, Start_Time__c , Clinic_Location__c,Status__c,Clinic_Resource__c
                FROM Appointment__c
                WHERE  Clinic_Resource__c = :providerId
             
            ];
            return appointments;
        } catch (Exception e) {
            System.debug('Error fetching appointments: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while retrieving appointments.');
        }
    }

    
    @AuraEnabled(cacheable = true)
    public static Clinic_Resource__c getProviderDetail(String providerId) {
        if (String.isBlank(providerId)) {
            throw new IllegalArgumentException('Provider ID cannot be null or blank.');
        }

        try {
            // Query appointments linked to the provider
            Clinic_Resource__c provider  = [
                SELECT Id, Name,Resource_Type__c,Clinic_Location__r.Provider_Company__c,Clinic_Location__c,Resource_Type__r.Resource_Category__c,Appointment_Type__c,Time_Zone__c,Email__c
                FROM Clinic_Resource__c
                WHERE  Id = :providerId
                LIMIT 1
             
            ];
            return provider;
        } catch (Exception e) {
            System.debug('Error fetching appointments: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while retrieving appointments.');
        }
    }

    @AuraEnabled(cacheable = true)
    public static String getPatientAppointments(String rand){
        List<Appointment__c> patientList = [SELECT Name, Appointed_Date__c, Start_Time__c, End_Time__c,Formatted_Date__c, Telehealth__c,Location_Text__c,
        Format_Date_For_Email__c, Provider_Company__c, Duration__c, Provider_Company__r.Address__c, Patient__r.Phone,Room_Type__c,
         Patient__r.HealthCloudGA__Gender__c, From_Outlook__c,Patient__r.HealthCloudGA__Age__c, Patient__r.Name, Clinic_Resource__r.Name, Clinic_Resource__r.Resource_Type__r.Name, Provider_Company__r.Name,Clinic_Location__c,Clinic_Location__r.Name,
         Clinic_Location__r.Address_Text__c,Clinic_Location__r.Provider_Company__c,Clinic_Location__r.Provider_Company__r.Name,Patient_Account__c,Patient_Account__r.Name
                                            , Appointment_Type__c, Room_Level__c, Room_Label__C, Appointment_Type__r.Name,  Resource_Type__c,   Resource_Type__r.Name, Resource_Category__c,    Resource_Category__r.Name, RecordTypeId, RecordType.DeveloperName,Description__c
                                         
                                            FROM Appointment__c
                                            WHERE Status__c != 'Cancelled' ORDER BY Name ASC] ;
        
        
        // System.debug(patientList);
        if (patientList.isEmpty()){
            return '';
        }
        
        return JSON.serialize(patientList);
    }


    @AuraEnabled(cacheable = true)
    public static List<Resource_Category__c>  getCareCatOfTheClinic(String locationId) {

system.debug(locationId);
        List<Category_Location_Map__c> CategoriLocationMapList = [SELECT Care_Category__c FROM Category_Location_Map__c WHERE Group_Location__r.Id = :locationId];
        
         List<Resource_Category__c> careCatList = [SELECT Id,Name FROM Resource_Category__c];
       
       
         Map<Id, Resource_Category__c> careCatMap = new Map<Id, Resource_Category__c>();
         for (Resource_Category__c careCat : careCatList) {
             careCatMap.put(careCat.Id, careCat);
         }
         system.debug(CategoriLocationMapList);
         system.debug(careCatList);


         List<Resource_Category__c> matchedCareCategories = new List<Resource_Category__c>();

         for (Category_Location_Map__c catLoc : CategoriLocationMapList) {
            if (catLoc.Care_Category__c != null && careCatMap.containsKey(catLoc.Care_Category__c)) {
                matchedCareCategories.add(careCatMap.get(catLoc.Care_Category__c));
            }
        }
        system.debug('matched ' + matchedCareCategories);
    return matchedCareCategories;  
    }

    @AuraEnabled(cacheable = true)
    public static List<Clinic_Location__c>  getAllLocationOfSameCareCat(String careCatId) {

//system.debug(locationId);
        List<Category_Location_Map__c> CategoriLocationMapList = [SELECT Care_Category__c,Group_Location__c FROM Category_Location_Map__c WHERE Care_Category__r.Id = :careCatId];
        
         List<Clinic_Location__c> grpLocationList = [SELECT Id,Name,Provider_Company__c FROM Clinic_Location__c];
       
       
         Map<Id,Clinic_Location__c > grpMap = new Map<Id, Clinic_Location__c>();
         for (Clinic_Location__c groLoc : grpLocationList) {
            grpMap.put(groLoc.Id, groLoc);
         }
        // system.debug(CategoriLocationMapList);
        // system.debug(careCatList);


         List<Clinic_Location__c> matchedgrpLocation = new List<Clinic_Location__c>();

         for (Category_Location_Map__c catLoc : CategoriLocationMapList) {
            if (catLoc.Group_Location__c != null && grpMap.containsKey(catLoc.Group_Location__c)) {
                matchedgrpLocation.add(grpMap.get(catLoc.Group_Location__c));
            }
        }
       system.debug('matched ' + matchedgrpLocation);
       return matchedgrpLocation;  
    }






    @AuraEnabled(cacheable = true)
    public static String getPatientRecordTypeID() {
        return (String)Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Patient').getRecordTypeId();
    }
    
    @AuraEnabled(cacheable = true)
    public static String getRecordTypeNameById(String recordTypeId) {
        // Query the RecordType object to get the Name of the RecordType
        List<RecordType> recordTypeList = [SELECT Name FROM RecordType WHERE Id = :recordTypeId LIMIT 1];
        
        // Check if we found a record with the provided RecordTypeId
        if (recordTypeList.isEmpty()) {
            return 'Record Type not found';
        }
        
        // Return the Name of the RecordType
        return recordTypeList[0].Name;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Provider_Company__c> getAllCompanyProviders(){
        List<Provider_Company__c> providerCompanyList = [SELECT Name, Address__c FROM Provider_Company__c  ORDER BY Name ASC ];
        
        if (providerCompanyList.isEmpty()) {
            return new List<Provider_Company__c>();
        }
        
        return providerCompanyList;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Clinic_Location__c> getClinicLocations(){
        List<Clinic_Location__c> providerCompanyList = [SELECT Name,Provider_Company__c FROM Clinic_Location__c  WHERE Status__c != 'Close' ORDER BY Name ASC];
        
        if (providerCompanyList.isEmpty()) {
            return new List<Clinic_Location__c>();
        }
        return providerCompanyList;
    }
    
    // @AuraEnabled(cacheable=true)
    // public static String getCurrentUserTimeZone() {
        //           // Get the current user's timezone
        //           TimeZone tz = UserInfo.getTimeZone();
        //           // Get the offset in minutes and convert to hours
        //           Integer offsetMinutes = tz.getOffset(System.now());
        //           Integer offsetHours = offsetMinutes / 3600000; // Convert milliseconds to hours
        //           String gmtOffset =  (offsetHours >= 0 ? '+' : '') + offsetHours;
        
        //           return gmtOffset;
        
    // }
    
    // @AuraEnabled(cacheable=true)
    // public static Map<String, String> getCurrentUserTimeZone() { // commented by proma while writing test class
        
        //     Map<String, String> timeZoneInfo = new Map<String, String>();
        //     // TimeZone tz = UserInfo.getTimeZone();
        //     // Integer offsetMinutes = tz.getOffset(System.now());
        //     // Integer offsetHours = offsetMinutes / 3600000; // Convert milliseconds to hours
        //     // String gmtOffset = (offsetHours >= 0 ? '+' : '') + offsetHours;
        
        //     // timeZoneInfo.put('timeZoneId', tz.getID()); // Get the time zone ID
        //     // timeZoneInfo.put('gmtOffset', gmtOffset);    // Store the GMT offset
        
        //     return timeZoneInfo;
    // }
    
    @AuraEnabled
    public static List<String>  getAvailableAppointmentSlots(String providerTypeID,String appDuration,String locationID, String careCategoryID, Date appointmentDate,String doc){
        if(providerTypeID == null){
            providerTypeID = '';
        }
        if(locationID== '' || appDuration == ''){    
             // when the group location or the duration is not selected it will show 12:00 am to 12:00 pm  in the starttime dropdown.
            return new List<String>{
                '00:00', '00:15', '00:30', '00:45',
                '01:00', '01:15', '01:30', '01:45',
                '02:00', '02:15', '02:30', '02:45',
                '03:00', '03:15', '03:30', '03:45',
                '04:00', '04:15', '04:30', '04:45',
                '05:00', '05:15', '05:30', '05:45',
                '06:00', '06:15', '06:30', '06:45',
                '07:00', '07:15', '07:30', '07:45',
                '08:00', '08:15', '08:30', '08:45',
                '09:00', '09:15', '09:30', '09:45',
                '10:00', '10:15', '10:30', '10:45',
                '11:00', '11:15', '11:30', '11:45',
                '12:00', '12:15', '12:30', '12:45',
                '13:00', '13:15', '13:30', '13:45',
                '14:00', '14:15', '14:30', '14:45',
                '15:00', '15:15', '15:30', '15:45',
                '16:00', '16:15', '16:30', '16:45',
                '17:00', '17:15', '17:30', '17:45',
                '18:00', '18:15', '18:30', '18:45',
                '19:00', '19:15', '19:30', '19:45',
                '20:00', '20:15', '20:30', '20:45',
                '21:00', '21:15', '21:30', '21:45',
                '22:00', '22:15', '22:30', '22:45',
                '23:00', '23:15', '23:30', '23:45'
            };
        }
        String  clinicId = locationID;
        String  careCategory = careCategoryID;
        String  appointedDate = appointmentDate.format();
        String providerType  = providerTypeID;
        String doctorID = doc;
        // the appDuration is in the form '45 mins', so to get the number part i splited it with the space which will store the 45
        String duration;
        if(appDuration != null) {
            duration = appDuration.split( ' ')[0];
        } else {
            duration = '15';
        }
        // if i've 45 duration it will return 3 , if 30 it will return 2 , i used it cause when i need when the duration is 45 i need to check 3 slots in a row , if i have 30 mins duration , i need to check 2 slots in a row , as the slots in dropdown are showing in 15 mins gap
        Integer durationInt = (Integer.valueOf(duration))/15;
        List<Clinic_Resource__c> listOfDoctors =  new List<Clinic_Resource__c>();
        
        if(providerType == '' ){  // when provider is not selected it wll fatch all doctors of all provider types , and will run the method in all of them
            listOfDoctors =  [SELECT Name,Id FROM Clinic_Resource__c WHERE  Clinic_Location__c = :clinicId AND Clinic_Location__r.Provider_Company__r.Resource_Category__c = :careCategory  ];
        }else{           // if the provider type is selected it will get the list of doctor only of the selected provider type
            //listOfDoctors =  [SELECT Name,Id FROM Clinic_Resource__c WHERE  Clinic_Location__c = :clinicId AND Clinic_Location__r.Provider_Company__r.Resource_Category__c = :careCategory AND Resource_Type__c =:providerType ];
            listOfDoctors = [SELECT Name,Id FROM Clinic_Resource__c WHERE  Clinic_Location__c = :clinicId AND Appointment_Type__r.Resource_Category__c = :careCategory AND Resource_Type__c =:providerType ];
        }
        System.debug('list of doctors: ' + listOfDoctors);
        // System.debug('Appointment Date: ' + appointedDate);
        // all appointments
        List<Appointment__c> listOfappointments =  [SELECT Name,Id,Start_Time__c,End_Time__c,Appointed_Date__c,Clinic_Location__c,Clinic_Location__r.Provider_Company__r.Resource_Category__c, Clinic_Resource__c FROM Appointment__c  WHERE  Clinic_Location__c = :clinicId  AND (Status__c = 'Accepted' OR Status__c = 'Requested')];
        // all availabilites
        List<Availability__c> allAvailability = [SELECT Id,Clinic_Resource__c, Day__c,Start_Shift__c,End_Shift__c FROM Availability__c];
        // doc id -> list of times with 15 mins gap , like 0903333-> 3:00,3:15,3:30
        map <String,List<String>> docAvaiableTimeList = availabilitiesOfDoctors(listOfDoctors,allAvailability,appointmentDate);
        // docId -> bookedStart-bookedEnd , 9897897-> 3:15-4:00
        Map<String,List<String>> slots = bookedSlotsOfDoctors(listOfDoctors,listOfappointments,appointedDate);
        System.debug('Booked Slots: ' + slots);
        // store the final dropdown value of startTime field
        List<String> availableTime = new  List<String>();
        
        for(Clinic_Resource__c doctor:listOfDoctors){
            if( doctorID =='' || (doctor.Id== doctorID)){
                // if he has availability record
                if(docAvaiableTimeList.get(doctor.Id) != null){
                    // doc available times , ex: 3:00,3:15,3:300, 3:45
                    List<String> availableTimes = docAvaiableTimeList.get(doctor.Id);
                    // for each available time for ex: 3:00  , decision if it is an available time or not
                    for (Integer i = 0; i < availableTimes.size(); i++){
                        Boolean flag = false;
                        Map<String,Boolean> mapp = new Map<String,Boolean>();
                        // this condition handles the case when the appointment start time is less than endTime of the doc availabilites but the appointment endTime exceeds the availabilites endTime
                        // for ex: when a doc has the availability of 2:00 - 4:00 , the user is able to set appointment at 3:30 or 3:45 for 45 mins duration , if the user set an appointment at 3:30 for 45 mins , the meeting will end at 4:15 which is greater than his availability time ,same goes for 3:45, which is not correct ,  so i have stop the user to create appointment which end time exceeds his availability end time.
                        if(i+(durationInt-1) >=availableTimes.size() ){
                            continue;
                        }
                        // puting 3 values in the mapp variabl if duration is 45 mins , if availableTimes[i]== 3:00 , i need to ensure 3:00,3:15,3:30 is free time(not in the booked list) of the doc
                        for(Integer j =0 ; j<durationInt ;j++){
                            // for case 05:0 to 05:00
                            if(availableTimes[i+j].split(':')[1]=='0'){
                                availableTimes[i+j] = availableTimes[i+j]+'0';
                            }
                            // mapp will always have 3 values for 45 , 2 for 30 and so on
                            mapp.put(availableTimes[i+j],true);
                        }
                        // to confirm that the availableTimes[i] is available , i need to check it with the booked slots , that it shouldn't exists in the bookedslots
                       // System.debug('Available Times: ' + availableTimes);
                       // System.debug('Slots mapp: ' + mapp);
                        for(String bookedSlots: slots.get(doctor.Id)){
                            String timeString = bookedSlots;
                            System.debug('Booked slots: ' + timeString);
                            List<String> timeParts = timeString.split(':');
                            List<String> timeParts2 = timeString.split('-');
                            
                            Integer hour = Integer.valueOf(timeParts[0]);
                            Integer minute = Integer.valueOf(timeParts[1].split('-')[0]);
                            
                            Integer hour1 = Integer.valueOf(timeParts2[1].split(':')[0]);
                            Integer minute1 = Integer.valueOf(timeParts2[1].split(':')[1]);
                            
                            Time timeValueStart = Time.newInstance(hour, minute, 0, 0);
                            Time timeValueEnd= Time.newInstance(hour1, minute1, 0, 0);
                            
                            Map<String,Boolean> mp = new  Map<String,Boolean>();
                            System.debug('Slots mapp in loop 1: ' + mapp);
                            // it is checking the bookedslot of the doc
                            for(Time k = timeValueStart ; k<timeValueEnd; k=k.addMinutes(15)){
                                String sp = String.valueOf(k);
                                System.debug('SP in time: ' + sp);
                                if(availableTimes[i].split(':')[1]=='0'){
                                    availableTimes[i] = availableTimes[i]+'0';

                                }// if the booked slot time exists in the map , means the avaiablities[i] is not available.
                                if(mapp.containsKey(sp.split(':')[0]+':'+sp.split(':')[1].split(':')[0])){
                                    mapp.put(sp.split(':')[0]+':'+sp.split(':')[1].split(':')[0],false);
                                }
                                
                            }
                            
                            
                        }
                        System.debug('Slots mapp after loop: ' + mapp);
                        System.debug('Available Times after loop: ' + availableTimes);
                        // if any value of the map is false , the avaiablities[i] is not available
                        for( String key: mapp.keySet()){
                            
                            if(mapp.get(key) == false){
                                flag = true;
                                break;
                                
                            }
                        }
                        
                        if(flag == false && (!availableTime.contains(availableTimes[i]))){
                            availableTime.add(availableTimes[i]);
                        }
                        System.debug('Actual Available Time: ' + availableTime);
                    }
                }
                
            }
            
        }
        // sorting for the order of the time
        availableTime.sort();
        // remove duplicate if any
        Set<String> availableTimeSet = new Set<String>(availableTime);
        // returning as list after sorting
        List<String> availableSlotsListReturn  = new List<String>(availableTimeSet);
        System.debug('Available Slots Return: ' + availableSlotsListReturn);
        return availableSlotsListReturn;
    }
    
    public static map <String,List<String>> availabilitiesOfDoctors(List<Clinic_Resource__c> listOfDoctors,List<Availability__c> allAvailability, Date appointmentDate){
        
        map <String,List<String>> docAvaiableTimeList = new map<String,List<String>>();
        
        for(Clinic_Resource__c doctor : listOfDoctors){
            String docId = doctor.Id; // docID
            
            Date dateValue =appointmentDate;
            DateTime dateTimeValue = DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day(), 0, 0, 0);
            // which day , ex. Monday
            String dayOfWeek = dateTimeValue.format('EEEE');
            
            List<String> docAv = new List<String>();
            for( Availability__c availab : allAvailability){
                
                if(availab.Clinic_Resource__c == docId && availab.Day__c.split('d')[0] == dayOfWeek.split('d')[0]){
                    
                    for(Time i = availab.Start_Shift__c ; i < availab.End_Shift__c; i = i.addMinutes(15) ){
                        String timeStr;
                        // if it is 1  to 9 , it will make 01 and 09 , 1:15 to  "01:15
                        if(i.hour()<10){
                            timeStr = '0'+i.hour() +':'+ i.minute() ;
                        }else{
                            timeStr = i.hour() +':'+ i.minute() ;   // else , 11:15
                        }
                        // system.debug(timeStr);
                        docAv.add(timeStr);
                    }
                    
                }
            }
            
            docAvaiableTimeList.put(doctor.Id,docAv);    // docId -> day(specifc selected date day) -> list of availability
        }
        return docAvaiableTimeList;
    }
    
    public static  Map<String,List<String>>  bookedSlotsOfDoctors(List<Clinic_Resource__c> listOfDoctors, List<Appointment__c> listOfappointments,String  appointedDate){
        Map<String,List<String>> slots = new Map<String,List<String>>();
        for(Clinic_Resource__c doctor:listOfDoctors){
            List<String> bookedSlots = new List<String>();
            for(Appointment__c app:listOfappointments){
                if(app.Clinic_Resource__c == doctor.Id && app.Appointed_Date__c.format() == appointedDate ){
                    string start =  String.valueOf(app.Start_Time__c);
                    String endtime = String.valueOf(app.End_Time__c);
                    String appointmentStart = start.split(':')[0]+':'+ start.split(':')[1].split(':')[0];
                    String appointmentEnd =   endtime.split(':')[0]+':'+ endtime.split(':')[1].split(':')[0];
                    // system.debug('kukkyk '+appointmentStart +'  '+appointmentEnd);
                    bookedSlots.add(appointmentStart+'-'+appointmentEnd);
                }
            }
            slots.put(doctor.Id,bookedSlots);
        }
        return slots;
    }
    
    
    
    @AuraEnabled
    public static List<Resource_Category__c> getAllCareCategories(String rand){
        return [SELECT Id, Name
                FROM Resource_Category__c
                ORDER BY Name ASC];
    }
    
    @AuraEnabled
    public static List<Provider_Company__c> getAllAffiliatedGrps(String rand){
        return [SELECT Id, Name, Resource_Category__c
                FROM Provider_Company__c
                ORDER BY Name ASC];
    }
    @AuraEnabled
    public static List<Availability__c> getAllAvailabilities(String rand){
        return [SELECT Id, Clinic_Resource__c, Start_Shift__c,End_Shift__c
                FROM Availability__c
                ORDER BY Name ASC];
    }
    
    
    @AuraEnabled
    public static List<Resource_Type__c> getAllProviderTypes(String rand){
        return [SELECT Id, Name, Appointment_Type__c, Clinic_Location__c, Resource_Category__c, Clinic_Location__r.Address_Text__c
                FROM  Resource_Type__c
                ORDER BY Name ASC];
    }
    @AuraEnabled
    public static List<Appointment_Type__c> getAllAppTypes(String rand){
        return [SELECT Id, Name, Duration__c, Description__c, Resource_Category__c
                FROM Appointment_Type__c
                ORDER BY Name ASC];
    }
    
    @AuraEnabled
    public static List<Clinic_Location__c> getAllGrpLocations(String rand){
        return [SELECT Id, Name, Provider_Company__c, Address_Text__c
                FROM Clinic_Location__c WHERE Status__c != 'Close'
                ORDER BY Name ASC];
    }
    
    @AuraEnabled
    public static List<Resource_Type__c> filterCareCat(String rand){
        return [SELECT Id, Name, Appointment_Type__c, Resource_Category__c, Clinic_Location__c
                FROM Resource_Type__c
                ORDER BY Name ASC];
    }
    
    @AuraEnabled
    public static List<Clinic_Resource__c> getAllProviders(String rand){
        return [SELECT Id, Name, Clinic_Location__r.Provider_Company__r.Resource_Category__c, Appointment_Type__c, Clinic_Location__r.Provider_Company__c, Clinic_Location__c, Resource_Type__c, Clinic_Location__r.Address_Text__c,Resource_Type__r.Resource_Category__c, Resource_Type__r.Clinic_Location__c
                FROM Clinic_Resource__c  WHERE Clinic_Location__r.Status__c != 'Close'
                ORDER BY Name ASC];
    }
    // @AuraEnabled
    // public static List<Clinic_Resource__c> filterCat(String rand, String afiiliatedId ){
        //     return [SELECT Id,
    //             FROM Resource_Category__c
    //             WHERE Id :=afiiliatedId];
    // }
    
    @AuraEnabled
    public static string createAppointment(String jsonData){
        Appointment__c appointment = new Appointment__c();
        Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        // System.debug('Appointment_Type__c-->' + dataMap.get('Appointment_Type__c'));
        
        String appType = (String) dataMap.get('event_Type');
        
        Id appointmentTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Appointment').getRecordTypeId();
        
        
        if (appType == 'Unavailable'){
            appointmentTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Unavailable').getRecordTypeId();
        }
        
        Date dateValue = Date.valueOf((String) dataMap.get('Appointed_Date__c'));
        //Datetime dateTimeValue = Datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day(), 0, 0, 0);
        
        Integer startHour = Integer.valueOf(((String) dataMap.get('Start_Time__c')).split(':')[0]);
        Integer startMins = Integer.valueOf(((String) dataMap.get('Start_Time__c')).split(':')[1]);
        
        Integer endHour = Integer.valueOf(((String) dataMap.get('End_Time__c')).split(':')[0]);
        Integer endMins = Integer.valueOf(((String) dataMap.get('End_Time__c')).split(':')[1]);
        
        Time startTime = Time.newInstance(startHour, startMins, 0, 0);
        Time endTime = Time.newInstance(endHour, endMins, 0, 0);
        Id patientId = (Id) dataMap.get('Patient_Account__c');
        
        List<Appointment__c> existingAppointments = [
                SELECT Id 
                FROM Appointment__c 
                WHERE Patient_Account__c = :patientId 
                AND Appointed_Date__c = :dateValue 
                AND Start_Time__c = :startTime
                AND End_Time__c = :endTime
                AND Status__c != 'Cancelled'
            ];
        
        if (!existingAppointments.isEmpty()) {
            throw new AuraHandledException('An appointment already exists for this patient at the same time and date.');
        }
        
        
        appointment.RecordTypeId = appointmentTypeId;
        appointment.Patient_Account__c = (Id) dataMap.get('Patient_Account__c');
        appointment.Provider_Company__c = (Id) dataMap.get('Provider_Company__c');
        appointment.Resource_Category__c = (Id) dataMap.get('Resource_Category__c');
        if(appType == 'Appointment' && (String) dataMap.get('Appointment_Type__c') != null){
            appointment.Appointment_Type__c = (Id) dataMap.get('Appointment_Type__c');
        }
        
        appointment.Appointed_Date__c = dateValue;
        appointment.Clinic_Location__c = (Id) dataMap.get('Clinic_Location__c');
        appointment.Description__c = (String) dataMap.get('Description__c');
        appointment.Telehealth__c = (String) dataMap.get('Telehealth__c');
        appointment.Clinic_Resource__c = (Id) dataMap.get('Clinic_Resource__c');
        appointment.Resource_Type__c = (Id) dataMap.get('Resource_Type__c');
        appointment.Room_Type__c = (String) dataMap.get('Room_Type__c');
        appointment.Start_Time__c = startTime;
        appointment.End_Time__c = endTime;
        appointment.Status__c = 'Accepted';
        
        if (appointment.Telehealth__c == 'Yes') {
            appointment.Provider_Company__c = null;
        }
        // System.debug('appointment-->' + JSON.serializePretty(appointment));
        
        String returnvalue = '';
        try{
            Database.insert(appointment, true);
            returnValue = 'Success';
        } catch (Exception e){
            returnValue = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        return returnValue;
    }
    // public static Integer formatToIntegerMinute(String minute){          //proma
        
        //     // if (!minute.split(' ').isEmpty()){
            //     //     return Integer.valueOf(minute.split(' ')[0]);
        //     // }
        //     // //system.debug('who' + Integer.valueOf(minute.substring(0, 2)));
        //     // return Integer.valueOf(minute.substring(0, 2));
        //     if (String.isEmpty(minute)) {
            //         throw new IllegalArgumentException('Minute string is empty.');
        //     }
        //     if (minute.contains('minutes') || minute.contains('minute')) {
            //         String[] parts = minute.split(' ');
            //         try {
                //             return Integer.valueOf(parts[0]);
            //         } catch (Exception e) {
                //             throw new IllegalArgumentException('Invalid duration format: ' + minute);
            //         }
        //     }
        //     try {
            //         return Integer.valueOf(minute);
        //     } catch (Exception e) {
            //         throw new IllegalArgumentException('Invalid duration format: ' + minute);
        //     }
    // }
    // public static Boolean isDoctorAvailable(DateTime triggeredAppTime, String duration, Id docId, Id clinicLocationId){    //proma
        
        //     List<Appointment__c> appointments = [SELECT Date_and_Time__c, Duration__c
        //                                          FROM Appointment__c
        //                                          WHERE Clinic_Resource__c = :docId AND (Status__c != 'completed' OR Status__c != 'declined')
        //                                          ORDER BY Date_and_Time__c ASC];
        
        //     if (appointments.isEmpty()){
            //         return true;
        //     }
        
        //     Integer prevIndex = -1;
        //     Integer nextIndex = -1;
        //     for (Integer i = 0; i < appointments.size(); i++){
            //         if (appointments[i].Date_and_Time__c < triggeredAppTime){
                //             prevIndex = i;
            //         } else if (appointments[i].Date_and_Time__c == triggeredAppTime){
                //             return false;
            //         } else if (appointments[i].Date_and_Time__c > triggeredAppTime){
                //             nextIndex = i;
                //             break;
            //         }
        //     }
        
        //     DateTime prevAppointmentDT;
        //     Boolean isPrevAvailable = false;
        //     Boolean isNextAvailable = false;
        //     if (prevIndex != -1){
            //         prevAppointmentDT = appointments[prevIndex].Date_and_Time__c.addMinutes(formatToIntegerMinute(appointments[prevIndex].Duration__c));
            //         if (prevAppointmentDT <= triggeredAppTime){
                //             isPrevAvailable = true;
            //         }
        //     }
        //     if (nextIndex != -1){
            //         triggeredAppTime = triggeredAppTime.addMinutes(formatToIntegerMinute(duration));
            //         system.debug('m nxt' + triggeredAppTime + ' ' + appointments[nextIndex].Date_and_Time__c);
            //         if (triggeredAppTime <= appointments[nextIndex].Date_and_Time__c){
                //             isNextAvailable = true;
            //         }
        //     }
        //     if (prevIndex != -1 && nextIndex != -1){
            //         if (isPrevAvailable && isNextAvailable){
                //             return true;
            //         }
        //     }
        //     if (prevIndex != -1 && nextIndex == -1){
            //         if (isPrevAvailable){
                //             return true;
            //         }
        //     }
        //     if (prevIndex == -1 && nextIndex != -1){
            //         if (isNextAvailable){
                //             return true;
            //         }
        //     }
        //     return false;
    // }
    
    // public static void assignRoundRobin(Appointment__c app){    //proma
        //     List<Clinic_Resource__c> defualtDoctor = [SELECT Id
        //                                               FROM Clinic_Resource__c
        //                                               LIMIT 1];
        
        //     if (defualtDoctor.isEmpty()){
            //         return;
        //     }
        
        //     List<Clinic_Resource__c> allDoctors = [SELECT Id, Auto_Number__c
        //                                            FROM Clinic_Resource__c
        //                                            WHERE Clinic_Location__c = :app.Clinic_Location__c];
        //     Integer totalDoctors = allDoctors.size();
        //     // List<Integer> allDurationMunites = getAllDurationMinutes();
        //     Integer roundRobin = roundRobinGenerator(totalDoctors);
        
        //     if (totalDoctors == 0){
            //         app.addError('No Doctor is available for the provided clinic location. Please choose a different clinic location and try again.');
        //     }
        //     Map<Integer, Clinic_Resource__c> docsMap = new Map<Integer, Clinic_Resource__c>();
        
        //     Integer counter = 0;
        //     for (Clinic_Resource__c doc : allDoctors){
            
            //         docsMap.put(Integer.valueOf(counter), doc);
            //         counter++;
        //     }
        
        //     Id assignedDoc = null;
        //     // system.debug(docsMap.get(roundRobin).Id);
        //     for (Integer i = 0; i < totalDoctors; i++){
            //         System.debug('i-->' + docsMap);
            //         if (isDoctorAvailable(app.Date_and_Time__c, app.Duration__c, docsMap.get(roundRobin).Id, app.Clinic_Location__c)){
                //             assignedDoc = docsMap.get(roundRobin).Id;
                //             break;
            //         }
            //         roundRobin = roundRobinGenerator(totalDoctors);
        //     }
        
        //     if (assignedDoc == null){
            //         assignWithoutRoundRobin(app, allDoctors);
        //     }
        
        //     app.Clinic_Resource__c = assignedDoc;
    // }
    // private static void assignWithoutRoundRobin(Appointment__c app, List<Clinic_Resource__c> allDoctors){    // proma
        //     for (Clinic_Resource__c doc : allDoctors){
            //         if (isDoctorAvailable(app.Date_and_Time__c, app.Duration__c, doc.Id, app.Clinic_Location__c)){
                //             app.Clinic_Resource__c = doc.Id;
                //             return;
            //         }
        //     }
        //     // app.addError('No doctor is available at this time. Please select different appointment time!');
    // }
    
    // public static Integer roundRobinGenerator(Integer totalDoctors){   // proma
        
        //     if (totalDoctors == 0){
            //         return 0;
        //     }
        
        //     Integer randomNumber = Integer.valueOf((Integer) (Math.random() * 100));
        //     // system.debug('i me ' + randomNumber);
        //     randomNumber = Math.Mod(randomNumber, totalDoctors);
        //     // system.debug('i m ' + randomNumber);
        //     return randomNumber;
    // }
    
    
    
    
    
    
    
    
    @AuraEnabled
    public static Map<Id, Map<String, String>> getAvailableProviders(Date dateT , String timee , List<Clinic_Resource__c> providerList) {
        // Fetch the current date 12:00 AM
        Date datee =dateT;
        //  system.debug(Integer.valueOf(time.split(':')[0])+ '   i m time  '+ Integer.valueOf(time.split(':')[1]));
        // system.debug(Integer.valueOf(timee.split(':')[0]));
        // system.debug('i m '+Integer.valueOf(timee.split(':')[1]));
        Time givenTime;
        if(timee != '') {
            String[] timeParts = timee.split(' '); // Split into time and AM/PM
            String timeValue = timeParts[0]; // "12:00"
            
            // Extract hours and minutes
            Integer hour = Integer.valueOf(timeValue.split(':')[0]);
            Integer minute = Integer.valueOf(timeValue.split(':')[1]);
            
            // Create the Time object
            givenTime = Time.newInstance(hour, minute, 0, 0);
        } else {
            givenTime = Time.newInstance(0, 0, 0, 0);
        }
        
        
        DateTime dateTimeValue = DateTime.newInstance(datee.year(), datee.month(), datee.day(), 0, 0, 0);
        Date dateValue = dateTimeValue.date();
        String dayOfWeek = dateTimeValue.format('EEEE');
        system.debug('i m day '+ dayOfWeek + givenTime);
        
        Map<Id, Map<String, String>> availableDoctorsMap = new Map<Id, Map<String, String>>();
        
        for (Availability__c availability : [
                SELECT Id, Clinic_Resource__c, Start_Shift__c, End_Shift__c, 
                    Clinic_Resource__r.Resource_Type__c, Clinic_Resource__r.Appointment_Type__c,
                    Clinic_Resource__r.Clinic_Location__c
                FROM Availability__c 
                WHERE Day__c = :dayOfWeek 
                AND Active__c = true
            ]) {
            List<Appointment__c> listOfappointments =  [SELECT Name,Id,Start_Time__c,
                                                            End_Time__c,Appointed_Date__c,Clinic_Location__c,    Clinic_Location__r.Provider_Company__r.Name,
                                                            Clinic_Location__r.Provider_Company__r.Resource_Category__c, 
                                                            Clinic_Resource__c FROM Appointment__c  WHERE 
                                                            Clinic_Resource__c = :availability.Clinic_Resource__c 
                                                            AND Appointed_Date__c = :dateValue AND Status__c != 'Cancelled'];
            if (timee != '') {
                if (givenTime >= availability.Start_Shift__c && givenTime <= availability.End_Shift__c) {
                    Boolean hasConflict = false;
                    
                    // Check for time conflicts in appointments
                    for (Appointment__c appointment : listOfappointments) {
                        // System.debug('appointment Start time: ' + appointment.Start_Time__c + ' End time: ' + appointment.End_Time__c);
                        // System.debug('Given time: ' + givenTime);
                        if (appointment.Start_Time__c <= givenTime && appointment.End_Time__c > givenTime) {
                            hasConflict = true;
                            break;
                        }
                    }
                    
                    // Add Clinic_Resource__c with its related details to the map if no conflict
                    if (!hasConflict) {
                        availableDoctorsMap.put(
                            availability.Clinic_Resource__c,
                        new Map<String, String>{
                            'Resource_Type__c' => availability.Clinic_Resource__r.Resource_Type__c,
                            'Appointment_Type__c' => availability.Clinic_Resource__r.Appointment_Type__c,
                            'Clinic_Location__c' => availability.Clinic_Resource__r.Clinic_Location__c
                        }
                        );
                    }
                }
            } else {
                // Add Clinic_Resource__c with its related details to the map
                availableDoctorsMap.put(
                    availability.Clinic_Resource__c,
                new Map<String, String>{
                    'Resource_Type__c' => availability.Clinic_Resource__r.Resource_Type__c,
                    'Appointment_Type__c' => availability.Clinic_Resource__r.Appointment_Type__c,
                    'Clinic_Location__c' => availability.Clinic_Resource__r.Clinic_Location__c
                }
                );
            }
        }
        
        // Debug to check the map values
        for (Id key : availableDoctorsMap.keySet()) {
            System.debug('Clinic_Resource__c: ' + key + ', Details: ' + availableDoctorsMap.get(key));
        }
        
        return availableDoctorsMap;
        
        //    List<Availability__c> availabilities = [ SELECT Clinic_Resource__c  FROM Availability__c  WHERE Day__c = :dayOfWeek  AND :givenTime >= Start_Shift__c AND :givenTime <= End_Shift__c AND Active__c = true];
        
        // Collect doctor IDs
        // List<Clinic_Resource__c> doctorIds = new List<Clinic_Resource__c>();
        // for (Availability__c availability : availabilities) {
            //     doctorIds.add(availability.Clinic_Resource__c);
        // }
        
        // return availableDoctors;
    }
    public static Boolean duplicateAppointment(Appointment__c app){
        List<Appointment__c> conflictingAppointments = [SELECT Id
                                                            FROM Appointment__c
                                                            WHERE Event_ID__c = :app.Event_ID__c];
        
        System.debug('conflictingAppointments-->' + conflictingAppointments);
        if (!conflictingAppointments.isEmpty()){
            return true;
        }
        return false;
    }
    public static void appEmailHandler(Appointment__c app){
        EventHandler.sentEventToDoctor(app, app.Location_Text__c);
        EventHandler.emailToPatient(app);
    }
    public static void formatDateTime(Appointment__c app){
        /*DateTime dt = app.Date_and_Time__c;
        
        String timeFormat2 = dt.format('hh:mm a');
        String timeFormat = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        String dayOfWeek = dt.format('EEEE');  // Thursday
        Integer dayOfMonth = dt.day();        // 21
        String month = dt.format('MMM');      // Oct
        Integer year = dt.year();             // 2024
        
        String daySuffix;
        if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31){
            daySuffix = 'st';
        } else if (dayOfMonth == 2 || dayOfMonth == 22){
            daySuffix = 'nd';
        } else if (dayOfMonth == 3 || dayOfMonth == 23){
            daySuffix = 'rd';
        } else{
            daySuffix = 'th';
        }
        
        String formattedDate = timeFormat2 + '@' + dayOfWeek + ', ' + dayOfMonth + daySuffix + '-' + month + '-' + year;
        app.Format_Date_For_Email__c = timeFormat;
        app.Formatted_Date__c = formattedDate;
         */
    }
    public static void statusValidator(Appointment__c app){
        // if (!app.From_Outlook__c && app.Status__c != 'Requested'){
            //     app.addError('Status should be \'Requested\'');
        // }
    }
    
    @AuraEnabled
    public static void notifyCancelToPatient(Appointment__c app, Integer choice) {
        System.debug('notifyCancelToPatient--->' + app);
        System.debug('meet-->'+app.Meet_Link_Url__c);
        
        String status;
        if(choice == 1){
            status = 'Cancelled';
        } else {
            status = 'Accepted';
        }
        
        // Query the Clinic Resource
        System.debug('Clinic_Resource__c--->' + app.Clinic_Resource__c);
        if (app.Clinic_Resource__c != null) {
            List<Clinic_Resource__c> provider = [SELECT Id, Name, Email__c FROM Clinic_Resource__c WHERE Id = :app.Clinic_Resource__c LIMIT 1];
            System.debug('Provider: '+provider);
            system.debug('clinic'+app.Clinic_Resource__c);
            List<Account> patient = [SELECT Id, Email__c , Name FROM Account WHERE Id = :app.Patient_Account__c LIMIT 1];
            System.debug('Patient: '+patient);
            System.debug('Provider_Company__c' + app.Provider_Company__c);
            List<Provider_Company__c> company;
            
            if (app.Provider_Company__c != null) {
                company = [SELECT Id, Name FROM Provider_Company__c WHERE Id = :app.Provider_Company__c LIMIT 1];
            }
            String providerEmail = provider[0].Email__c;
            String providerName = provider[0].Name;
            String patientEmail = patient[0].Email__c;
            String patientName = patient[0].Name;
            Time startTime = app.Start_Time__c;
            Datetime dateTimeValue = Datetime.newInstance(Date.today(), startTime);
            String formattedTime = dateTimeValue.format('hh:mm a');
            String appointedDate = app.Appointed_Date__c.format();
            String[] dateparts = appointedDate.split(' ');
            
            String onlyDate = dateparts[0];
            if (!provider.isEmpty()) {
                
                if (String.isNotBlank(provider[0].Email__c)) {
                    
                    if (company == null || company.isEmpty()) {
                        Clinic_Location__c clinicLocation = [
                            SELECT Provider_Company__c 
                            FROM Clinic_Location__c 
                            WHERE Id = :app.Clinic_Location__c
                            LIMIT 1
                        ];
                        // Safely fetch company details if not already fetched
                        company = [SELECT Id, Name FROM Provider_Company__c WHERE Id = :clinicLocation.Provider_Company__c LIMIT 1];
                        System.debug( company[0].Name);
                        
                    }
                    
                    
                    
                    // Prepare and send email
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { providerEmail });
                    email.setSubject('Appointment with ' + patientName + ' has been ' + app.Status__c );
                    email.setSenderDisplayName('Guardiant Appointment');
                    String emailBody = '<html><body><p>Dear ' + providerName + ',</p>' +
                        '<p>Your appointment with ' + patientName + ', at ' + company[0].Name + ', ' + app.Location_Text__c +
                        ', on <strong>' + formattedTime + ' , ' + app.Time_Zone__c + ', ' + onlyDate +
                        '</strong> has been ' + status + '.</p>';
                    
                    // Check if Meet_Link_Url__c is not blank
                    // Add the meeting link if it's not blank and Status__c equals 'Accepted'
                    
                    
                    // Set the email body
                    email.setHtmlBody(emailBody);
                    
                    
                    try {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                        System.debug('Appointment cancelled and email sent to provider ' + providerEmail);
                    } catch (Exception ex) {
                        System.debug('Email could not be sent due to the following error: ' + ex.getMessage());
                    }
                } else {
                    System.debug('Provider email is blank for Clinic Resource ID: ' + app.Clinic_Resource__c);
                }
            } else {
                System.debug('No Clinic Resource found for Appointment ID: ' + app.Id);
            }
            if (!patient.isEmpty()) {
                
                if (String.isNotBlank(patient[0].Email__c)) {
                    String emailBody;
                    
                    // Check if the appointment's status is 'Accepted' and a meeting link is provided
                    if (app.Status__c == 'Accepted' && String.isNotBlank(app.Meet_Link_Url__c)) {
                        // Email body for 'Accepted' status with meeting link
                        emailBody = '<html><body><p>Dear ' + patientName + ',</p>' +
                            '<p>Your appointment with ' + providerName  +' '+
                            'on <strong>' + formattedTime + ' , ' + app.Time_Zone__c + ', ' + onlyDate + '</strong> has been ' + status + '.</p>' +
                            '<p>You can join the meeting using the following link: <a href="' + app.Meet_Link_Url__c + '">' + app.Meet_Link_Url__c + '</a></p>' +
                            '<p>Thank you.</p></body></html>';
                    } else {
                        // Email body for other statuses without a meeting link
                        emailBody = '<html><body><p>Dear ' + patientName + ',</p>' +
                            '<p>Your appointment with ' + providerName + ', at ' + company[0].Name + ', ' + app.Location_Text__c + ', ' +
                            'on <strong>' + formattedTime + ' , ' + app.Time_Zone__c + ', ' + onlyDate + '</strong> has been ' + status + '.</p>' +
                            '<p>Thank you.</p></body></html>';
                    }
                    
                    // Prepare and send email to patient
                    Messaging.SingleEmailMessage patientEmailMessage = new Messaging.SingleEmailMessage();
                    patientEmailMessage.setToAddresses(new String[] { patientEmail });
                    patientEmailMessage.setSubject('Appointment with ' + providerName + ' has been '+app.Status__c );
                    patientEmailMessage.setSenderDisplayName('Guardiant Appointment');
                    patientEmailMessage.setHtmlBody(emailBody);
                    
                    
                    
                    // Send email to patient
                    try {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { patientEmailMessage });
                        System.debug('Appointment cancelled and email sent to patient ' + patientEmail);
                    } catch (Exception ex) {
                        System.debug('Email to patient could not be sent due to the following error: ' + ex.getMessage());
                    }
                } else {
                    System.debug('Patient email is blank for Patient Account ID: ' + app.Patient_Account__c);
                }
            } else {
                System.debug('No Patient Account found for Appointment ID: ' + app.Id);
            }
        } else {
            System.debug('No Clinic Resource linked to this appointment: ' + app.Id);
        }
    }
    /*@AuraEnabled
    public static void notifyUpdateTimeToPatient(Appointment__c newApp, Appointment__c oldApp) {
        System.debug('notifyUpdateTimeToPatient---> New: ' + newApp + ', Old: ' + oldApp);
        
        // Check if the Clinic Resource and Patient Account are linked to the appointment
        if (newApp.Clinic_Resource__c != null && newApp.Patient_Account__c != null) {
            // Query the Clinic Resource
            List<Clinic_Resource__c> provider = [SELECT Id, Name, Email__c FROM Clinic_Resource__c WHERE Id = :newApp.Clinic_Resource__c LIMIT 1];
            List<Account> patient = [SELECT Id, Email__c, Name FROM Account WHERE Id = :newApp.Patient_Account__c LIMIT 1];
            List<Provider_Company__c> company = [SELECT Id, Name FROM Provider_Company__c WHERE Id = :newApp.Provider_Company__c LIMIT 1];
            
            if (!provider.isEmpty() && !patient.isEmpty()) {
                Clinic_Resource__c clinicResource = provider[0];
                Account patientAccount = patient[0];
                
                // Extract provider and patient details
                String providerEmail = clinicResource.Email__c;
                String providerName = clinicResource.Name;
                String patientEmail = patientAccount.Email__c;
                String patientName = patientAccount.Name;
                
                // Format the old and new appointment times
                Datetime oldDateTimeValue = Datetime.newInstance(oldApp.Appointed_Date__c, oldApp.Start_Time__c);
                Datetime newDateTimeValue = Datetime.newInstance(newApp.Appointed_Date__c, newApp.Start_Time__c);
                
                String oldFormattedTime = oldDateTimeValue.format('hh:mm a');
                String newFormattedTime = newDateTimeValue.format('hh:mm a');
                
                String oldDate = oldApp.Appointed_Date__c.format();
                String newDate = newApp.Appointed_Date__c.format();
                
                // Prepare the email content
                String emailBody = '<html><body><p>Dear {0},</p>' +
                    '<p>The appointment with {1} at {2}, {3} has been rescheduled.</p>' +
                    '<p><strong>Old Schedule:</strong> {4}, {5}</p>' +
                    '<p><strong>New Schedule:</strong> {6}, {7}</p>' +
                    '<p>Thank you.</p></body></html>';
                
                // Notify the provider
                if (String.isNotBlank(providerEmail)) {
                    Messaging.SingleEmailMessage providerEmailMessage = new Messaging.SingleEmailMessage();
                    providerEmailMessage.setToAddresses(new String[] { providerEmail });
                    providerEmailMessage.setSubject('Appointment with ' + patientName + ' has been rescheduled');
                    providerEmailMessage.setSenderDisplayName('Guardiant Appointment');
                    providerEmailMessage.setHtmlBody(String.format(emailBody,
                    new String[] { providerName, patientName, company[0].Name, newApp.Location_Text__c,
                    oldDate, oldFormattedTime, newDate, newFormattedTime }));
                    
                    try {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { providerEmailMessage });
                        System.debug('Appointment reschedule notification sent to provider ' + providerEmail);
                    } catch (Exception ex) {
                        System.debug('Error sending email to provider: ' + ex.getMessage());
                    }
                } else {
                    System.debug('Provider email is blank for Clinic Resource ID: ' + newApp.Clinic_Resource__c);
                }
                
                // Notify the patient
                if (String.isNotBlank(patientEmail)) {
                    Messaging.SingleEmailMessage patientEmailMessage = new Messaging.SingleEmailMessage();
                    patientEmailMessage.setToAddresses(new String[] { patientEmail });
                    patientEmailMessage.setSubject('Appointment with ' + providerName + ' has been rescheduled');
                    patientEmailMessage.setSenderDisplayName('Guardiant Appointment');
                    patientEmailMessage.setHtmlBody(String.format(emailBody,
                    new String[] { patientName, providerName, company[0].Name, newApp.Location_Text__c,
                    oldDate, oldFormattedTime, newDate, newFormattedTime }));
                    
                    try {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { patientEmailMessage });
                        System.debug('Appointment reschedule notification sent to patient ' + patientEmail);
                    } catch (Exception ex) {
                        System.debug('Error sending email to patient: ' + ex.getMessage());
                    }
                } else {
                    System.debug('Patient email is blank for Patient Account ID: ' + newApp.Patient_Account__c);
                }
            } else {
                System.debug('No provider or patient found for Appointment ID: ' + newApp.Id);
            }
        } else {
            System.debug('No Clinic Resource or Patient Account linked to this appointment: ' + newApp.Id);
        }
    }*/
    
}