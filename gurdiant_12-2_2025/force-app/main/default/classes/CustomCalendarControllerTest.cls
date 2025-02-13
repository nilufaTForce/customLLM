@isTest
public class CustomCalendarControllerTest {
    @isTest
    public static void CustomCalendarController() {
        Test.startTest();
        RecordType existingRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' LIMIT 1];

        RecordType appointmentRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Appointment' AND SObjectType = 'Appointment__c' LIMIT 1];
        RecordType unavailableRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Unavailable' AND SObjectType = 'Appointment__c' LIMIT 1];


        Resource_Category__c resourceCategory = DataFactoryTest.createResourceCategory(true);
        Account patient = DataFactoryTest.createPatient(true,'Orye');
        Provider_Company__c providerCompany = DataFactoryTest.createProviderCompany(true,resourceCategory);
        Clinic_Location__c clinicLocation = DataFactoryTest.createClinicLocation(true,providerCompany);
    
        Appointment_Type__c appointmentType = DataFactoryTest.createAppointmentType(true, resourceCategory);
        Resource_Type__c resourceType = DataFactoryTest.createResourceType(true,clinicLocation, appointmentType,resourceCategory);
        Clinic_Resource__c clinicResource = DataFactoryTest.createClinicResource(true,clinicLocation, resourceType, appointmentType);
        Availability__c availability = DataFactoryTest.createAvailability(true,clinicResource);
        Appointment__c appointment = DataFactoryTest.createAppointment(true,clinicResource, providerCompany, clinicLocation,patient);

        String jsonData = JSON.serialize(new Map<String, Object>{
            'event_Type' => 'Appointment',
            'Patient_Account__c' => patient.Id,
            'Provider_Company__c' => providerCompany.Id,
            'Resource_Category__c' => resourceCategory.Id,
            'Appointment_Type__c' =>appointmentType.Id ,
            'Appointed_Date__c' => Date.today(),
      
            'Clinic_Location__c' => clinicLocation.Id,
            'Description__c' => 'Test Description',
            'Telehealth__c' => 'No',
            'Clinic_Resource__c' => clinicResource.Id,
        
            'Resource_Type__c' => resourceType.Id,
            'Room_Type__c' => 'One Gen Room',
            'Start_Time__c' => '09:00',
            'End_Time__c' => '10:00'

        });


        List<Clinic_Resource__c> providerList = new List<Clinic_Resource__c> {clinicResource};

        String result = CustomCalendarController.getPatientAppointments('testRand');
        String recordTypeName = CustomCalendarController.getRecordTypeNameById(existingRecordType.Id);
        List<Provider_Company__c> prov = CustomCalendarController.getAllCompanyProviders();
        List<Clinic_Location__c> clinics = CustomCalendarController.getClinicLocations();
        String createApp = CustomCalendarController.createAppointment(jsonData);
        CustomCalendarController.notifyCancelToPatient(appointment, 1); // Status = Cancelled
        CustomCalendarController.notifyCancelToPatient(appointment, 2); // Status = Accepted
        CustomCalendarController.getAllCareCategories('t');
        CustomCalendarController.getAllAffiliatedGrps('t');
        CustomCalendarController.getAllAvailabilities('t');
        CustomCalendarController.getAllProviderTypes('t');
        CustomCalendarController.getAllAppTypes('t');
        CustomCalendarController.getAllGrpLocations('t');
        CustomCalendarController.filterCareCat('t');
        CustomCalendarController.getAllProviders('t');
        CustomCalendarController.getAvailableProviders(Date.today(),'',providerList);
        CustomCalendarController.getAvailableProviders(Date.today(),'12:00 AM',providerList);
        // insert resourceCategory;
        // insert resourceCategory;
        List<String>  av =  CustomCalendarController.getAvailableAppointmentSlots(resourceType.Id,'30 min',clinicLocation.Id,resourceCategory.Id,Date.today(), clinicResource.Id);
        List<String>  av1 =  CustomCalendarController.getAvailableAppointmentSlots(resourceType.Id,'',clinicLocation.Id,resourceCategory.Id,Date.today(), clinicResource.Id);
        List<String>  av2 =  CustomCalendarController.getAvailableAppointmentSlots('','30 min',clinicLocation.Id,resourceCategory.Id,Date.today(), clinicResource.Id);

        Test.stopTest();
    }
}