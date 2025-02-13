public with sharing class Two_Himel {
    public static string createAppointmentThroughChat(String phoneNumber) {
        List<SMS_Text__c> smsTexts = [SELECT Id, Phone__c, Conversation__c, Message_Serial__c, Is_Completed__c, Is_Expired__c FROM SMS_Text__c WHERE Phone__c = :phoneNumber AND Is_Expired__c = false AND Is_Completed__c = false ORDER BY Message_Serial__c DESC];
        if (smsTexts.isEmpty()) {
            return 'No messages found. Please provide the required information: Name, Age, Medical Issue, Appointment Type (Offline/Online), Address, Date, Time, and Email.';
        }
        
        // Map to store required data with their serial numbers
        Map<Integer, String> requiredFields = new Map<Integer, String>{
            1 => 'Name',
            2 => 'Date of Birth',
            3 => 'gender',
            4 => 'Medical Issue',
            5 => 'Appointment Type (Offline/Online)',
            6 => 'Address',
            7 => 'Date',
            8 => 'Time',
            9 => 'Email'
        };
        Map<Integer, String> receivedData = new Map<Integer, String>();
        
        for (SMS_Text__c sms : smsTexts) {
            Integer serial = Integer.valueOf(sms.Message_Serial__c);
            receivedData.put(serial, sms.Conversation__c);
        }
        List<String> missingFields = new List<String>();
        for (Integer key : requiredFields.keySet()) {
            if (!receivedData.containsKey(key)) {
                missingFields.add(requiredFields.get(key));
            }
        }
        if (!missingFields.isEmpty()) {
            return 'Please provide the following missing information: ' + String.join(missingFields, ', ');
        } // ***
        
        // Convert Date of Birth from dd/mm/yyyy to mm/dd/yyyy
        String dobInput = receivedData.get(2);
        Date dob = null;
        try {
            List<String> dobParts = dobInput.split('/');
            dob = Date.newInstance(Integer.valueOf(dobParts[2]), Integer.valueOf(dobParts[1]), Integer.valueOf(dobParts[0]));
        } catch (Exception e) {
            return 'Invalid Date of Birth format. Please provide it in dd/mm/yyyy format.';
        }
        
        // Fetch or create patient account
        Account patientAccount;
        String email = receivedData.get(9);
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Email__c = :email LIMIT 1];
        if (!existingAccounts.isEmpty()) {
            patientAccount = existingAccounts[0];
        } else {
            patientAccount = new Account(
                Name = receivedData.get(1),
            Email__c = email,
            Gender__c = receivedData.get(3),
            Date_of_Birth__c = dob
                );
            insert patientAccount;
        }
        List<Resource_Type__c> providerType = [SELECT Id, Resource_Category__c, Appointment_Type__c, Clinic_Location__c,
                                                    Clinic_Location__r.Provider_Company__c
                                                    FROM Resource_Type__c
                                                    WHERE Name = :receivedData.get(4) LIMIT 1];
        if (providerType.isEmpty()) {
            return 'Invalid provider type specified.';
        }
        
        //Fetch appointment type and calculate duration
        List<Appointment_Type__c> appointmentType = [SELECT Id, Name, Duration__c
                                                          FROM Appointment_Type__c
                                                          WHERE Id = :providerType[0].Appointment_Type__c LIMIT 1];
        if (appointmentType.isEmpty()) {
            return 'Invalid appointment type for the provider.';
        }
        
        String durationString = appointmentType[0].Duration__c;
        Integer durationValue;
        try {
            durationValue = Integer.valueOf(durationString.split(' ')[0]);
        } catch (Exception e) {
            return 'Invalid duration format in appointment type.';
        }
        
        //Fetch available doctors
        List<Clinic_Resource__c> doctors = [SELECT Id FROM Clinic_Resource__c
                                                WHERE Resource_Type__c = :providerType[0].Id];
        if (doctors.isEmpty()) {
            return 'No available doctors found for the specified provider type.';
        }
        String startTimeInput = receivedData.get(8); // Assumed formats: "HH:mm", "HH AM/PM"
        Integer startHour;
        Integer startMinute;
        
        try {
            // Normalize the input to lower case and trim any whitespace
            String normalizedInput = startTimeInput.trim().toLowerCase();
            startHour = 0;
            startMinute = 0;
            // Check if the input contains a colon for HH:mm format
            if (normalizedInput.contains(':')) {
                List<String> timeParts = normalizedInput.split(':');
                startHour = Integer.valueOf(timeParts[0].trim());
                startMinute = Integer.valueOf(timeParts[1].substring(0, 2).trim()); // Get only the minutes part
                if (startMinute < 0 || startMinute >= 60) {
                    return 'Invalid minute value. Please provide a valid time.';
                }
            } else {
                // Handle HH AM/PM format
                List<String> parts = normalizedInput.split(' ');
                String timePart = parts[0]; // The hour part (e.g., "10" or "10:15")
                String amPmPart = parts.size() > 1 ? parts[1] : ''; // The AM/PM part
                // Parse the hour
                startHour = Integer.valueOf(timePart.split(':')[0].trim());
                // Set minutes to 00 if no minutes are provided
                startMinute = 0;
                // Convert to 24-hour format based on AM/PM
                if (amPmPart.equals('pm') && startHour < 12) {
                    startHour += 12; // Convert PM hour to 24-hour format
                } else if (amPmPart.equals('am') && startHour == 12) {
                    startHour = 0; // Midnight case
                }
                if (startHour < 0 || startHour >= 24) {
                    return 'Invalid hour value. Please provide a valid time.';
                }
                if (startMinute < 0 || startMinute >= 60) {
                    return 'Invalid minute value. Please provide a valid time.';
                }
            }
            
        } catch (Exception e) {
            return 'Invalid time format. Please provide time in HH:mm or HH AM/PM format.';
        }
        // Create Time instances for start and end time
        Time startTime = Time.newInstance(startHour, startMinute, 0, 0);
        Time endTime = startTime.addMinutes(durationValue);
        System.debug('Start Time: ' + startTime);
        System.debug('End Time: ' + endTime);
        String meetLink;
        String appointmentTypeName;
        if (receivedData.get(5) == 'online') {
            meetLink = 'https://meet.google.com/say-iaye-kit';
            appointmentTypeName = providerType[0].Appointment_Type__c;
        } else {
            meetLink = '';
            appointmentTypeName = providerType[0].Appointment_Type__c;
        }
        //Create appointment
        Id recordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Appointment').getRecordTypeId();
        Appointment__c appointment = new Appointment__c(
        // RecordTypeId = '012Wr000000ymUnIAI',
        RecordTypeId = recordTypeId,

        Patient_Account__c = patientAccount.Id,
        Provider_Company__c = providerType[0].Clinic_Location__r.Provider_Company__c,
        Resource_Category__c = providerType[0].Resource_Category__c,
        Appointment_Type__c = appointmentTypeName,
        Appointed_Date__c = dob,
        Clinic_Location__c = providerType[0].Clinic_Location__c,
        Description__c = receivedData.get(4),
        Telehealth__c = receivedData.get(5),
        Clinic_Resource__c = doctors[0].Id,
        Resource_Type__c = providerType[0].Id,
        Room_Type__c = '--',
        Start_Time__c = startTime,
        End_Time__c = endTime,
        Meet_Link_Url__c = meetLink
        );
        
        // insert appointment;
        System.debug('Appointment Created: ' + appointment );
        return 'Appointment successfully created for patient: ' + patientAccount.Name;
        
    }
}