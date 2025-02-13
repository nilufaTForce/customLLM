public with sharing class PatientFormController {
    @AuraEnabled
    public static Id createAppointment(String patientName, String email, String gender, Date dob, DateTime appointmentDateTime, Id clinicLocationId, String duration){
        // Step 1: Create the Account record
        Id accountId = createAccount(patientName, email, gender, dob);

        // Step 2: Create a Clinic_Location__c record and associate it with the Account
        Appointment__c newApp = new Appointment__c();
        newApp.Patient_Account__c = accountId;  // Assign the newly created Account to this field
        newApp.Clinic_Location__c = clinicLocationId;  // Set the passed clinic location Id
        // newApp.Date_and_Time_Temp__c = appointmentDateTime;  // Set the Appointment Date and Time
        newApp.Status__c = 'Accepted';  // Set the status to 'Requested'
        // newApp.Duration__c = duration;

        try{
            // Insert the Appointment record
            insert newApp;
        } catch (DmlException e){

            try{

                if (accountId != null){
                    delete [SELECT Id
                            FROM Account
                            WHERE Id = :accountId];
                }
            } catch (DmlException deleteEx){

                throw new AuraHandledException('Error deleting Account after Appointment failure: ' + deleteEx.getMessage());
            }


            throw new AuraHandledException('Error creating Appointment: ' + e.getMessage());
        }

        // Return the Id of the newly created Clinic_Location
        return newApp.Id;
    }

    public static Id createAccount(String patientName, String email, String gender, Date dob){
        RecordTypeInfo patientRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient');
        Id patientRecordTypeId = patientRecordTypeInfo.getRecordTypeId();


        List<Account> existingAccounts = [SELECT Id
                                          FROM Account
                                          WHERE Email__c = :email AND Date_Of_Birth__c = :dob AND RecordTypeId = :patientRecordTypeId
                                          LIMIT 1];

        if (!existingAccounts.isEmpty()){
            // If an existing account is found, return the existing account's Id
            return existingAccounts[0].Id;
        }
        List<Account> AccountToInsert = new List<Account>();


        Account newAcc = new Account();
        newAcc.Name = patientName; // Set Status picklist value to "New"
        newAcc.Date_Of_Birth__c = dob; // Set Appointment_Date_and_Time_Temp__c
        newAcc.RecordTypeId = patientRecordTypeId; // Set RecordTypeId
        newAcc.Email__c = email;
        newAcc.Gender__c = gender;

        Database.insert (newAcc, true);
        return newAcc.Id;
    }

    public static void formatDateTime(Appointment__c app){
        /*DateTime dt = app.Date_and_Time_Temp__c;

         String timeFormat2 = dt.format('hh:mm a');
         String timeFormat = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
         String dayOfWeek = dt.format('EEEE');  // Thursday
         Integer dayOfMonth = dt.day();        // 21
         String month = dt.format('MMM');      // Oct
         Integer year = dt.year();             // 2024

         String daySuffix;
         if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31) {
         daySuffix = 'st';
         } else if (dayOfMonth == 2 || dayOfMonth == 22) {
         daySuffix = 'nd';
         } else if (dayOfMonth == 3 || dayOfMonth == 23) {
         daySuffix = 'rd';
         } else {
         daySuffix = 'th';
         }

         String formattedDate = timeFormat2 + '@' + dayOfWeek + ', ' + dayOfMonth + daySuffix + '-' + month + '-' + year;
         app.Format_Date_For_Email__c = timeFormat;
         app.Formatted_Date__c = formattedDate;
         */
    }
}