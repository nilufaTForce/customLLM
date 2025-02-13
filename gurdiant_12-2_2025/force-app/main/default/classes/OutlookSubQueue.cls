public without sharing class OutlookSubQueue implements Queueable {
    
    private Outlook_Subscribe__c globarOS = new Outlook_Subscribe__c();

    SUbReturnType srt = new SUbReturnType();

    public OutlookSubQueue(List<Outlook_Subscribe__c> subscribeList) {
        //
    }

    // The execute method contains the code that runs asynchronously
    public void execute(QueueableContext context) {
        
        List <Outlook_Subscribe__c> osList = new List<Outlook_Subscribe__c>();
        SUbReturnType subObj;

        for (Outlook_Subscribe__c os : getAllSubcribers()) {
            RefreshTokenService.renewRefreshToken(os.Id);
            OutlookRenewSubscription.renewOutlookSubscription(os.Id);
            // this.globarOS = os;
            // os = this.globarOS;
            // osList.add(os);
            // this.globarOS = null;
        }

        // update osList;

        System.debug('Queueable job completed.');
    }



    private static Microsoft_Outlook_API__mdt getAPICreds(){
        return [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
    }

    private static List<Outlook_Subscribe__c> getAllSubcribers(){
        return [SELECT Id, Access_Token__c, Refresh_Token__c, Subscribe_ID__c, User_ID__c, Expiration_Date__c, Meta_Data__c
                                   FROM Outlook_Subscribe__c
                                   WHERE Expiration_Date__c = TODAY];
    }

    private class SUbReturnType{
        String subID;
        String accessToken;
        String expirationDate;
    }
}