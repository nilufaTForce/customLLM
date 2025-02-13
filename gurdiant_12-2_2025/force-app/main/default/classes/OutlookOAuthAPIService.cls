@RestResource(urlMapping = '/OAuthApiService/*')
global without sharing class OutlookOAuthAPIService{
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(req));
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonData.get('params')));
        String validationToken = (String) params.get('validationToken');


        System.debug('Debug-POST---->' + JSON.serialize(req));
        // Subscription
        if (validationToken != null){
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(validationToken);
            res.addHeader('Content-Type', 'text/plain');

            // update appList;
        }
        
    }

    @HttpGet
    global static void getHandlers(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        System.debug('Debug-GET---->' + JSON.serialize(req));
        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(req));
        // if(jsonData)

        // Map<String, Object> jsonData2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonData.get('params')));
        
        // System.debug('Debug-GET-CODE--->' + jsonData2.get('code').toString());
        // System.debug('Debug-GET-CODE--->' + jsonData2.get('code'));
        // String accessToken = OutlookOAuthAPIHandler.getAccessToken(jsonData2.get('code').toString());
        Boolean state = OutlookOAuthAPIHandler.handleOAuth(jsonData);
        // System.debug('Debug-GET-ACCESS_TOKEN--->' + accessToken);

        

        // Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(req));
        res.addHeader('Content-Type', 'text/plain');
        if(state){
            res.responseBody = Blob.valueOf('Successfully Authenticated');
        }
        else{
            res.responseBody = Blob.valueOf('Authentication was not done.');
            
        }
        res.statusCode = 200;
    }

}