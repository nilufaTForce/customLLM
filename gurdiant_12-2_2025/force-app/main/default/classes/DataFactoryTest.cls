@isTest
public with sharing class DataFactoryTest {
    public static Provider_Company__c createProviderCompany(Boolean insertRecord, Resource_Category__c resourceCategory) {
        // Resource_Category__c resourceCategory = createResourceCategory(true);

        Provider_Company__c providerCompany = new Provider_Company__c(
            Name = 'Health Care Providers Inc.',
            Address__CountryCode__s = 'US',
            Address__City__s = 'Oakland',
            Address__PostalCode__s = '94607',
            Address__Street__s = '123 Health St',
            Resource_Category__c = resourceCategory.Id
        );
        if(insertRecord){
            insert providerCompany;
        }

        return providerCompany;
    }
    
    public static Account createPatient(Boolean insertRecord, String accountName) {

  
   Account patient = new Account(Name = accountName);
        

   if (insertRecord) {
       insert patient;
   }
   

   return patient;
    }


    public static Clinic_Location__c createClinicLocation(Boolean insertRecord, Provider_Company__c providerCompany) {
        Clinic_Location__c clinicLocation = new Clinic_Location__c(
            Name = 'Location 1',
            Address__City__s = 'Oakland',
            Provider_Company__c = providerCompany.Id,
            Address__CountryCode__s = 'US',
            Address__PostalCode__s = '94607',
            Address__StateCode__s = 'CA',
            Address__Street__s = '101 Broadway',
            Time_Zone__c = 'Pacific Standard Time (Mexico)'
        );
        if(insertRecord){

        insert clinicLocation;
        }
        return clinicLocation;
    }

    public static Appointment_Type__c createAppointmentType(Boolean insertRecord, Resource_Category__c resourceCategory) {
        Appointment_Type__c appointmentType = new Appointment_Type__c(
            Name = 'Consultation',
            Resource_Category__c = resourceCategory.Id,
            Duration__c = '45 mins'
        );
        insert appointmentType;
        return appointmentType;
    }

    public static Resource_Type__c createResourceType(Boolean insertRecord, Clinic_Location__c clinicLocation, Appointment_Type__c appointmentType,Resource_Category__c resourceCatagory) {
        Resource_Type__c resourceType = new Resource_Type__c(
            Name = 'Test resource type',
            Resource_Category__c =resourceCatagory.Id,
            Clinic_Location__c = clinicLocation.Id,
            Appointment_Type__c = appointmentType.Id
        );
        if(insertRecord){
        insert resourceType;
        }
        return resourceType;
    }

    public static Clinic_Resource__c createClinicResource(Boolean insertRecord , Clinic_Location__c clinicLocation, Resource_Type__c resourceType, Appointment_Type__c appointmentType) {
        Clinic_Resource__c clinicResource = new Clinic_Resource__c(
            Name = 'Test Clinic Resource',
            Email__c = 'provider@test.com',
            Resource_Type__c = resourceType.Id,
            Clinic_Location__c = clinicLocation.Id,
            Appointment_Type__c = appointmentType.Id,
            Time_Zone__c = 'UTC-11'
            
        );
        if(insertRecord){
        insert clinicResource;
        }
        return clinicResource;
    }

    public static Availability__c createAvailability(Boolean insertRecord , Clinic_Resource__c clinicResource) {
        
        Date today = Date.today();
        Datetime todayDatetime = Datetime.newInstance(today.year(), today.month(), today.day());

        String dayOfWeek = todayDatetime.format('EEEE');

        Availability__c availability = new Availability__c(
            Clinic_Resource__c = clinicResource.Id,
            Day__c = dayOfWeek,
            Start_Shift__c = Time.newInstance(9, 0, 0, 0),
            End_Shift__c = Time.newInstance(11, 0, 0, 0)
        );
        if(insertRecord){
        insert availability;
        }
        return availability;
    }

    public static Appointment__c createAppointment(Boolean insertRecord , Clinic_Resource__c clinicResource, Provider_Company__c providerCompany, Clinic_Location__c clinicLocation, Account patient) {
        Appointment__c appointment = new Appointment__c(
            Appointed_Date__c = Date.today(),
            Start_Time__c = Time.newInstance(10, 30, 0, 0),
            Clinic_Resource__c = clinicResource.Id,
            Patient_Account__c = patient.Id,
            Provider_Company__c = providerCompany.Id,
            Clinic_Location__c = clinicLocation.Id,
            End_Time__c = Time.newInstance(11, 30, 0, 0)
        );
        if(insertRecord){
        insert appointment;
        }
        return appointment;
    }

    public static Resource_Category__c createResourceCategory(Boolean insertRecord) {
        Resource_Category__c resourceCategory = new Resource_Category__c(
            Name = 'Test Resource Category'
        );
        if(insertRecord){
        insert resourceCategory;
        }
        return resourceCategory;
    }
}