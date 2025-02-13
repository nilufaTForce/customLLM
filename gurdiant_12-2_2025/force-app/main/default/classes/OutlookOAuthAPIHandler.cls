public without sharing class OutlookOAuthAPIHandler{
    // https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=0435718d-299b-4c16-9382-edc56963047e&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&state=12345
    @future(callout = true)
    private static void createOutlookSubscription(String subscribeCreds){

        Boolean ifExist = checkIFOutlookSubscriptionExist(subscribeCreds); 
        if(ifExist==false){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        // System.debug('createOutlookSubscription: subscribeCreds--->' + subscribeCreds);
        Outlook_Subscribe__c os = new Outlook_Subscribe__c();
        
        String accessToken = subscribeCreds.split('::')[0];
        os.Access_Token__c = accessToken;
        os.Refresh_Token__c = subscribeCreds.split('::')[1];
        
        String userString = OutlookUserInfoAPI.updateSubUserId(accessToken);
        os.User_ID__c = userString.split('::')[0];
        os.Email__c = userString.split('::')[1];

        Microsoft_Outlook_API__mdt azure_key = getAPICreds();
        String url = azure_key.Outlook_Subscription_Api__c;
        String endPoint = azure_key.Redirect_Url_Outlook__c;
        
        //do not delete
        //req.setEndpoint('https://graph.microsoft.com/v1.0/subscriptions');
        req.setEndpoint(url);
        req.setMethod('POST');
        // req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        //do not delete
       // String endPoint = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice';
        
        Datetime datePlusTwoDays = Datetime.now().addDays(3);
        
        // Format it as a string in the desired format with milliseconds and 'Z' at the end
        String formattedDate = datePlusTwoDays.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        
        
        
        String body = JSON.serialize(new Map<String, Object>{
            'changeType' => 'created,updated,deleted',
            'notificationUrl' => endPoint,
            'resource' => 'users/' + os.User_ID__c + '/events',
            'expirationDateTime' => formattedDate,
            'clientState' => 'secretClientValue'
        });
        
        req.setBody(body);
        
        Boolean isDuplicateFound = false;
        List<Outlook_Subscribe__c> osList = [SELECT Id, Access_Token__c, Refresh_Token__c, Subscribe_ID__c, Expiration_Date__c, Meta_Data__c FROM Outlook_Subscribe__c WHERE User_ID__c = :os.User_ID__c AND Email__c = :os.Email__c];
        if (!osList.isEmpty()) {
            isDuplicateFound = true;
        }
        // System.debug('req--->' + req);
        // System.debug('accessToken--->' + accessToken);
        // System.debug('body--->' + body);
        // System.debug('Headers: ' + req.getHeaders());
        try{
            HttpResponse res = http.send(req);
            System.debug('OutlookOAuthAPIHandler - Response Body--->' + res.getBody());
            // System.debug('Response Code: ' + res.getStatusCode());
            if (res.getStatusCode() == 201){
                // API Call Returning 201 - (Created)
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                
                String expirationDateTime = (String) jsonData.get('expirationDateTime');
                // String userId = (String) jsonData.get('creatorId');
                String subscribeId = (String) jsonData.get('id');

                if(isDuplicateFound){
                    osList[0].Access_Token__c = subscribeCreds.split('::')[0];
                    osList[0].Refresh_Token__c = subscribeCreds.split('::')[1];
                    osList[0].Expiration_Date__c = Date.valueOf(expirationDateTime);
                    osList[0].Subscribe_ID__c = subscribeId;
                    osList[0].Meta_Data__c = res.getBody();
                    Database.update(osList[0]);
                    return;
                }

                os.Expiration_Date__c = Date.valueOf(expirationDateTime);
                os.Subscribe_ID__c = subscribeId;
                // os.User_ID__c = userId;
                os.Meta_Data__c = res.getBody();
                
                
            } else{
                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        } catch (Exception e){
            System.debug('Exception on createOutlookSubscription: ' + e.getMessage());
        }
        // System.debug('OutlookOAuthAPIHandler: Outlook_Subscribe__c-->' + os);
        insert os;
        }
    }
    
    public static Boolean handleOAuth(Map<String, Object> jsonData){
        Map<String, Object> jsonData2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonData.get('params')));
        
        if(!jsonData2.containsKey('code')){
            System.debug('Code was not found!');
            return false;
        }
        String code = jsonData2.get('code').toString();
        
        HttpRequest req = createRequest(code);
        
        Http http = new Http();
        HttpResponse res;
        
        try{
            res = http.send(req);
            if (res.getStatusCode() == 200){
                
                // Outlook_Subscribe__c os = createSubscribeRecord(res);
                String subscribeCreds = createSubscribeRecord(res);
                
                createOutlookSubscription(subscribeCreds);
                return true;
                
            } else{
                System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
                // return null;
            }
        } catch (Exception e){
            System.debug('Exception while making HTTP request: ' + e.getMessage());
            // return null;
        }
        return false;
    }
    
    
    private static HttpRequest createRequest(String authorizationCode){
        
        Microsoft_Outlook_API__mdt azure_key = getAPICreds();
        String clientId = azure_key.Client_Id__c;
        String clientSecret = azure_key.Client_Secret__c;
       
        String endpoint =azure_key.Base_Auth_Url__c +'/common/oauth2/v2.0/token' ; 
        //do not delete
       // String redirectUri = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService';
       String redirectUri =azure_key.Redirect_Url__c; 
        
        // Initialize the HTTP request
        HttpRequest req = new HttpRequest();
        // do not delete
       // req.setEndpoint('https://login.microsoftonline.com/common/oauth2/v2.0/token');
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Create the body with URL-encoded form data
        String body = 'grant_type=authorization_code' +
            '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
            '&code=' + EncodingUtil.urlEncode(authorizationCode, 'UTF-8') +
            '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8');
        
        // Set the body on the request
        req.setBody(body);
        return req;
    }
    
    private static String createSubscribeRecord(HttpResponse res){
        // Parse the JSON response to extract the access token
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('GET BODY--->' + JSON.serializePretty(responseBody));
        String accessToken = (responseBody.get('access_token') != null) ? (String) responseBody.get('access_token') : null;
        String refreshToken = (responseBody.get('refresh_token') != null) ? (String) responseBody.get('refresh_token') : null;
        
        // Map <String, String> tokenMap = new Map <String, String>();
        String response = '';
        if (accessToken != null){
            // tokenMap.put('accessToken', accessToken);
            response = accessToken;
        }
        if (refreshToken != null){
            // tokenMap.put('refreshToken', refreshToken);
            response += '::' + refreshToken;
        }
        
        return response;
    }
    
    private static void updateSubUserId(Id recordId){
        Outlook_Subscribe__c os = [SELECT Id, Access_Token__c, Refresh_Token__c, Subscribe_ID__c, User_ID__c, Expiration_Date__c, Meta_Data__c
                                   FROM Outlook_Subscribe__c
                                   WHERE Id = :recordId
                                   LIMIT 1];
        
        Microsoft_Outlook_API__mdt azure_key = getAPICreds();
        String clientId = azure_key.Client_Id__c;
        String clientSecret = azure_key.Client_Secret__c;
         
        String endpoint =azure_key.Endpoint__c +'/v1.0/me' ; 
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        //do not delete
        //req.setEndpoint('https://graph.microsoft.com/v1.0/me');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + os.Access_Token__c);
        req.setHeader('Content-Type', 'application/x-application/json');
        req.setHeader('Accept', 'application/json');
        
        
        HttpResponse res = http.send(req);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        
        // System.debug('new responseBody--> ' + responseBody);
        if (responseBody.get('id') == null){
            return;
        }
        
        os.User_ID__c = (String) responseBody.get('id');
        // os.Email__c = (String) responseBody.get('mail');
        update os;
    }
    
    private static Microsoft_Outlook_API__mdt getAPICreds(){
        return [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
                Base_Auth_Url__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
    }

   
    private static boolean checkIFOutlookSubscriptionExist(String subscribeCreds) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String accessToken = subscribeCreds.split('::')[0];
        Microsoft_Outlook_API__mdt azure_key = getAPICreds();
        String endpoint = azure_key.Outlook_Subscription_Api__c;
      
        //do not delete
       // req.setEndpoint('https://graph.microsoft.com/v1.0/subscriptions');
       req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        
        try {
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                // Parse the response body
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                List<Object> subscriptions = (List<Object>) jsonData.get('value');
                
                // The notification URL that we want to check for
                //do not delete
               //String targetNotificationUrl = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice';
              String targetNotificationUrl = azure_key.Redirect_Url_Outlook__c;
                
                // Loop through the subscriptions to check if the notificationUrl already exists
                for (Object subscriptionObj : subscriptions) {
                    Map<String, Object> subscription = (Map<String, Object>)subscriptionObj;
                    String notificationUrl = (String) subscription.get('notificationUrl');
                    
                    // If the notification URL matches, return true (subscription exists)
                    if (targetNotificationUrl.equals(notificationUrl)) {
                        return true;
                    }
                }
            } else {
                System.debug('Error checking subscriptions: ' + res.getStatus() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception on checking subscription: ' + e.getMessage());
        }
        
        // If no match was found, return false (subscription doesn't exist)
        return false;
    }
    
    
}