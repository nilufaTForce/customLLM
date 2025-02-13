public without sharing class EventHandler{
    
    public static void sentEventToDoctor(Appointment__c app, String location){
        // Clinic_Resource__c cr = [SELECT Email__c, Time_Zone__c FROM Clinic_Resource__c WHERE Id = :app.Clinic_Resource__c LIMIT 1];
        
        
        // String email = cr.Email__c;
        
        // Date endDate = app.Appointed_Date__c;
        // Integer duration = Integer.valueOf(Decimal.valueOf(app.Duration__c.split(' ')[0]) * 60);
        
        
        // String appWithProviderName = [SELECT Clinic_Location__r.Provider_Company__r.Name FROM Appointment__c WHERE Id = :app.Id LIMIT 1].Clinic_Location__r.Provider_Company__r.Name;
        
        
        // Map<String, Decimal> timezone = GuardiantUtility.getTimeZonesMap();
        
        // Integer diffInMinutes = Integer.valueOf(timezone.get(cr.Time_Zone__c) * 60) * -1;
        
        // Time startTime = app.Start_Time__c.addMinutes(diffInMinutes);
        // Time endTime = app.End_Time__c.addMinutes(diffInMinutes);
        
        // // Time startTime = app.Start_Time__c;
        // // Time endTime = app.End_Time__c;
        
        // System.debug('appWithProviderName-->' + appWithProviderName);
        // EmailWrapper ew = new EmailWrapper();
        // ew.patientName = app.Patient_Text__c;
        // ew.doctorName = app.Doctor_Text__c;
        // ew.providerName = appWithProviderName;
        // ew.doctorEmail = email;
        // ew.location = location;
        // ew.eventUID = app.Id;
        // // ew.startDT = app.Formatted_Date__c.replace('@', ' PST, ');
        // ew.startTimeText = GuardiantUtility.formatTime(app.Start_Time__c) + ' (' + cr.Time_Zone__c +'), </strong> on <strong>' + GuardiantUtility.formatDate(app.Appointed_Date__c) + '.';
        // ew.duration = app.Duration__c;
        // ew.appointedDate = app.Appointed_Date__c;
        // ew.startTime = startTime;
        // ew.endTime = endTime;
        
        
        //------------------------------------------------------------------ start
        // Clinic_Resource__c cr = [SELECT Email__c, Time_Zone__c FROM Clinic_Resource__c WHERE Id = :app.Clinic_Resource__c LIMIT 1];
        
        // // Extract email
        // String email = cr.Email__c;
        
        // system.debug('APP duration--->'+ app.Duration__c);
        // system.debug('APP Start_Time__c--->'+ app.Start_Time__c );
        // system.debug('APP End_Time__c --->'+ app.End_Time__c  );
        
        
        // // Calculate appointment end time (duration in minutes)
        // Date endDate = app.Appointed_Date__c;
        // Integer duration = Integer.valueOf(Decimal.valueOf(app.Duration__c.split(' ')[0]) * 60);
        
        
        
        // // Query the provider's name (company)
        // String appWithProviderName = [SELECT Clinic_Location__r.Provider_Company__r.Name FROM Appointment__c WHERE Id = :app.Id LIMIT 1].Clinic_Location__r.Provider_Company__r.Name;
        // String groupTimezone = [SELECT Time_Zone__c FROM Clinic_Location__c WHERE Id = :app.Clinic_Location__c LIMIT 1].Time_Zone__c;
        //-----------------------------------------------------------------------------------
        
        if (app.Telehealth__c == 'Yes') {
            // If Telehealth is Yes, call sentEventToDoctorTelehealth
            sentEventToDoctorTelehealth(app, location);
        } else {
            // If Telehealth is No, call sentEventToDoctorDefault
            sentEventToDoctorDefault(app, location);
            System.debug('Sent Event to doctor default');
        }
        
        
    }
    
    public static void sentEventToDoctorTelehealth(Appointment__c app, String location) {
        // Initiate the queueable process
        System.enqueueJob(new CreateAgoraVideoCallLink(app,location));
       
    }
    // public static void sentEventToDoctorTelehealthLink(Appointment__c app, String location) {
    
    //     Appointment__c recentApp = [SELECT Meet_Link_Url__c From Appointment__c WHERE Id =:app.Id LIMIT 1];
    //     string url =recentApp.Meet_Link_Url__c; 
    //     system.debug('recentApp--->'+recentApp.Meet_Link_Url__c);
    //     List<Clinic_Resource__c> clinicResources = [SELECT Email__c, Time_Zone__c FROM Clinic_Resource__c WHERE Id = :app.Clinic_Resource__c LIMIT 1];
    //     List<Clinic_Location__c> clinicLocations = [SELECT Time_Zone__c,Provider_Company__c FROM Clinic_Location__c WHERE Id = :app.Clinic_Location__c LIMIT 1];
        
    //     // Check if records are returned before accessing fields
    //     if (clinicResources.isEmpty() || clinicLocations.isEmpty()) {
    //         System.debug('No Clinic Resource or Clinic Location found');
    //         return;
    //     }
        
    //     Clinic_Resource__c cr = clinicResources[0];
    //     Clinic_Location__c clinicLocation = clinicLocations[0];
        
    //     // Extract email and time zone
    //     String email = cr.Email__c;
    //     String groupTimezone = clinicLocation.Time_Zone__c;
        
        
        
    //     // Calculate appointment end time (duration in minutes)
    //     Date endDate = app.Appointed_Date__c;
    //     Integer duration = Integer.valueOf(Decimal.valueOf(app.Duration__c.split(' ')[0]) * 60);
        
        
    //     // Query the provider's name (company) using relationship query to reduce SOQL
    //     String appWithProviderName = app.Clinic_Location__r.Provider_Company__r.Name;
    //     System.debug('Query the provider name:'+ appWithProviderName );
        
        
    //     // Get time zone map and calculate time difference
    //     Map<String, Decimal> timezone = GuardiantUtility.getTimeZonesMap();
    //     String providerTimezone = cr.Time_Zone__c;
    //     String groupLocationTimezone = 'UTC';
        
    //     if (timezone.containsKey(providerTimezone) && timezone.containsKey(groupLocationTimezone)) {
    //         Decimal providerOffset = timezone.get(providerTimezone);
    //         Decimal groupOffset = timezone.get(groupLocationTimezone);
            
    //         // Calculate the difference
    //         Decimal timeDifference = providerOffset - groupOffset;
            
            
    //         // Integer diffInMinutes = Integer.valueOf(timezone.get(cr.Time_Zone__c) * 60) * -1;
    //         Time startTime = app.Start_Time__c;
    //         Time endTime = app.End_Time__c;
            
            
            
    //         // Prepare the event data for sending
    //         String startTimeText = GuardiantUtility.formatTime(app.Start_Time__c) + ', </strong> on <strong>' + GuardiantUtility.formatDate(app.Appointed_Date__c) + '.';
    //         Integer timeDifferenceInMinutes = (timeDifference * 60).intValue();
            
    //         Time adjustedStartTime;
    //         Time adjustedEndTime;
            
    //         // Adjust the start and end times based on the time zone difference
    //         if (timeDifferenceInMinutes < 0) {
    //             // If negative, use the absolute value and add minutes
    //             timeDifferenceInMinutes = Math.abs(timeDifferenceInMinutes);
                
    //             adjustedStartTime = startTime.addMinutes(timeDifferenceInMinutes);
    //             adjustedEndTime = endTime.addMinutes(timeDifferenceInMinutes);
    //         } else {
    //             // If positive or zero, subtract minutes
    //             adjustedStartTime = startTime.addMinutes(-timeDifferenceInMinutes);
    //             adjustedEndTime = endTime.addMinutes(-timeDifferenceInMinutes);
    //         }
          
    //         EventService.sendOutlookEventAsync(
    //             email,
    //         app.Patient_Text__c,
    //         app.Doctor_Text__c,
    //         appWithProviderName,
    //         location,
    //         app.Id,
    //         startTimeText,
    //         app.Duration__c,
    //         app.Appointed_Date__c,
    //         adjustedStartTime,
    //         adjustedEndTime,
    //         groupTimezone,
    //         recentApp.Meet_Link_Url__c
    //         );
    //     } else {
    //         if (!timezone.containsKey(providerTimezone)) {
    //             System.debug('Provider timezone not found in the map: ' + providerTimezone);
    //         }
    //         if (!timezone.containsKey(groupLocationTimezone)) {
    //             System.debug('Group location timezone not found in the map: ' + groupLocationTimezone);
    //         }
    //     }
    // }
    
    
    
    
    public static void sentEventToDoctorDefault(Appointment__c app, String location){

        system.debug('Sent event to doctor default');
        System.debug('App: ' + app);
        // if(app.From_Vapi__c) {
        //     System.debug('From Vapi');
        //     return;
        // }
        String meetLink = (app.Meet_Link_Url__c != null) ? app.Meet_Link_Url__c : ''; // Use empty string if no link
        // String meetLink = '';
    
        // System.debug('recentApp--->' + recentApp.Meet_Link_Url__c);
    
        List<Clinic_Resource__c> clinicResources = [SELECT Email__c, Time_Zone__c FROM Clinic_Resource__c WHERE Id = :app.Clinic_Resource__c LIMIT 1];
        List<Clinic_Location__c> clinicLocations = [SELECT Time_Zone__c ,Provider_Company__c, Provider_Company__r.Name FROM Clinic_Location__c WHERE Id = :app.Clinic_Location__c LIMIT 1];
        
        // Check if records are returned before accessing fields
        if (clinicResources.isEmpty()) {
            System.debug('No Clinic Resource found');
            return;
        }
        if (clinicLocations.isEmpty()) {
            System.debug('No Clinic Location found');
            return;
        }
        
        Clinic_Resource__c cr = clinicResources[0];
        Clinic_Location__c clinicLocation = clinicLocations[0];
        
        // Extract email and time zone
        String email = cr.Email__c;
        String groupTimezone = clinicLocation.Time_Zone__c;
        
        // Calculate appointment end time (duration in minutes)
        Date endDate = app.Appointed_Date__c;

        system.debug(' okay okay '+app.Start_Time__c);
        Integer duration = Integer.valueOf(Decimal.valueOf(app.Duration__c.split(' ')[0]) * 60);
        
        // Query the provider's name (company) using relationship query to reduce SOQL
        
        String appWithProviderName = clinicLocation.Provider_Company__r.Name;
        // System.debug('Query the provider name:'+ appWithProviderName );

      
        
        // Get time zone map and calculate time difference
        Map<String, Decimal> timezone = GuardiantUtility.getTimeZonesMap();
        String providerTimezone = cr.Time_Zone__c;
        String groupLocationTimezone = 'UTC';
        
        if (timezone.containsKey(providerTimezone) && timezone.containsKey(groupLocationTimezone)) {
            Decimal providerOffset = timezone.get(providerTimezone);
            Decimal groupOffset = timezone.get(groupLocationTimezone);
            
            // Calculate the difference
            Decimal timeDifference = providerOffset - groupOffset;
            
            Time startTime = app.Start_Time__c;
            Time endTime = app.End_Time__c;
            
            // Prepare the event data for sending
            String startTimeText = GuardiantUtility.formatTime(app.Start_Time__c) + ', </strong> on <strong>' + GuardiantUtility.formatDate(app.Appointed_Date__c) + '.';
            Integer timeDifferenceInMinutes = (timeDifference * 60).intValue();
            
            Time adjustedStartTime;
            Time adjustedEndTime;
            

            DateTime startDateTime = DateTime.newInstance(app.Appointed_Date__c, startTime);
            DateTime endDateTime = DateTime.newInstance(app.Appointed_Date__c, endTime);
            // Adjust the start and end times based on the time zone difference
            if (timeDifferenceInMinutes < 0) {
                // adjustedStartTime =  startTime;
                // adjustedEndTime= endTime;
                // If negative, use the absolute value and add minutes
                timeDifferenceInMinutes = Math.abs(timeDifferenceInMinutes);
                startDateTime = startDateTime.addMinutes(timeDifferenceInMinutes);
                endDateTime= endDateTime.addMinutes(timeDifferenceInMinutes);
                
                // adjustedStartTime = startTime.addMinutes(timeDifferenceInMinutes);
                // adjustedEndTime = endTime.addMinutes(timeDifferenceInMinutes);
            } else {
                // If positive or zero, subtract minutes
                startDateTime = startDateTime.addMinutes(timeDifferenceInMinutes);
                // adjustedStartTime = startTime.addMinutes(-timeDifferenceInMinutes);
                endDateTime= endDateTime.addMinutes(-timeDifferenceInMinutes);
                // adjustedStartTime =  startTime;
                // adjustedEndTime= endTime;
            }

            system.debug('i m adjusted '+startDateTime );
            System.debug('Record TYpe: ' + app.RecordType.Name);
            // sy


            // Send event with either Meet Link URL or empty string
            EventService.sendOutlookEventAsync(
                email,
                app.Patient_Text__c,
                app.Doctor_Text__c,
                appWithProviderName,
                location,
                app.Id,
                startTimeText,
                app.Duration__c,
                app.Appointed_Date__c,
                adjustedStartTime,
                adjustedEndTime,
                groupTimezone,
                meetLink, // Use meetLink, which will be empty string if no URL is present
                app,
                startDateTime,
                endDateTime
            );

        } else {
            if (!timezone.containsKey(providerTimezone)) {
                System.debug('Provider timezone not found in the map: ' + providerTimezone);
            }
            if (!timezone.containsKey(groupLocationTimezone)) {
                System.debug('Group location timezone not found in the map: ' + groupLocationTimezone);
            }
        }
        System.debug('sendOutlookEventAsync');
    }
    
    public static void emailToPatient(Appointment__c app){
        
        if (app.Patient_Account__c == null || app.Status__c == 'Requested'){
            return;
        }
        System.debug('emailToPatient: ' + app.Patient_Account__c);
        // Lead patient = [SELECT Name, Email FROM Lead WHERE Id = :app.Patient__c LIMIT 1];
        List<Account> patients = [SELECT Name, Email__c FROM Account WHERE Id = :app.Patient_Account__c LIMIT 1];
        if (patients.isEmpty() || patients[0].Email__c == null) {
            return;
        }
        Account patient = patients[0];
        
        // Query Clinic_Location and Provider_Company details in a single query
        List<Clinic_Location__c> clinicLocations = [SELECT Provider_Company__r.Name, Address_Text__c, Time_Zone__c
                                                    FROM Clinic_Location__c
                                                    WHERE Id = :app.Clinic_Location__c LIMIT 1];
        
        if (clinicLocations.isEmpty()) {
            return;
        }
        Clinic_Location__c cl = clinicLocations[0];
        
        if (patient.Email__c == null){
            return;
        }
        
        String patientName = patient.Name;
        String email = patient.Email__c;
        String doctorName = app.Doctor_Text__c;
        String timeT = GuardiantUtility.formatTime(app.Start_Time__c);
        String dateT = GuardiantUtility.formatDate(app.Appointed_Date__c);
        String clinicName = cl.Provider_Company__r.Name;
        String location = cl.Address_Text__c;
        String timezone = cl.Time_Zone__c;
        // System.debug(patientName + '--' + email + '--' + clinicName + '--' + timeT + '--' + dateT + '--' + location);
        if (app.Status__c == 'Accepted'){
            EventService.notifyAppToPatient(doctorName, patientName, email, clinicName, timeT, dateT, location, app.Id, 3, timezone);
        } else if (app.Status__c == 'Declined'){
            EventService.notifyAppToPatient(doctorName, patientName, email, clinicName, timeT, dateT, location, app.Id, 2, timezone);
        } else {
            EventService.notifyAppToPatient(doctorName, patientName, email, clinicName, timeT, dateT, location, app.Id, 1, timezone);
        }
    }
    
   
    
    
    
    
    public class EmailWrapper{
        public String patientName;
        public String providerName;
        public String doctorName;
        public String doctorEmail;
        public String eventUID;
        public String location;
        public String startTimeText;
        public String duration;
        public Date appointedDate;
        public Time startTime;
        public Time endTime;
        public String groupTimeZone;
        public String meetlink;
    }
    
    public class PatAppWrapper{
        public String patientName;
        public String email;
        public String doctorName;
        public String doctorEmail;
        public String eventUID;
        public String location;
        public Date startDate;
        public Date endDate;
        
    }
    
}