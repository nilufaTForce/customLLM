public class OutlookSubscribeQueueable implements Queueable, Database.AllowsCallouts{
    private String renew;
    public OutlookSubscribeQueueable(String renew){
        this.renew = renew;
    }

    // Execute method to make the API call
    public void execute(QueueableContext context){

        List<Outlook_Subscribe__c> osList = [SELECT Id
                                   FROM Outlook_Subscribe__c
                                   WHERE Expiration_Date__c <= TODAY];

        for (Outlook_Subscribe__c os : osList) {
            RefreshTokenService.renewRefreshToken(os.Id);
            OutlookRenewSubscription.renewOutlookSubscription(os.Id);
         
        }

      
    }

}