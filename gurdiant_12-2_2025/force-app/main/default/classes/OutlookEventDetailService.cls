public without sharing class OutlookEventDetailService {
    public static Map<String, Object> getEventDetils(String resourceUrl, Outlook_Subscribe__c os){
        
        Microsoft_Outlook_API__mdt config =  [SELECT Endpoint__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];

      
        String endpoint = config.Endpoint__c + '/v1.0/me/events'; 
        //do not delete
       // String endpoint = 'https://graph.microsoft.com/v1.0/me/events';
        
        String userID = resourceUrl.split('/')[1];
        String accessToken = os.Access_Token__c;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        
        Map<String, Object> responseMap;
        try{
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200){
                String responseBody = res.getBody();
                responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                System.debug('Parsed Response: ' + responseMap);
            }else if(res.getStatusCode() == 401){
                os = RefreshTokenService.getRefreshToken(os);
            } else{
                System.debug('Failed with status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        return responseMap;
    }
}