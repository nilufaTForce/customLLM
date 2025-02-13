public without sharing class OutlookUserInfoAPI {
    
    public static String updateSubUserId(String accessToken){
        Microsoft_Outlook_API__mdt cred = [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
        Base_Auth_Url__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];
        String endpoint = cred.Endpoint__c +'/v1.0/me' ;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        //do not delete
        //req.setEndpoint('https://graph.microsoft.com/v1.0/me');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/x-application/json');
        req.setHeader('Accept', 'application/json');


        HttpResponse res = http.send(req);
        Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        String returnBody = '';
        // System.debug('OutlookUserInfoAPI responseBody--> ' + responseBody);
        if (responseBody.get('id') != null){
            // os.User_ID__c = (String) responseBody.get('id');
            returnBody = (String) responseBody.get('id');
        }
        if (responseBody.get('mail') != null){
            // os.Email__c = (String) responseBody.get('mail');
            returnBody += '::' + (String) responseBody.get('mail');
        }

        return returnBody;
    }
}