trigger SMSTextTrigger on SMS_Text__c (after insert, after update) {
    SmsMessageTriggerHandler.execute(Trigger.old, Trigger.new);
}