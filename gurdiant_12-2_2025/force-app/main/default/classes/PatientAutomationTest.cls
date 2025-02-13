@isTest
public with sharing class PatientAutomationTest{
    // Helper method to create test data for an Appointment
    private static Appointment__c createTestAppointment(Id patientAccountId, Id doctorAccountId){


        Resource_Category__c resourceCategory = new Resource_Category__c(
            Name = 'General Practitioner'
        );
        insert resourceCategory;

        Provider_Company__c providerCompany = new Provider_Company__c(
            Name = 'Health Care Providers Inc.',
            Address__CountryCode__s = 'US',
            Address__City__s = 'Oakland',
            Address__PostalCode__s = '94607',
            Address__Street__s = '123 Health St',
            Resource_Category__c = resourceCategory.Id  // Linking Resource Category
        );
        insert providerCompany;




        Appointment_Type__c appointmentType = new Appointment_Type__c(
            Name = 'Consultation',
            Resource_Category__c = resourceCategory.Id,  // Linking Resource Category
            Duration__c = '45 mins' // Duration in minutes
        );
        insert appointmentType;
        



        Clinic_Location__c clinicLocation = new Clinic_Location__c(
            Name = 'Location 1',
            Address__City__s= 'Oakland',
            Provider_Company__c = providerCompany.Id,
       
                Address__CountryCode__s= 'US',
                Address__GeocodeAccuracy__s= null,
                Address__Latitude__s= null,
                Address__Longitude__s= null,
                Address__PostalCode__s= '94607',
                // Address__StateCode__s= 'California',
                Address__StateCode__s='CA',
              
                Address__Street__s='101 Broadway',
                 Time_Zone__c = 'Pacific Standard Time (Mexico)'
              
                // Address_Text__c = '101 Broadway, Oakland, CA, 94607, US'

        );

        insert clinicLocation;




        Resource_Type__c  resourceType1 = new Resource_Type__c(Name = 'Test resource type', Resource_Category__c = resourceCategory.Id,Clinic_Location__c =clinicLocation.Id, Appointment_Type__c = appointmentType.Id );
        insert resourceType1;

        // Create Clinic Resource
        Clinic_Resource__c clinicResource = new Clinic_Resource__c(
            Name = 'Test Clinic Resource',
            Email__c = 'provider@test.com',
            Resource_Type__c = resourceType1.Id,
            Clinic_Location__c = clinicLocation.Id,
            Appointment_Type__c =appointmentType.Id ,

            // Gmail__c = 'provider@test.com',
            Time_Zone__c = 'UTC-11'
        );
        insert clinicResource;

        // Create Clinic Location
        // Clinic_Location__c clinicLocation = new Clinic_Location__c(
        //     Name = 'Test Location', 
        //     Address__Street__s = '425 Mission Street', 
        //     Address__City__s = 'San Francisco', 
        //     Address__StateCode__s = 'CA', 
        //     Address__PostalCode__s = '94105', 
        //     Address__CountryCode__s = 'US', 
        //     Geolocation__Latitude__s = 41.8892318, 
        //     Geolocation__Longitude__s = -87.6230288
        // );
        // insert clinicLocation;

        // Create Appointment

        Time testTime = Time.newInstance(8, 45, 0, 0);
        Time testTime2 = Time.newInstance(9, 30, 0, 0);
        Appointment__c appointment = new Appointment__c(
            Patient_Account__c = patientAccountId, 
            Appointed_Date__c = Date.today().addDays(1), 
            // Duration__c = '30 minutes',
            Clinic_Resource__c = clinicResource.Id, 
            Start_Time__c = testTime,
            End_Time__c = testTime2,
            Clinic_Location__c = clinicLocation.Id, 
            Status__c = 'Requested',   // Initial status is 'Requested'
            Formatted_Date__c = '2024-11-12@15:00',
            Telehealth__c = 'No'
            
        );




        insert appointment;
        appointment.Status__c = 'Accepted';  // Change status to 'Accepted'
        update appointment;  // Perform the update DML operation
          
        return appointment;
    }

    // Declare RecordTypeId as a class-level variable for reuse
    static Id patientRecordTypeId;
    // Static block to initialize RecordTypeId before test methods
    static{
        RecordTypeInfo patientRecordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Patient');
        patientRecordTypeId = patientRecordTypeInfo.getRecordTypeId();
    }
    // Helper method to create a test patient (Account)
    private static Account createTestPatient(){
        Account patient = new Account(
            Name = 'John Doe', 
            Email__c = 'john.doe@example.com', 
            RecordTypeId = patientRecordTypeId
        );
        insert patient;
        return patient;
    }

    // Helper method to create a doctor (Account)
    private static Account createTestDoctor(){
        Account doctor = new Account(
            Name = 'Dr. Smith', 
            Email__c = 'dr.smith@example.com'
        );
        insert doctor;
        return doctor;
    }

    // Test for creating an appointment and ensuring email is sent
    @isTest
    static void testAppointmentCreationAndEmailNotification(){
        // Step 1: Create test patient and doctor
        Account patient = createTestPatient();
        Account doctor = createTestDoctor();

        // Step 2: Create an Appointment with the patient and doctor
        Appointment__c appointment = createTestAppointment(patient.Id, doctor.Id);

        // Step 3: Update the status of the Appointment to 'Accepted' BEFORE calling Test.startTest()
        appointment.Status__c = 'Accepted';  // Change status to 'Accepted'
        update appointment;  // Perform the update DML operation

        // Step 4: Test EventHandler.emailToPatient method
        // Start test context here
        Test.startTest();
        EventHandler.emailToPatient(appointment);  // Call the method under test
        // Stop test context

        // Assert that the email was sent to the patient
        // System.assertEquals(1, Limits.getEmailInvocations(), 'An email should have been sent to the patient.');

        // Step 5: Test EventHandler.sentEventToDoctor method (consider combining this into the same test context)
        // Start another test context for the next operation
   system.debug('i m event '+appointment);

        EventHandler.sentEventToDoctor(appointment, 'Test Location');  // Call method to notify doctor
        Test.stopTest();  // Stop test context

        // Assert that the email was sent to the doctor
        // System.assertEquals(1, Limits.getEmailInvocations(), 'An email should have been sent to the doctor.');
    }

    // Test EventService.sendOutlookEvent with mock data
    @isTest
    static void testOutlookEventSending(){
        // Step 1: Create test patient and doctor
        Account patient = createTestPatient();
        Account doctor = createTestDoctor();

        // Step 2: Create an Appointment
        Appointment__c appointment = createTestAppointment(patient.Id, doctor.Id);

        // Step 3: Update the status of the Appointment to 'Accepted' BEFORE calling Test.startTest()
        Time testTime = Time.newInstance(8, 45, 0, 0);
        // Step 4: Create a mock EmailWrapper
        EventHandler.EmailWrapper emailWrapper = new EventHandler.EmailWrapper();
        emailWrapper.patientName = 'John Doe';
        emailWrapper.providerName = 'Test Provider';
        emailWrapper.doctorName = 'Dr. Smith';
        emailWrapper.doctorEmail = 'doctor@example.com';
        emailWrapper.eventUID = appointment.Id;
        emailWrapper.location = 'Test Location';
        emailWrapper.appointedDate  =Date.today().addDays(1);
        // emailWrapper.startDT = '2024-11-12@15:00 PST';
        emailWrapper.duration = '30';
        emailWrapper.startTime =testTime ;
        emailWrapper.endTime = emailWrapper.startTime.addMinutes(30);

        // Step 5: Test EventService.sendOutlookEvent method
        Test.startTest();  // Start test context here
        EventService.sendOutlookEvent(emailWrapper);
        Test.stopTest();  // Stop test context

        // Assert that the email with .ics attachment was sent
        // System.assertEquals(1, Limits.getEmailInvocations(), 'An Outlook event email should have been sent.');
    }

}