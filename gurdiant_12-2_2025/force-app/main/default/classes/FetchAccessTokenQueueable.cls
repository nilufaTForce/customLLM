public class FetchAccessTokenQueueable implements Queueable, Database.AllowsCallouts {
    private Appointment__c app;
    private String location;
    public FetchAccessTokenQueueable(Appointment__c app, String location) {
        this.app = app;
        this.location = location;
    }


    public void execute(QueueableContext context) {
        // Fetch credentials from custom metadata
      //https://guardiant--willg.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
        Meet_Link_Credentials__mdt credentials = Meet_Link_Credentials__mdt.getInstance('NEST_Intelligence');
        String clientId = credentials.Client_ID__c;
        String clientSecret = credentials.Client_Secret__c;

        // Fetch refresh token from custom object
        Meet_Link_Token__c token = [SELECT Refresh_Token__c FROM Meet_Link_Token__c WHERE Name = 'test' LIMIT 1];

        String refreshToken = token.Refresh_Token__c;

        // Build HTTP request for access token
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://oauth2.googleapis.com/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=refresh_token&refresh_token=' + refreshToken + 
                        '&client_id=' + clientId + 
                        '&client_secret=' + clientSecret);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) jsonResponse.get('access_token');

            // Chain the next queueable
            System.enqueueJob(new CreateMeetingSpaceQueueable(accessToken, app, location));
        } else {
            System.debug('Failed to fetch access token: ' + response.getBody());
        }
    }
}