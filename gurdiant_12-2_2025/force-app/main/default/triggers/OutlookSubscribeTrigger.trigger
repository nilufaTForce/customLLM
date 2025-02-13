trigger OutlookSubscribeTrigger on 	Outlook_Subscribe__c (before insert, after insert, before update, after update, before delete, after delete) {
    OutlookSubscribeTriggerHandler.execute(Trigger.old, Trigger.new);
}