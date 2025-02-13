public without sharing class RefreshTokenService{
    
    /*public static Outlook_Subscribe__c getRefreshToken(Outlook_Subscribe__c os){
        Microsoft_Outlook_API__mdt moqm = getCreds();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String tenantId = moqm.Tenant_Id__c;
        String clientId = moqm.Client_Id__c;
        String clientSecret = moqm.Client_Secret__c;
        // String accessToken;

        req.setEndpoint('https://login.microsoftonline.com/common/oauth2/v2.0/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'client_id=' + clientId + 
                   '&client_secret=' + clientSecret + 
                   '&grant_type=' + 'refresh_token' + 
                   '&refresh_token=' + os.Refresh_Token__c + 
                   '&scope=https://graph.microsoft.com/.default';

        req.setBody(body);

        try{
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200){
                String responseBody = res.getBody();
                // System.debug('RefreshTokenService: ' + responseBody);

                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                // accessToken = (String) responseMap.get('access_token');
                // refreshToken = (String) responseMap.get('refresh_token');
                os.Access_Token__c = (String) responseMap.get('access_token');
                os.Refresh_Token__c = (String) responseMap.get('refresh_token');
                os.Expiry_Time__c = System.now().addMinutes(70);
                // if (isUpdate) {
                //     update os;
                // }
            }
            else if (res.getStatusCode() == 400) {
                System.debug('Status code is 400: ' + res.getBody());
            }
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        return os;
    }*/

    @Future(callout=true)
    public static void renewRefreshToken( Id recordId){
        Outlook_Subscribe__c os = [SELECT Id, Access_Token__c, Refresh_Token__c, Subscribe_ID__c, User_ID__c, Expiration_Date__c, Meta_Data__c
                                   FROM Outlook_Subscribe__c
                                   WHERE Id = :recordId LIMIT 1];
        Microsoft_Outlook_API__mdt moqm = getCreds();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        String tenantId = moqm.Tenant_Id__c;
        String clientId = moqm.Client_Id__c;
        String clientSecret = moqm.Client_Secret__c;
        String endpoint = moqm.Base_Auth_Url__c+'/common/oauth2/v2.0/token';
        String scope = moqm.Endpoint__c+'/.default';

        
        // String accessToken;
        // do not delete
        //req.setEndpoint('https://login.microsoftonline.com/common/oauth2/v2.0/token');
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

       //do not delete
        // String body = 'client_id=' + clientId + 
        //            '&client_secret=' + clientSecret + 
        //            '&grant_type=' + 'refresh_token' + 
        //            '&refresh_token=' + os.Refresh_Token__c + 
        //            '&scope=https://graph.microsoft.com/.default';
         String body = 'client_id=' + clientId + 
                   '&client_secret=' + clientSecret + 
                   '&grant_type=' + 'refresh_token' + 
                   '&refresh_token=' + os.Refresh_Token__c + 
                   '&scope='+scope;

        req.setBody(body);

        try{
            HttpResponse res = h.send(req);
            system.debug('before update');
            if (res.getStatusCode() == 200){
                system.debug('in if condition  update');
                String responseBody = res.getBody();
                // System.debug('RefreshTokenService: ' + responseBody);
                

                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                // accessToken = (String) responseMap.get('access_token');
                // refreshToken = (String) responseMap.get('refresh_token');
                os.Access_Token__c = (String) responseMap.get('access_token');
                os.Refresh_Token__c = (String) responseMap.get('refresh_token');
                os.Expiry_Time__c = System.now().addMinutes(70);
                // Database.update(os,true);
                try {
                    // Perform the update with partial success enabled
                    Database.SaveResult[] saveResults = Database.update(new List<SObject>{os}, true);
                
                    // Loop through the results to check the status of each record
                    for (Database.SaveResult sr : saveResults) {
                        if (sr.isSuccess()) {
                            System.debug('Update succeeded for record ID: ' + sr.getId());
                        } else {
                            // If update failed, log the errors
                            for (Database.Error err : sr.getErrors()) {
                                System.debug('Update failed for record ID: ' + os.Id + '. Error: ' + err.getMessage());
                            }
                        }
                    }
                } catch (Exception e) {
                    // Log any unexpected exceptions
                    System.debug('Unexpected error during update: ' + e.getMessage());
                }
                
                

               
            }
            else if (res.getStatusCode() == 400) {
                System.debug('Status code is 400: ' + res.getBody());
            }
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        
    }

    private static Microsoft_Outlook_API__mdt getCreds(){
        return [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Base_Auth_Url__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
    }

}