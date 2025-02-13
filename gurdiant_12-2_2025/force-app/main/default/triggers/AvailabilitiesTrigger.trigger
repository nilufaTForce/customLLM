trigger AvailabilitiesTrigger on Availability__c (before insert, after insert, before update, after update, before delete, after delete) {
    System.debug('AvailabilitiesTrigger Execution Started');
    AvailabilitiesTriggerHandler.execute(Trigger.old, Trigger.new);
}