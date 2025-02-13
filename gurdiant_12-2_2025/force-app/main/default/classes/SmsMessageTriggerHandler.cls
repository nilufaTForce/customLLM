public with sharing class SmsMessageTriggerHandler {
    interface HandleTrigger{
        void handle(SMS_Text__c [] oldSMS, SMS_Text__c[] newSMS);
    }
    
    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };
    public static Boolean systemUpdate = false;
    public static void execute(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldSMS, newSMS);
        }
    }
    class BeforeInsert implements HandleTrigger{
        public void handle(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){
            One_Proma.createPatient(newSMS[0]);
        }
    }
    class AfterInsert implements HandleTrigger{
        public void handle(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){
            List<SMS_Text__c> smsToUpdate = new List<SMS_Text__c>();
            List<SMS_Text__c> sms1 = new List<SMS_Text__c>();
            for(Integer i=0; i < newSMS.size(); i++){
                 Integer temp = 0;
                if (newSMS[i].Message_Serial__c == null) {
                    try {
                        // Query SMS_Text__c records for the current phone number in descending order
                        sms1 = [
                            SELECT Id, Message_Serial__c 
                            FROM SMS_Text__c 
                            WHERE Phone__c = :newSMS[i].Phone__c 
                            AND Message_Serial__c != null  // Ensure only records with Message_Serial__c are included
                            ORDER BY Message_Serial__c DESC
                        ];
            
                        System.debug('SMS_Text__c message serial value' + sms1[0].Message_Serial__c.intValue());
                        // Check if any records were returned
                        if (!sms1.isEmpty()) {
                            temp = sms1[0].Message_Serial__c.intValue(); // Assign the value to temp
                        }
                    } catch (Exception e) {
                        // Handle the exception, log it or take appropriate action
                        System.debug('An error occurred: ' + e.getMessage());
                        // Optionally, you can set temp to a specific value or leave it as default
                    }
                }
                if(newSMS[i].Sender__c == 'From Patient') {
                    if(temp == 9) {
                        Two_Himel.createAppointmentThroughChat(newSMS[i].Phone__c);
                    } else if (temp == 0) {
                        //name validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 1) {
                        //Date of Birth validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 2) {
                        //Gender validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 3) {
                        //Provider Type validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 4) {
                        //telehealth validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 5) {
                        //address validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 6) {
                        //date validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 7) {
                        //time validation
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    } else if (temp == 8) {
                        //email validation and do Two_Himel.createAppointmentThroughChat(newSMS[0].Phone__c);
                        SMS_Text__c sms = new SMS_Text__c(
                            Id = newSMS[i].Id,
                        Message_Serial__c = temp + 1
                            );
                        smsToUpdate.add(sms);
                    }
                    if (!smsToUpdate.isEmpty()) {
                        update smsToUpdate;
                    }
                }
            }
        }
    }
    class AfterUpdate implements HandleTrigger{
        public void handle(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){
            for(Integer i=0; i < newSMS.size(); i++){
                if(newSMS[i].Sender__c == 'From Patient') {
                    if(newSMS[i].Message_Serial__c == 9) {
                        Two_Himel.createAppointmentThroughChat(newSMS[i].Phone__c);
                    }
                }
            }
        }
    }
    class BeforeUpdate implements HandleTrigger{
        public void handle(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){}
    }
    class BeforeDelete implements HandleTrigger{
        public void handle(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){}
    }
    class AfterDelete implements HandleTrigger{
        public void handle(SMS_Text__c[] oldSMS, SMS_Text__c[] newSMS){}
    }
    
    
    
    
    
    
    
}