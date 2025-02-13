public without sharing  class DeleteOutlookSubscribeJob implements Queueable, Database.AllowsCallouts {
    private String accessToken;
    private Outlook_Subscribe__c os;

   
    public DeleteOutlookSubscribeJob(Outlook_Subscribe__c os) {
        this.os = os;
    }

    public void execute(QueueableContext context) {
        
        System.debug('id-->'+ os);
        Outlook_Subscribe__c updatedOS1 = new Outlook_Subscribe__c();

        updatedOS1.Refresh_Token__c=  os.Refresh_Token__c;
        updatedOS1.Access_Token__c= os.Access_Token__c;

      
        Outlook_Subscribe__c updatedOS = RefreshTokenService.getRefreshToken(updatedOS1);
        System.debug('Updated Outlook_Subscribe__c: ' + updatedOS);
      
      

       

        if (updatedOS != null) {
           
            accessToken= updatedOS.Access_Token__c;
            system.debug('access token'+accessToken);
            Three_Nilufa.fetchSubscriptionsAndNotify(accessToken);
            
            //
        } else {
            System.debug('No matching Outlook_Subscribe__c record found.');
        }
    }
    
    // private static String sendHttpRequest(String url, String accessToken) {
    //     // Send a GET request to Microsoft Graph API to retrieve subscriptions
    //     System.debug('accessToken--->' + accessToken);
    //     System.debug('url--->' + url);

    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(url);
    //     req.setMethod('GET');
    //     req.setHeader('Authorization', 'Bearer ' + accessToken);
    //     req.setHeader('Accept', 'application/json');  // Add the Accept header

    //     Http http = new Http();
    //     HttpResponse res = http.send(req);

    //     if (res.getStatusCode() == 200) {
    //         return res.getBody();
    //     } else {
    //         System.debug('Error fetching subscriptions: ' + res.getBody());
    //         return null;
    //     }
    // }

    // public static void delteOutlikeSubscribe(Outlook_Subscribe__c os) {
    //     // Step 1: Get a valid access token
    //     Outlook_Subscribe__c updatedOS = RefreshTokenService.getRefreshToken(os);
    //     System.debug('Updated Outlook_Subscribe__c: ' + updatedOS);

    //     String accessToken = updatedOS.Access_Token__c;
    //     if (String.isNotEmpty(accessToken)) {
    //         // Step 2: Query Microsoft Graph API for Subscriptions
    //         String subscriptionsUrl = 'https://graph.microsoft.com/v1.0/subscriptions/';
    //         String response = sendHttpRequest(subscriptionsUrl, accessToken);

    //         // Step 3: Parse the response and check for matching notificationUrl
    //         if (response != null) {
    //             try {
    //                 // Deserialize the response to a Map to access the 'value' field
    //                 Map<String, Object> responseMap = ((Map<String, Object>)JSON.deserializeUntyped(response));
    //                 List<Object> subscriptions = ((List<Object>)responseMap.get('value'));

    //                 // The notification URL that we want to check for
    //                 String targetNotificationUrl = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice';

    //                 // Step 4: Loop through the subscriptions to check if the notificationUrl already exists
    //                 boolean subscriptionFound = false;
    //                 for (Object subscriptionObj : subscriptions) {
    //                     Map<String, Object> subscription = (Map<String, Object>) subscriptionObj;
    //                     String notificationUrl = (String) subscription.get('notificationUrl');

    //                     // If the notification URL matches, delete the subscription
    //                     if (targetNotificationUrl.equals(notificationUrl)) {
    //                         subscriptionFound = true;
    //                         String subscriptionId = (String) subscription.get('id');
    //                         String deleteUrl = 'https://graph.microsoft.com/v1.0/subscriptions/' + subscriptionId;
    //                         deleteSubscription(deleteUrl, accessToken);
    //                         break;  // Exit the loop once the subscription is deleted
    //                     }
    //                 }

    //                 if (!subscriptionFound) {
    //                     System.debug('No matching subscription found with the specified notification URL.');
    //                 }
    //             } catch (Exception e) {
    //                 System.debug('Exception during subscription check or deletion: ' + e.getMessage());
    //             }
    //         } else {
    //             System.debug('No response received from the API.');
    //         }
    //     } else {
    //         System.debug('No access token available');
    //     }
    // }

    // private static void deleteSubscription(String url, String accessToken) {
    //     // Send a DELETE request to Microsoft Graph API to delete the subscription
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(url);
    //     req.setMethod('DELETE');
    //     req.setHeader('Authorization', 'Bearer ' + accessToken);

    //     Http http = new Http();
    //     HttpResponse res = http.send(req);

    //     if (res.getStatusCode() == 204) {
    //         System.debug('Subscription deleted successfully.');
    //     } else {
    //         System.debug('Error deleting subscription: ' + res.getBody());
    //     }
    // }
}