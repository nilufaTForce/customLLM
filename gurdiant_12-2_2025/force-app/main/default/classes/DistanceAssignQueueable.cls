public with sharing class DistanceAssignQueueable implements Queueable, Database.AllowsCallouts {
    
    private Id appointmentID;
    private String location;
    
    public DistanceAssignQueueable(Id appointmentID, String location) {
        this.appointmentID = appointmentID;
        this.location = location;
    }

    public void execute(QueueableContext context) {
        //
        Id appID = this.appointmentID;
        Appointment__c appointment = [SELECT Duration__c, Clinic_Location__r.Provider_Company__r.Name, Location_Text__c, Clinic_Location__c, From_Outlook__c, Appointed_Date__c, Formatted_Date__c,Start_Time__c,End_Time__c, Clinic_Resource__c, Patient_Text__c, Doctor_Text__c, Resource_Category__c FROM Appointment__c WHERE Id = :appID LIMIT 1];
        this.location = appointment.Location_Text__c;

        if (!String.isEmpty(this.location)) {
            Id clinicId = DistanceService.getClosestClinicLocationId(this.location, appointment.Resource_Category__c);
            appointment.Clinic_Location__c = clinicId;
            
            if (appointment.Clinic_Location__c != null) {
                Database.update(appointment, true);
            }
        }

        if (!appointment.From_Outlook__c) {
            EventHandler.sentEventToDoctor(appointment, this.location);
        }

    }
}