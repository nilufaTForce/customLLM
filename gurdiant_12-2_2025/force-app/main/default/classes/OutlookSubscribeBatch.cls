public class OutlookSubscribeBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Expiration_Date__c, Access_Token__c, Refresh_Token__c, User_ID__c FROM Outlook_Subscribe__c');
    }

    public void execute(Database.BatchableContext BC, List<Outlook_Subscribe__c> scope) {
        System.enqueueJob(new OutlookSubscribeQueueable('Start Renew'));
    }

    public void finish(Database.BatchableContext BC) {}
    public void execute(SchedulableContext SC) {
        OutlookSubscribeBatch batchJob = new OutlookSubscribeBatch();
        Database.executeBatch(batchJob, 200);
    }
    public static void runJob(){
        // Execute Schedule JOB
        String cronExpression = '0 35 10 * * ?'; // This will run at midnight every day
        System.schedule('Daily Outlook Subscribe Batch', cronExpression, new OutlookSubscribeBatch());
    }
}