@RestResource(urlMapping='/createEvent')
global with sharing class EventCreator {
    @HttpPost
    global static void createEvent(DateTime dateAndTime, String lastName, Boolean fromOutlook) {

        if (!fromOutlook) {
            return;
        }
        // Create a new Appointment__c
        Appointment__c newAppointment = new Appointment__c();
    
        Id leadID = null;
        // Id leadID = AppointmentHandler.createLead(lastName,dateAndTime );
        //newAppointment.Date_and_Time_Temp__c = dateAndTime; // Set Date and Time
        newAppointment.Patient__c = leadID; // Set the Patient__c field
        newAppointment.Clinic_Location__c = 'a1OWr000000NSgLMAW'; // Static Clinic Location ID

        try {
            // Insert the appointment
            insert newAppointment;
            // return newAppointment.Id; // Return the ID of the created appointment
        } catch (Exception e) {
            // Handle exceptions
            // return 'Error: ' + e.getMessage();
        }
    }
}