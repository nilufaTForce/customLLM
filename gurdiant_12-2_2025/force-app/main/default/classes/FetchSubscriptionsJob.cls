public without sharing  class FetchSubscriptionsJob implements Queueable, Database.AllowsCallouts {
    private Outlook_Subscribe__c outlookSubscribe;

    public FetchSubscriptionsJob(Outlook_Subscribe__c outlookSubscribe) {
        this.outlookSubscribe = outlookSubscribe;
    }

    public void execute(QueueableContext context) {
        Microsoft_Outlook_API__mdt apiCreds =[SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
        Base_Auth_Url__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];

        //do not delete
        String subscriptionsUrl = apiCreds.Outlook_Subscription_Api__c;
        //do not delete
        //String subscriptionsUrl = 'https://graph.microsoft.com/v1.0/subscriptions/';
        String accessToken = outlookSubscribe.Access_Token__c;

        if (String.isNotEmpty(accessToken)) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(subscriptionsUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'application/json');

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                System.enqueueJob(new ProcessSubscriptionsJob(res.getBody(), accessToken));
            } else {
                System.debug('Error fetching subscriptions: ' + res.getBody());
            }
        } else {
            System.debug('No access token available.');
        }
    }
}