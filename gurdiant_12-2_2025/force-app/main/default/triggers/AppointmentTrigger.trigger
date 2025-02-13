trigger AppointmentTrigger on Appointment__c (before insert, after insert, before update, after update, before delete, after delete) {
    System.debug('AppointmentTrigger Execution Started');
    AppointmentTriggerHandler.execute(Trigger.old, Trigger.new);
}