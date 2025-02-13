trigger ClinicLocationTrigger on Clinic_Location__c (before insert, after insert, before update, after update, before delete, after delete) {
    ClinicLocationTriggerHandler.execute(Trigger.old, Trigger.new);
}