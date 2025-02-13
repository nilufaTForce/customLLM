public class CreateMeetingSpaceQueueable implements Queueable, Database.AllowsCallouts {
    private String accessToken;
    private Appointment__c app;
    private String location;
   

    public CreateMeetingSpaceQueueable(String accessToken,Appointment__c app, String location) {
        this.accessToken = accessToken;
        this.app = app;  // This line is causing an issue as 'app' is not initialized here.
        this.location = location; // This line is also an issue for the same reason.
    }
    

     public void execute(QueueableContext context) {
        // Query the record again to ensure it's not read-only
        Appointment__c queriedApp = [SELECT Id, Meet_Link_Url__c FROM Appointment__c WHERE Id = :app.Id LIMIT 1];

        // Build HTTP request for meeting space
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://meet.googleapis.com/v2/spaces');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"config":{"accessType":"OPEN","entryPointAccess":"ALL"}}');

        HttpResponse response;
        try {
            response = http.send(request);
        } catch (Exception e) {
            System.debug('HTTP request failed: ' + e.getMessage());
            return;
        }

        // Process the response
        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String meetingUrl = (String) jsonResponse.get('meetingUri');

            System.debug('Meeting URL: ' + meetingUrl);

            // Update the queried record
            queriedApp.Meet_Link_Url__c = meetingUrl;
            try {
                update queriedApp; // Save changes to the database
                System.debug('Updated Appointment with Meeting URL: ' + queriedApp.Meet_Link_Url__c);
                EventHandler.sentEventToDoctorDefault(app,location);
            } catch (DmlException e) {
                System.debug('Error updating appointment: ' + e.getMessage());
            }
        } else {
            System.debug('Failed to create meeting space: ' + response.getBody());
        }
    }
}