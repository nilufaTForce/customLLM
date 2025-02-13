public with sharing class AgoraTokenController {
  //do not delete
    //private static final String BASE_URL = 'https://agora-in-test.vercel.app/api/generateToken';
  
    public class TokenResponse {
        public String token { get; set; }
    }
    
    /**
     * Generate Agora RTC Token by calling the external API.
     * @param channelName The channel name for Agora communication.
     * @param uid The unique user ID for Agora.
     * @return The generated RTC token.
     * @throws CalloutException if the API call fails.
     */
    @AuraEnabled(cacheable=true)
    public static String generateToken(String channelName, String uid) {
        Agora_API_Setting__mdt agoraSetting = [SELECT Generate_Token_Api__c FROM Agora_API_Setting__mdt LIMIT 1];
        String BASE_URL = agoraSetting.Generate_Token_Api__c;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set request details
        request.setEndpoint(BASE_URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(new Map<String, String>{
            'channelName' => channelName,
            'uid' => uid
        }));
        
        // Make the HTTP callout
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            String tokenKey = '"token":"';
            Integer tokenStartIndex = responseBody.indexOf(tokenKey) + tokenKey.length();
            Integer tokenEndIndex = responseBody.indexOf('"', tokenStartIndex);
            if (tokenStartIndex > 0 && tokenEndIndex > 0) {
                return responseBody.substring(tokenStartIndex, tokenEndIndex);
            } else {
                throw new AuraHandledException('Token not found in response');
            }
        } else {
            throw new CalloutException('Error: ' + response.getBody());
        }
    }
}