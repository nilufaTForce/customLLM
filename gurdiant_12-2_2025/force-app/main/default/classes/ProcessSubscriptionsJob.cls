public without sharing  class ProcessSubscriptionsJob implements Queueable {
    private String responseBody;
    private String accessToken;

    public ProcessSubscriptionsJob(String responseBody, String accessToken) {
        this.responseBody = responseBody;
        this.accessToken = accessToken;
    }

    public void execute(QueueableContext context) {
        try {
            Microsoft_Outlook_API__mdt cred = [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
            Base_Auth_Url__c
            FROM Microsoft_Outlook_API__mdt
            WHERE DeveloperName = 'Outlook_API_Settings'
            LIMIT 1];

         
            Map<String, Object> responseMap = ((Map<String, Object>) JSON.deserializeUntyped(responseBody));
            List<Object> subscriptions = ((List<Object>) responseMap.get('value'));

            //do not delete
            String targetNotificationUrl = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice';
           // String targetNotificationUrl =cred.Redirect_Url_Outlook__c;

            for (Object subscriptionObj : subscriptions) {
                Map<String, Object> subscription = (Map<String, Object>) subscriptionObj;
                String notificationUrl = (String) subscription.get('notificationUrl');

                if (targetNotificationUrl.equals(notificationUrl)) {
                    String subscriptionId = (String) subscription.get('id');
                    //do not delete
                    //String deleteUrl = 'https://graph.microsoft.com/v1.0/subscriptions/' + subscriptionId;
                    String deleteUrl = cred.Outlook_Subscription_Api__c +'/' + subscriptionId;
                    System.enqueueJob(new DeleteSubscriptionJob(deleteUrl, accessToken));
                    break;
                }
            }
        } catch (Exception e) {
            System.debug('Error processing subscriptions: ' + e.getMessage());
        }
    }
}