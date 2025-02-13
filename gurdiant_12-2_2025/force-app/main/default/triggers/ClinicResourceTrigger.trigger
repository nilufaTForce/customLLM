trigger ClinicResourceTrigger on Clinic_Resource__c(before insert, after insert, before update, after update, before delete, after delete ){
    ClinicResourceTriggerHandler.execute(Trigger.old, Trigger.new );
}