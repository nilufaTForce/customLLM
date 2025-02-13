public class CreateAgoraVideoCallLink implements Queueable, Database.AllowsCallouts  {
    private Appointment__c app;
    private String location;
    public CreateAgoraVideoCallLink(Appointment__c app, String location) {
        this.app = app;
        this.location = location;
    }

    public void execute(QueueableContext context) {
        Agora_API_Setting__mdt  agoraSetting = [SELECT Endpoint__c FROM Agora_API_Setting__mdt LIMIT 1];
        string endpoint = agoraSetting.Endpoint__c; 
        // Callout to get meeting URL
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //do not delete
        // request.setEndpoint('https://agora-video-call-link.vercel.app/createVideoLink');
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String meetingUrl = (String)responseData.get('link');
                Appointment__c queriedApp = [SELECT Id, Meet_Link_Url__c FROM Appointment__c WHERE Id = :app.Id LIMIT 1];
                queriedApp.Meet_Link_Url__c = meetingUrl;
                update queriedApp;
                System.debug('Updated Appointment with Meeting URL: ' + queriedApp.Meet_Link_Url__c);
                EventHandler.sentEventToDoctorDefault(app, location);
            } else {
                System.debug('Failed to fetch the meeting URL, response status: ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Error in making HTTP request: ' + e.getMessage());
        }
    }

}