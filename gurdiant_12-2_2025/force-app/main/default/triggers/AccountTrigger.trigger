trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete) {
    System.debug('AccountTrigger');
    AccountTriggerHandler.execute(Trigger.old, Trigger.new);
}