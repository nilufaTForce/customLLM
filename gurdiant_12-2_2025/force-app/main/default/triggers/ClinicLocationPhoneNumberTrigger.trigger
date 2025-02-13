trigger ClinicLocationPhoneNumberTrigger on Clinic_Location__c (before insert, before update) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        PhoneNumberValidationHandler.validatePhoneNumbers(Trigger.new);
    }
}