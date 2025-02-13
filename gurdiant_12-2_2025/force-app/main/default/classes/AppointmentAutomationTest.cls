@IsTest
public class AppointmentAutomationTest {

    public class MyHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTPResponse object
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            // Set the mock response body with the detailed JSON response
            res.setBody('{"destination_addresses": ["Destination Address 1", "Destination Address 2"], "origin_addresses": ["Origin Address"], "rows": [{"elements": [{"distance": {"text": "5.4 km", "value": 5400}, "duration": {"text": "12 mins", "value": 720}, "status": "OK"}, {"distance": {"text": "3.2 km", "value": 3200}, "duration": {"text": "7 mins", "value": 420}, "status": "OK"}]}], "status": "OK"}');
            
            System.debug('Detailed mock response body set successfully.');
            return res;
        }
    }
    


    // Test method to verify Appointment creation and handle HTTP callout
    @IsTest
    static void testAppointmentCreation() {
          // Create Clinic_Resource__c record
           // Create Resource Category record
           Resource_Category__c resourceCategory = new Resource_Category__c(
            Name = 'General Practitioner'
        );
         insert resourceCategory;
        Resource_Category__c resourceCategory2 = new Resource_Category__c(
            Name = 'Generall Practitioner'
        );
        insert resourceCategory2;
           Appointment_Type__c appointmentType = new Appointment_Type__c(
            Name = 'Consultation',
            Resource_Category__c = resourceCategory.Id,  // Linking Resource Category
            Duration__c = '45 mins' // Duration in minutes
        );
        insert appointmentType;
        Appointment_Type__c appointmentType2 = new Appointment_Type__c(
            Name = 'sonsultation',
            Resource_Category__c = resourceCategory2.Id,  // Linking Resource Category
            Duration__c = '45 mins' // Duration in minutes
        );
        insert appointmentType2;
        Provider_Company__c providerCompany = new Provider_Company__c(
            Name = 'Health Care Providers Inc.',
            Address__CountryCode__s = 'US',
            Address__City__s = 'Oakland',
            Address__PostalCode__s = '94607',
            Address__Street__s = '123 Health St',
            Resource_Category__c = resourceCategory.Id  // Linking Resource Category
        );
        insert providerCompany;
        Provider_Company__c providerCompany2 = new Provider_Company__c(
            Name = 'Health Care Providers Incc.',
            Address__CountryCode__s = 'US',
            Address__City__s = 'Oakland',
            Address__PostalCode__s = '94607',
            Address__Street__s = '123 Health St',
            Resource_Category__c = resourceCategory2.Id  // Linking Resource Category
        );
        insert providerCompany2;
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
        
        Resource_Type__c resourceType = new Resource_Type__c(
            Name = 'General Practitioner',
            Clinic_Location__c = clinicLocation.id,  // Assuming this is not mandatory for now
            Appointment_Type__c = appointmentType.Id,  // Linking Appointment Type
            Resource_Category__c = resourceCategory.Id  // Linking Resource Category
        );
        insert resourceType;
        Clinic_Location__c clinicLocation2 = new Clinic_Location__c(
            Name = 'Location 2',
            Provider_Company__c = providerCompany2.Id ,
            Time_Zone__c = 'UTC-02'
            // Resource_Type__c=resourceType2.id
 
        );
        insert clinicLocation2;
        Resource_Type__c resourceType2 = new Resource_Type__c(
            Name = 'General Practitioner',
            Clinic_Location__c = clinicLocation2.id,  // Assuming this is not mandatory for now
            Appointment_Type__c = appointmentType2.Id,  // Linking Appointment Type
            Resource_Category__c = resourceCategory2.Id  // Linking Resource Category
        );
        insert resourceType2;
         clinicLocation2.Resource_Type__c=resourceType2.id;
 
     
        update clinicLocation2;

      
     

        Outlook_Subscribe__c os = new Outlook_Subscribe__c(

        );

           Clinic_Resource__c clinicResource = new Clinic_Resource__c(
            Name = 'Resource 1',
            Email__c = 'support@flowr.life',
            Clinic_Location__c = clinicLocation2.Id,
            Appointment_Type__c = appointmentType2.Id,
            Resource_Type__c = resourceType2.id,
            // Gmail__c = 'araf@gmail.com',
            Time_Zone__c = 'Pacific Standard Time'
        );
        insert clinicResource;
    
     
        DateTime app1Start = DateTime.newInstance(2024, 12, 30, 8, 0, 0); // 8:00 AM
        DateTime app2Start = DateTime.newInstance(2024, 12, 30, 10, 0, 0); // 10:00 AM (triggered appointment)
        DateTime app3Start = DateTime.newInstance(2024, 12, 30, 12, 0, 0); // 12:00 PM

     

        // Clinic_Location__c clinicLocation2 = new Clinic_Location__c(
        //     Name = 'Location 2',
        //     Provider_Company__c = providerCompany.Id ,
        //     Time_Zone__c = 'UTC-02',
        //     Resource_Type__c=resourceType.id
 
        // );

        // insert clinicLocation2;
      

        Clinic_Resource__c clinicResource1 = new Clinic_Resource__c(
            Name = 'Resource 1',
            Email__c = 'resource1@example.com',
            Clinic_Location__c = clinicLocation2.Id,
            Appointment_Type__c =appointmentType2.Id,
            Resource_Type__c =resourceType2.id,
            // Gmail__c = 'araf@gmail.com',
            Time_Zone__c= 'Hawaiian Standard Time'
 
        );
        insert clinicResource1;
        // Create Account record (required for lookup)
        Account account = new Account(
            Name = 'Test Account',
            RecordTypeId = '012Wr000000wfNlIAI', // Ensure this is a valid Record Type ID in the test environment
            Email__c = 'proma.tforce@gmail.com'
           
        );
        insert account;
        

        Account account1 = new Account(
            Name = 'Test1 Account',
            RecordTypeId = '012Wr000000wfNlIAI', // Ensure this is a valid Record Type ID in the test environment
            Email__c = 'proma1.tforce@gmail.com'
        );
        insert account1;

        // Create Appointment with required fields and lookup relationships
        Appointment__c appointment = new Appointment__c(
            Appointed_Date__c = Date.newInstance(2024, 12, 30),
            Status__c = 'Requested',
            Clinic_Resource__c = clinicResource.Id,
            Clinic_Location__c = clinicLocation.Id,
            Patient_Account__c = account.Id,
             test__c = '60 minutes',
             Appointment_Type__c = appointmentType.Id, 
             Telehealth__c = 'No',
           
            Provider_Company__c = providerCompany.Id,
            Start_Time__c = Time.newInstance(8, 0, 0, 0),  // Set start time to 8:00 AM
            End_Time__c = Time.newInstance(8, 30, 0, 0) // 14:30:00 (2:30 PM)
            
        );
        insert appointment;
        Appointment__c appointmentc = new Appointment__c(
            Appointed_Date__c = Date.newInstance(2024, 12, 28),
            Date_and_Time__c=DateTime.newInstance(Date.newInstance(2024, 12, 28), Time.newInstance(8, 0, 0, 0)),
            Status__c = 'Requested',
            Clinic_Resource__c = clinicResource.Id,
            Clinic_Location__c = clinicLocation.Id,
            Patient_Account__c = account.Id,
             test__c = '60 minutes',
             Appointment_Type__c = appointmentType.Id, 
             Event_ID__c=appointment.Event_ID__c,
             Telehealth__c = 'No',
            Provider_Company__c = providerCompany.Id,
            Start_Time__c = Time.newInstance(8, 0, 0, 0),  // Set start time to 8:00 AM
            End_Time__c = Time.newInstance(9,0 , 0, 0) // 14:30:00 (2:30 PM)
            
        );
        insert appointmentc;
       
        Appointment__c appointmentFuture = new Appointment__c(
            Appointed_Date__c = Date.newInstance(2024, 12, 29), 
           // Appointment date (after triggered time)
            Status__c = 'Requested',
            Clinic_Resource__c = clinicResource.Id,
            Clinic_Location__c = clinicLocation.Id,
            Patient_Account__c = account1.Id,
            test__c = '30 minutes',
            Telehealth__c = 'No',
            Appointment_Type__c = appointmentType.Id,
            Provider_Company__c = providerCompany.Id,
            Start_Time__c = Time.newInstance(10, 0, 0, 0),  // Appointment start time 10:00 AM
            End_Time__c = Time.newInstance(10, 30, 0, 0)  // Appointment end time 10:30 AM
        );
        insert appointmentFuture;
        Appointment__c appointmentFuture1 = new Appointment__c(
            Appointed_Date__c = Date.newInstance(2024, 12, 29), 
           // Appointment date (after triggered time)
            Status__c = 'Requested',
            Clinic_Resource__c = clinicResource.Id,
            Clinic_Location__c = clinicLocation.Id,
            Telehealth__c = 'No',
            Patient_Account__c = account1.Id,
            test__c = '30 minutes',
            Appointment_Type__c = appointmentType.Id,
            Provider_Company__c = providerCompany.Id,
            Start_Time__c = Time.newInstance(10, 0, 0, 0),  // Appointment start time 10:00 AM
            End_Time__c = Time.newInstance(10, 30, 0, 0)  // Appointment end time 10:30 AM
        );
        insert appointmentFuture1;
        appointmentFuture1.Status__c= 'Cancelled';
        update appointmentFuture1;
       
       

        Appointment__c appointment1 = new Appointment__c(
            Appointed_Date__c = Date.newInstance(2024, 5, 30),
         
            Status__c = 'Requested',
            Clinic_Resource__c =  clinicResource.Id,
            Clinic_Location__c = clinicLocation.Id,
            Patient_Account__c = account1.Id,
            test__c = '15 minutes',
            Appointment_Type__c = appointmentType.Id, 
            Telehealth__c = 'No',
            Provider_Company__c = providerCompany.Id,
            Start_Time__c = Time.newInstance(10, 0, 0, 0),  // Set start time to 8:00 AM
            End_Time__c = Time.newInstance(10, 30, 0, 0) // 14:30:00 (2:30 PM)
        );
        insert appointment1;
       
        
        Appointment__c appointment2 = new Appointment__c(
            Appointed_Date__c = Date.newInstance(2024, 13, 28),
            
            Status__c = 'Requested',
            Clinic_Resource__c =  clinicResource.Id,
            Clinic_Location__c = clinicLocation.Id,
            Patient_Account__c = account1.Id,
            test__c = '30 minutes',
            Appointment_Type__c = appointmentType.Id, 
            Telehealth__c = 'No',
         
            Provider_Company__c = providerCompany.Id ,
            Start_Time__c =  app2Start.time(),  // Set start time to 8:00 AM
            End_Time__c =  app2Start.addMinutes(30).time()// 14:30:00 (2:30 PM)
        );

        insert appointment2;
       
        List<Clinic_Resource__c> clinicResources = new List<Clinic_Resource__c>();
        clinicResources.add(clinicResource);
        clinicResources.add(clinicResource1);
            
        DistanceService.getClinicLocationNameById(clinicLocation.Id);
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock());
        Test.startTest();
        AppointmentHandler.assignClinicLocation(appointment);
       
        AppointmentHandler.duplicateAppointment(appointment);
        AppointmentHandler.assignRoundRobin(appointment);
        AppointmentHandler.notifyAppToPat(appointment1);
        AppointmentHandler.formatToIntegerMinute('3 hours');
     
        AppointmentHandler.formatToIntegerMinute('45'); 
        DateTime triggeredAppTime = DateTime.newInstance(2024, 12, 30, 10, 0, 0); 
        DateTime triggeredAppTime2 =  DateTime.newInstance(2024, 12, 30, 9, 30, 0);
        DateTime triggeredAppTime3 =  DateTime.newInstance(2024, 12, 27, 9, 30, 0);
        String duration = '30 hours'; 
        // AppointmentHandler.isDoctorAvailable(app2Start, '30 minutes', clinicResource.Id, clinicLocation.Id); // This is where we test
        AppointmentHandler.assignWithoutRoundRobin( appointment2, clinicResources);   
         
        AppointmentHandler.isDoctorAvailable(triggeredAppTime, '45 hours', appointment2.Clinic_Resource__c, appointment2.Clinic_Location__c);   
        AppointmentHandler.isDoctorAvailable(triggeredAppTime, duration, appointment2.Clinic_Resource__c, appointment2.Clinic_Location__c);   
        AppointmentHandler.isDoctorAvailable(triggeredAppTime, duration, appointmentc.Clinic_Resource__c, appointmentc.Clinic_Location__c); 

        AppointmentHandler.isDoctorAvailable(triggeredAppTime2, duration, appointmentc.Clinic_Resource__c, appointmentc.Clinic_Location__c); 
        AppointmentHandler.isDoctorAvailable(triggeredAppTime3, duration, appointmentc.Clinic_Resource__c, appointmentc.Clinic_Location__c); 
        AppointmentHandler.isDoctorAvailable(triggeredAppTime2, '30 hours', appointmentFuture.Clinic_Resource__c, appointmentFuture.Clinic_Location__c);  
      
       
       
       
        Test.stopTest(); }
    }
       


        // List<Appointment__c> appointments = new List<Appointment__c>();

        // // appointments.add(new Appointment__c(
        // //     Appointed_Date__c = Date.newInstance(2024, 11, 30,),
        // //     Status__c = 'Requested',
        // //     // Clinic_Resource__c = clinicResource.Id,
        // //     Clinic_Location__c = clinicLocation2.Id,
        // //     Patient_Account__c = account.Id,
        // //     Duration__c = '30 minutes'
        // // ));

        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 14),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
          
        //     Provider_Company__c = providerCompany.Id,
        //     Start_Time__c = Time.newInstance(17, 0, 0, 0),  // Set start time to 8:00 AM
        //     End_Time__c = Time.newInstance(17, 30, 0, 0) // 14:30:00 (2:30 PM)
        // ));
        
        // // Appointment overlapping with clinic start (e.g., 8:00 AM)
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 15),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '15 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id, 
        //     Start_Time__c = Time.newInstance(1, 0, 0, 0),  // Set start time to 8:00 AM
        //     End_Time__c = Time.newInstance(1, 30, 0, 0) // 14:30:00 (2:30 PM)
        // ));

        // // Appointment fully within an hour (e.g., 9:00 AM - 9:30 AM)
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 16),
        //     Status__c = 'Requested',
        //     Start_Time__c = Time.newInstance(4, 0, 0, 0),  // Set start time to 8:00 AM
        //     End_Time__c = Time.newInstance(4, 30, 0, 0), // 14:30:00 (2:30 PM)

        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id 
        // ));
        
        // // Appointment spanning across two hours (e.g., 10:30 AM - 11:30 AM)
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 17 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '60 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id,
        //     Start_Time__c = Time.newInstance(9, 0, 0, 0),  // Set start time to 9:00 AM
        //     End_Time__c = Time.newInstance(9, 15, 0, 0)  
        // ));
        
        // // Appointment at the end of the day (e.g., 7:30 PM - 8:00 PM)
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 18 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(10, 30, 0, 0),  // Set start time to 10:30 AM
        //     End_Time__c = Time.newInstance(11, 0, 0, 0)   // End time 30 minutes later
        // ));

        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 19 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
          
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(14, 30, 0, 0),  // Set start time to 2:30 PM
        //     End_Time__c = Time.newInstance(15, 0, 0, 0)   // End time 30 minutes later
        // ));
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 20),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
          
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(16, 45, 0, 0),  // Set start time to 4:45 PM
        //     End_Time__c = Time.newInstance(17, 0, 0, 0)   // End time 15 minutes later
        // ));

        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 21),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
          
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // // Booked start at '15' minutes past the hour
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 22 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // // Booked start at '30' minutes past the hour
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 23 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '30 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // // Booked start at '45' minutes past the hour
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 14 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '15 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
         
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));

        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 20 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '15 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 20 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     Appointment_Type__c = appointmentType.Id, 
        //     test__c = '15 minutes',
          
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 11, 20 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '15 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));

        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 12, 1 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '15 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
           
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 12, 2 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     Appointment_Type__c = appointmentType.Id, 
        //     test__c = '15 minutes',
          
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));
        // appointments.add(new Appointment__c(
        //     Appointed_Date__c = Date.newInstance(2024, 12, 3 ),
        //     Status__c = 'Requested',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     test__c = '15 minutes',
        //     Appointment_Type__c = appointmentType.Id, 
          
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // ));

        // appointments.add(new Appointment__c(
        //     // Appointed_Date__c = Date.newInstance(2024, 12, 3,            Appointed_Date__c = System.now().ad),
        //     Status__c = 'Accepted',
        //     Clinic_Resource__c = clinicResource.Id,
        //     Clinic_Location__c = clinicLocation.Id,
        //     Patient_Account__c = account.Id,
        //     Appointment_Type__c = appointmentType.Id, 
        //     test__c = '15 minutes',
        
        //     Provider_Company__c = providerCompany.Id ,
        //     Start_Time__c = Time.newInstance(18, 0, 0, 0),  // Set start time to 6:00 PM
        //     End_Time__c = Time.newInstance(18, 15, 0, 0)   // End time 15 minutes later
        // )
        // );


        // // Insert the test appointments
        // insert appointments;


        // AppointmentHandler.getAvailableAppointmentSlots(clinicLocation.Id);
      
        // Appointment__c[] appointments = //     SELECT Id, Name, Appointed_Date__c, , 
        //            Clinic_Resource__c, Clinic_Location__c, 
        //            Patient_Account__c
        //     FROM Appointment__c
        // ];