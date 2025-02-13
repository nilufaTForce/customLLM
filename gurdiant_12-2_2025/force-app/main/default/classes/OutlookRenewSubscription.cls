public without sharing class OutlookRenewSubscription {

    @Future(callout=true)
    public static void renewOutlookSubscription(Id recordId){
        Outlook_Subscribe__c os = [SELECT Id, Access_Token__c, Refresh_Token__c, Subscribe_ID__c, User_ID__c, Expiration_Date__c, Meta_Data__c,Email__c
                                   FROM Outlook_Subscribe__c
                                   WHERE Id = :recordId LIMIT 1];
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        String accessToken = os.Access_Token__c;
        // String accessToken = 'eyJ0eXAiOiJKV1QiLCJub25jZSI6IlBlXzRPWlRHSHNGYnVaZnRzbDV3ampINGFoLVROcENXY2VlSUtYSGJTTTAiLCJhbGciOiJSUzI1NiIsIng1dCI6IjNQYUs0RWZ5Qk5RdTNDdGpZc2EzWW1oUTVFMCIsImtpZCI6IjNQYUs0RWZ5Qk5RdTNDdGpZc2EzWW1oUTVFMCJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC81NDFlNzExMC1lOTkxLTQ1YjUtYTUxNC04YWNiNzMxM2Q4Y2UvIiwiaWF0IjoxNzMxOTA4MTY2LCJuYmYiOjE3MzE5MDgxNjYsImV4cCI6MTczMTkxMjg3OCwiYWNjdCI6MCwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhZQUFBQWw2L2pENzJNVHlHNVFWWnVMYjR0RXRrR0x2Nm9qVHB3YmZHUTdRNGRjYlJ0T0JDUjBjcHZMRTRBU2tXWWNObHlCd1pTR2t6QVJnN2RReWNDdmVmRHJqU1ZVVDNaT3JCYkVBTXZZTnlpVE9jPSIsImFtciI6WyJwd2QiLCJtZmEiXSwiYXBwX2Rpc3BsYXluYW1lIjoiU3VwZXJDYWxlbmRhciIsImFwcGlkIjoiMDQzNTcxOGQtMjk5Yi00YzE2LTkzODItZWRjNTY5NjMwNDdlIiwiYXBwaWRhY3IiOiIxIiwiZmFtaWx5X25hbWUiOiJLYXkiLCJnaXZlbl9uYW1lIjoiV2lsbGlhbSIsImlkdHlwIjoidXNlciIsImlwYWRkciI6IjEwMy4yMTguMjcuMSIsIm5hbWUiOiJXaWxsaWFtIEtheSIsIm9pZCI6ImQwYzVkMjMyLThkM2ItNDg1NS04YzBkLTU0OTA3MGIyNTE0OSIsInBsYXRmIjoiNSIsInB1aWQiOiIxMDAzMjAwM0Y3OTg2MDNDIiwicmgiOiIxLkFYRUJFSEVlVkpIcHRVV2xGSXJMY3hQWXpnTUFBQUFBQUFBQXdBQUFBQUFBQUFCeEFlNXhBUS4iLCJzY3AiOiJDYWxlbmRhcnMuUmVhZCBEaXJlY3RvcnkuUmVhZC5BbGwgTWFpbGJveFNldHRpbmdzLlJlYWQgVXNlci5SZWFkIFVzZXIuUmVhZC5BbGwgVXNlci5SZWFkQmFzaWMuQWxsIHByb2ZpbGUgb3BlbmlkIGVtYWlsIiwic2lnbmluX3N0YXRlIjpbImttc2kiXSwic3ViIjoicl9HSEJpVWZBaXVRVzh6QlpQYzNyTXB5N3NXaGhlaWxUclVOWUlVb05yWSIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJOQSIsInRpZCI6IjU0MWU3MTEwLWU5OTEtNDViNS1hNTE0LThhY2I3MzEzZDhjZSIsInVuaXF1ZV9uYW1lIjoic3VwcG9ydEBmbG93ci5saWZlIiwidXBuIjoic3VwcG9ydEBmbG93ci5saWZlIiwidXRpIjoiemIzYnRxSTUyMENXTEdBaWY4TklBdyIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc19pZHJlbCI6IjEgMjgiLCJ4bXNfc3QiOnsic3ViIjoiLXdwcDlrams5Y2RJY2I2cnNXa1psc20wWVUwMkRGMHJWa25wN29jY1R1NCJ9LCJ4bXNfdGNkdCI6MTczMTA4OTY1MX0.TfrnQW149Tegyuh5qMN2nTAamiY_AbV4my56fdqIc8nMC9NNamJWnnABsB0Qbg6gyCWtYuj8xZ4nN-Dry91bkaWiQvL00pJN8YpSz5bEntgpHZUvmkHuxV1Ko502F05FOEpviMh1vfolG9KwdmbR2d-i7u4muksNBPGZAPBkagaULj4t82UcRPRk21CGFD-bsFaf4ULS57dArrqC_-Su542Zgcjpz0CY8JTf3YoVKfO6ccwI-FecudBnNBsHu5n8hKOeeL31WjsCm853G7EZdxU4RHmeeJ8QG115hLdVzng6Q7bwlA-BU4ZqC5h_HQOGyew34mxVZkNeuFJHySFtQA';
        Microsoft_Outlook_API__mdt cred = [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
                Base_Auth_Url__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
        String endpoint = cred.Outlook_Subscription_Api__c+'/' + os.Subscribe_ID__c;
    
        //do not delete
        //req.setEndpoint('https://graph.microsoft.com/v1.0/subscriptions/' + os.Subscribe_ID__c);
        req.setEndpoint(endpoint );
        req.setMethod('PATCH');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        // String endPoint = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice';

        Datetime datePlusTwoDays = Datetime.now().addDays(3);

        // Format it as a string in the desired format with milliseconds and 'Z' at the end
        String formattedDate = datePlusTwoDays.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');


        String body = '{' + '"expirationDateTime": "' + formattedDate + '"' + '}';

        req.setBody(body);
        
        // System.debug('req--->' + req);
        // System.debug('accessToken--->' + accessToken);
        // System.debug('body--->' + body);

        try{
            HttpResponse res = http.send(req);
            System.debug('OutlookSubQueue--Response Body: ' + res.getBody());
            System.debug('OutlookSubQueue--Response Code: ' + res.getStatusCode());
            if (res.getStatusCode() == 200){
                 // API Call Returning 201 - (Created)
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

                String expirationDateTime = (String) jsonData.get('expirationDateTime');
                // String userId = (String) jsonData.get('creatorId');
                String subscribeId = (String) jsonData.get('id');

                os.Expiration_Date__c = Date.valueOf(expirationDateTime);
                os.Subscribe_ID__c = subscribeId;
                // os.Meta_Data__c = res.getBody();
                // this.globarOS = os;

            }
            else if (res.getStatusCode() == 404) {
                // If the subscription is not found (404), create a new subscription
                // Id newSubscriptionId = createOutlookSubscription(os.Access_Token__c, os.User_ID__c, os.Email__c);
                createOutlookSubscriptionAndUpdateExisting(os);
                // Once subscription is created, renew it
                // renewOutlookSubscription(newSubscriptionId); 
                // os.Subscribe_ID__c = newSubscriptionId;
                // Database.update(os, true);
            } else{
                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        } catch (Exception e){
            System.debug('Exception on OutlookRenewSubscription.renewOutlookSubscription: ' + e.getMessage());
        }
        Database.update(os, true);
    }
    
    private static void createOutlookSubscriptionAndUpdateExisting(Outlook_Subscribe__c os) {
           Microsoft_Outlook_API__mdt cred = [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
                Base_Auth_Url__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
        String url = cred.Outlook_Subscription_Api__c;
    
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        //do not delete
        //req.setEndpoint('https://graph.microsoft.com/v1.0/subscriptions');
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + os.Access_Token__c);

        String endPoint = cred.Redirect_Url_Outlook__c;
        //do not delete
        //String endPoint = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice';
        Datetime datePlusTwoDays = Datetime.now().addDays(3);
        String formattedDate = datePlusTwoDays.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

        String body = JSON.serialize(new Map<String, Object>{
            'changeType' => 'created,updated,deleted',
            'notificationUrl' => endPoint,
            'resource' => 'users/' + os.User_ID__c + '/events',
            'expirationDateTime' => formattedDate,
            'clientState' => 'SecretClientState'
        });

        req.setBody(body);

        try {
            HttpResponse res = http.send(req);
            System.debug('Response Body: ' + res.getBody());

            if (res.getStatusCode() == 201) {
                Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String expirationDateTime = (String) jsonData.get('expirationDateTime');
                String subscribeId = (String) jsonData.get('id');

                // Update the existing Outlook_Subscribe__c record with the new subscription ID
                os.Expiration_Date__c = Date.valueOf(expirationDateTime);
                os.Subscribe_ID__c = subscribeId;
                os.Meta_Data__c = res.getBody();

                // Update the existing record instead of inserting a new one
                Database.update(os, true);
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception in createOutlookSubscriptionAndUpdateExisting: ' + e.getMessage());
        }
    }
    
}