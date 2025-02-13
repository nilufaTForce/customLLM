public class OutlookAPIHandler{
    private static Outlook_Subscribe__c getAccessToken(String userID){
        
        List<Outlook_Subscribe__c> osList = [SELECT Access_Token__c, Refresh_Token__c
                                             FROM Outlook_Subscribe__c
                                             WHERE User_ID__c = :userID
                                             ORDER BY CreatedDate DESC];
        if (osList.isEmpty()){
            return null;
        }
        
        return osList[0];
    }
    
    public static Map<String, Object> getEventDetils(String resourceUrl){
        Map<String, String> outlookApiSettingsMap = getOutlookApiSettingsInfo();
        System.debug('outlookApiSettingsMap => ' + outlookApiSettingsMap);
        String baseUrl = outlookApiSettingsMap.get('Endpoint');
        
        String ver = outlookApiSettingsMap.get('Version');
        Microsoft_Outlook_API__mdt config =  [SELECT Endpoint__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];
        
        // do not delete
        // String endpoint = 'https://graph.microsoft.com/v1.0/me/events';
        String endpoint = config.Endpoint__c + '/v1.0/me/events'; // Concatenate with the required path
        
        // System.debug('Endpoint => ' + endpoint);
        
        // String accessToken = getAccessToken(outlookApiSettingsMap);
        String userID = resourceUrl.split('/')[1];
        Outlook_Subscribe__c os = getAccessToken(userID);
        String accessToken = os.Access_Token__c;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        // System.debug('Access Token => ' + accessToken);
        
        Map<String, Object> responseMap;
        try{
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200){
                String responseBody = res.getBody();
                Map<String, Object> responseStatusMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                // String s = JSON.serialize(responseStatusMap.get('value'));
                // System.debug('Parsed String--->' + s);
                List<Object> values = (List<Object>)responseStatusMap.get('value');
                responseMap = (Map<String, Object>)values[0];
                // System.debug('Parsed Response--->' + JSON.deserializeUntyped(JSON.serialize(responseMap.get('value'))));
                System.debug('Parsed Response--->' + responseMap);
            } else if (res.getStatusCode() == 401){
                // os = RefreshTokenService.getRefreshToken(os);
                // Database.update (os);
                // responseMap = OutlookEventDetailService.getEventDetils(resourceUrl, os);
            } else{
                System.debug('Failed with status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        return responseMap;
    }
    
    public static Map<String, String> getOutlookApiSettingsInfo(){
        Microsoft_Outlook_API__mdt outlookSettings = getCreds();
        
        Map<String, String> outlookApiSettingsMap = new Map<String, String>();
        
        // Add key-value pairs to the map
        outlookApiSettingsMap.put('Endpoint', outlookSettings.Endpoint__c);
        outlookApiSettingsMap.put('ClientId', outlookSettings.Client_Id__c);
        outlookApiSettingsMap.put('ClientSecret', outlookSettings.Client_Secret__c);
        outlookApiSettingsMap.put('Version', outlookSettings.Version__c);
        outlookApiSettingsMap.put('TenantId', outlookSettings.Tenant_Id__c);
        
        return outlookApiSettingsMap;
    }
    
    @future(callout = true)
    public static void updateAppointments(String eventID){
        //
    }
    
    public static String upsertAppointment(Map<String, Object> eventDetails, String changeType){
        
        if (eventDetails == null || eventDetails.isEmpty()){
            return 'Event details is null';
        }
        
        System.debug('eventDetails-->' + JSON.serialize(eventDetails));
        
        List<Object> values = new List<Object>();
        if (eventDetails.containsKey('value')){
            values = (List<Object>)eventDetails.get('value');
            eventDetails = (Map<String, Object>)values[0];
        }
        String eventID = (String) eventDetails.get('id');
        
        List<Appointment__c> appList = new List<Appointment__c>();
        Boolean isUpdate = false;
        Id appointmentToUpdate;
        String tempKeepAppointmentId;
        System.debug('Here 1');
        
        Boolean isInsert = true;
        if (eventDetails.containsKey('uid')){
            System.debug('Here 2');
            String uid = (String) eventDetails.get('uid');
            System.debug('uid: ' + uid);
            
            if (uid.startsWithIgnoreCase('a1l')){
                System.debug('Here 3');
                isInsert = false;
                String appointmentId = uid.substringBefore('DTSTAMP').trim();
                tempKeepAppointmentId = appointmentId;
                
                List<Appointment__c> appointmentToUpdateList = [SELECT Id, Event_ID__c
                                                                FROM Appointment__c
                                                                WHERE Id = :appointmentId];
                if (appointmentToUpdateList.size() > 0 && (appointmentToUpdateList[0].Event_ID__c == null || appointmentToUpdateList[0].Event_ID__c == '')){
                    System.debug('Here 4: ' + appointmentToUpdateList[0].Event_ID__c + ' app Id ' + appointmentId);
                    appointmentToUpdateList[0].Event_ID__c = eventID;
                    update appointmentToUpdateList;
                    return 'Appointment updated successfully.';
                }
            }
        }
        System.debug('Here 5');
        
        
        Map<String, Object> startMap = (Map<String, Object>)eventDetails.get('start');
        String startDateTimeStr = (String) startMap.get('dateTime');
        // System.debug('Start DateTime: ' + startDateTimeStr);
        
        
        Map<String, Object> endMap = (Map<String, Object>)eventDetails.get('end');
        String endDateTimeStr = (String) endMap.get('dateTime');
        
        Map<String, Object> organiserMap = (Map<String, Object>)eventDetails.get('organizer');
        Map<String, Object> emailAddressMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(organiserMap.get('emailAddress')));
        String email = (String) emailAddressMap.get('address');
        
        // List<Clinic_Resource__c> doctorList = [SELECT Id, Clinic_Location__c FROM Clinic_Resource__c WHERE Email__c = :docEmail];
        List<Clinic_Resource__c> doctorList = [SELECT Id, Email__c, Clinic_Location__c, Clinic_Location__r.Provider_Company__c, Time_Zone__c
                                               FROM Clinic_Resource__c
                                               WHERE Email__c = :email];
        
        if (doctorList.isEmpty()){
            String tempUid = (String) eventDetails.get('uid');
            String tempAppointmentId = tempUid.substringBefore('DTSTAMP').trim();
            List<Appointment__c> apps = [SELECT Id, Clinic_Resource__c FROM Appointment__c
                                            WHERE Id = :tempAppointmentId];
            doctorList = [SELECT Id, Email__c, Clinic_Location__c, Clinic_Location__r.Provider_Company__c, Time_Zone__c
                          FROM Clinic_Resource__c
                          WHERE Id = :apps[0].Clinic_Resource__c
                LIMIT 1];
        }
        Provider_Company__c affiliatedGrp = [SELECT Id
                                             FROM Provider_Company__c
                                             WHERE Id = :doctorList[0].Clinic_Location__r.Provider_Company__c
            LIMIT 1];
        String docEmail = doctorList[0].Email__c;
        // Trim milliseconds to match the expected format for Datetime.valueOfGmt
        startDateTimeStr = startDateTimeStr.substring(0, 19);
        endDateTimeStr = endDateTimeStr.substring(0, 19);
        
        // Replace 'T' with space
        startDateTimeStr = startDateTimeStr.replace('T', ' ');
        endDateTimeStr = endDateTimeStr.replace('T', ' ');
        System.debug('Start Time String: ' + startDateTimeStr);
        System.debug('End Time String: ' + endDateTimeStr);
        
        // System.debug('startDateTimeStr-->' + startDateTimeStr);
        // System.debug('endDateTimeStr-->' + endDateTimeStr);
        
        // Convert to Datetime objects
        Datetime startDateTime = Datetime.valueOf(startDateTimeStr);
        Datetime endDateTime = Datetime.valueOf(endDateTimeStr);
        
        Map<String, Integer> startTimeMap = sperateTime(startDateTimeStr.split(' ')[1]);
        Map<String, Integer> endTimeMap = sperateTime(endDateTimeStr.split(' ')[1]);
        
        Time startTime = Time.newInstance(startTimeMap.get('hours'), startTimeMap.get('minutes'), startTimeMap.get('seconds'), 0);
        Time endTime = Time.newInstance(endTimeMap.get('hours'), endTimeMap.get('minutes'), endTimeMap.get('seconds'), 0);
        System.debug('Start Time: ' + startTime);
        System.debug('End Time: ' + endTime);
        
        Map<String, Decimal> timezone = GuardiantUtility.getTimeZonesMap();
        String providerTimezone = doctorList[0].Time_Zone__c;
        
        System.debug('Provider Timezone: ' + providerTimezone);
        Datetime adjustedStartDateTime = startDateTime;
        Datetime adjustedEndDateTime = endDateTime;
        
        if (timezone.containsKey(providerTimezone)) {
            Decimal providerOffset = timezone.get(providerTimezone);
            Integer timeNeedToBeAdjusted = (providerOffset * 60).intValue(); // Convert hours to minutes
            
            System.debug('Time Offset (minutes): ' + timeNeedToBeAdjusted);
            
            // Adjust DateTime directly instead of just Time
            adjustedStartDateTime = startDateTime.addMinutes(timeNeedToBeAdjusted);
            adjustedEndDateTime = endDateTime.addMinutes(timeNeedToBeAdjusted);
        }
        
        System.debug('Adjusted Start DateTime: ' + adjustedStartDateTime);
        System.debug('Adjusted End DateTime: ' + adjustedEndDateTime);
        if (changeType == 'updated' || changeType == 'deleted'){ 
            
            List<Appointment__c> appointment = [SELECT Id, Clinic_Resource__c, Event_ID__c
                                                FROM Appointment__c
                                                WHERE Event_ID__c = :eventID];
            isUpdate = true;
            isInsert = false;
            System.debug('isUpdate ' + eventID);
            Map<String, Object> responseStatus = (Map<String, Object>)eventDetails.get('responseStatus');
            String comingStatus = (String) responseStatus.get('response');
            appList = [SELECT Id, From_Outlook__c, Status__c, Request_Body__c, Appointed_Date__c, Patient_Account__c, Clinic_Resource__c, Clinic_Location__c, Event_ID__c, Description__c, Appointment_Type__c, Start_Time__c, End_Time__c
                       FROM Appointment__c
                       WHERE Event_ID__c = :eventID];
            if (appList.size() == 0){
                appList = [SELECT Id, From_Outlook__c, Status__c, Request_Body__c, Appointed_Date__c, Patient_Account__c, Clinic_Resource__c, Clinic_Location__c, Event_ID__c, Description__c, Appointment_Type__c, Start_Time__c, End_Time__c
                           FROM Appointment__c
                           WHERE Id = :tempKeepAppointmentId];
                if (appList.size() == 0){
                    System.debug('No appointment found to update');
                    return 'No appointment found to update';
                }
            }
            appointmentToUpdate = appList[0].Id;
            appList[0].Appointed_Date__c = adjustedStartDateTime.date();
            appList[0].Start_Time__c = adjustedStartDateTime.time(); 
            appList[0].End_Time__c = adjustedEndDateTime.time();

            if((comingStatus == 'accepted' && appList[0].Status__c == 'Accepted') ||
            (comingStatus == 'cancelled' && appList[0].Status__c == 'Cancelled')) {
                return 'Already Updated';
            }
            if (comingStatus == 'cancelled' || comingStatus == 'declined' || changeType == 'deleted'){
                appList[0].Status__c = 'Cancelled';
            } else if (comingStatus == 'accepted'){
                appList[0].Status__c = 'Accepted';
            }
            System.debug('appointmentToUpdate --> ' + appList[0]);
            // return 'No appointment found to updated.';
        }
        
        Appointment__c newAppointment = new Appointment__c();
        Id appointmentTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Unavailable').getRecordTypeId();
        newAppointment.RecordTypeId = appointmentTypeId;
        
        
        newAppointment.From_Outlook__c = true;
        newAppointment.Status__c = 'Accepted';
        newAppointment.Request_Body__c = JSON.serialize(eventDetails);
        
        newAppointment.Appointed_Date__c = startDateTime.date(); // Not working because of the validation rule
        newAppointment.Clinic_Resource__c = doctorList[0].Id;
        newAppointment.Clinic_Location__c = doctorList[0].Clinic_Location__c;
        
        // newAppointment.Duration_From_Outlook_Minutes__c = getDateTimeDifferenceInMinutes(startDateTimeStr, endDateTimeStr);
        newAppointment.Provider_Company__c = affiliatedGrp.Id;
        newAppointment.Event_ID__c = eventID;
        // newAppointment.Description__c = 'Subject : ' + (String) eventDetails.get('subject') + '::' + 'Body : ' + (String) eventDetails.get('bodyPreview');
        // newAppointment.Description__c = (String) eventDetails.get('bodyPreview');
        // Query the Id from Appointment_Type__c where Name = 'Emergency Check up'
        Appointment_Type__c appointmentType = [
            SELECT Id 
            FROM Appointment_Type__c 
            WHERE Name = 'Emergency Check up' 
            LIMIT 1
        ];
        
        // Assign the retrieved Id to the newAppointment
        if (appointmentType != null) {
            newAppointment.Appointment_Type__c = appointmentType.Id;
        } else {
            // Handle the case where the appointment type is not found
            
        }
        
        
        
        appList[0].Start_Time__c = adjustedStartDateTime.time(); 
        appList[0].End_Time__c = adjustedEndDateTime.time();
        
        
        System.debug('upsertAppointment-->' + JSON.serializePretty(newAppointment));
        try{
            if (isInsert){
                if (String.isNotBlank(eventID)) {
                    // Check if an appointment with the same Event_ID__c already exists
                    List<Appointment__c> existingAppointments = [
                        SELECT Id, Event_ID__c 
                        FROM Appointment__c 
                        WHERE Event_ID__c = :eventID 
                        LIMIT 1
                    ];
                    
                    if (!existingAppointments.isEmpty()) {
                        System.debug('Appointment with Event ID already exists: ' + eventID);
                        return 'Appointment already exists with the same Event ID.';
                    }
                }
                System.debug('Inserting appointment--> ' + newAppointment);
                Database.insert(newAppointment, true);
            } else if (isUpdate){
                System.debug('Updating appointment--> ' + appList[0]);
                Database.update(appList, true);
                // EventHandler.emailToPatient(appList[0]);
            }
            // System.debug('Successfully upserted the appointment');
            return 'Success';
        } catch (Exception e){
            System.debug('Failed to upsert-->' + e.getMessage());
            return JSON.serializePretty('Failed to upsert appointment due to exception: ' + e.getMessage());
        }
    }
    
    public static String deleteAppointment(String eventId){
        try{
            // Appointment__c appointmentToDelete = [SELECT Id FROM Appointment__c WHERE Event_ID__c =: eventId LIMIT 1];
            List<Appointment__c> appList = [SELECT Id
                                            FROM Appointment__c
                                            WHERE Event_ID__c = :eventId];
            System.debug('appList-->' + appList.size());
            if (!appList.isEmpty()){
                appList[0].Status__c = 'Cancelled';
                update appList;
            }
        } catch (Exception e){
            return 'Failed to delete appointment due to exception: ' + e.getMessage();
        }
        return 'Success';
    }
    
    /*
    public static Integer getDateTimeDifferenceInMinutes(String startDateString, String endDateString){
        Datetime startDateTime = Datetime.valueOfGmt(startDateString);
        Datetime endDateTime = Datetime.valueOfGmt(endDateString);
        Long differenceInMillis = endDateTime.getTime() - startDateTime.getTime();
        Integer differenceInMinutes = (Integer) (differenceInMillis / (1000 * 60));
        System.debug('differenceInMinutes -> ' + differenceInMinutes);
        return differenceInMinutes;
    }
     */
    private static Microsoft_Outlook_API__mdt getCreds(){
        return [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
    }
    
    private static Map<String, Integer> sperateTime(String timeString){
        Map<String, Integer> returnMap = new Map<String, Integer>();
        
        List<String> timeParts = timeString.split(':');
        Integer hours = Integer.valueOf(timeParts[0]);
        Integer minutes = Integer.valueOf(timeParts[1]);
        Integer seconds = Integer.valueOf(timeParts[2]);
        
        returnMap.put('hours', hours);
        returnMap.put('minutes', minutes);
        returnMap.put('seconds', seconds);
        
        return returnMap;
    }
    
}