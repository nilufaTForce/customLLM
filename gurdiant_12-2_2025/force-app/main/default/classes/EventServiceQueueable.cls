public with sharing class EventServiceQueueable implements Queueable, Database.AllowsCallouts{
    private String eventSubject;
    private DateTime startDateTime;
    private DateTime endDateTime;
    private String eventLocation;
    private String recipientEmail;
    private String emailBody;
    private String accessToken;
    private String location;
    private Id eventUID;
    // Constructor to pass in the event details
    public EventServiceQueueable(String eventSubject, DateTime startDateTime, DateTime endDateTime, String eventLocation, String recipientEmail, String emailBody, String accessToken, String eventUID){
        this.eventSubject = eventSubject;
        this.startDateTime = startDateTime;
        this.endDateTime = endDateTime;
        this.eventLocation = eventLocation;
        this.recipientEmail = recipientEmail;
        this.emailBody = emailBody;
        this.accessToken = accessToken;
        this.eventUID = eventUID;
    }

    // The execute method for the Queueable job
    public void execute(QueueableContext context){
        Microsoft_Outlook_API__mdt apiCreds =[SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
        Base_Auth_Url__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];
        String apiUrl = apiCreds.Endpoint__c + '/v1.0/me/events';
        system.debug('Hii i m quable  '+apiUrl);
        //do  not delete
        //String apiUrl = 'https://graph.microsoft.com/v1.0/me/events';

        // // Prepare the event payload
        String eventPayload = '{"subject": "' + eventSubject + '",' + 
                           '"start": {"dateTime": "' + startDateTime.format() + '", "timeZone": "UTC"},' + 
                           '"end": {"dateTime": "' + endDateTime.format() + '", "timeZone": "UTC"},' + 
                           '"location": {"displayName": "' + eventLocation + '"},' + 
                           '"attendees": [{"emailAddress": {"address": "' + recipientEmail + '"}, "type": "required"}],' + 
                           '"body": {"contentType": "HTML", "content": "' + emailBody + '"},' + 
                           '"reminderMinutesBeforeStart": 15}';  // Set reminder 15 minutes before


                           system.debug(' i m eventpayload   '+eventPayload);

        //   System.debug(eventPayload+' i m d'+startDateTime.format() +' '+startDateTime+'      jj     '+startDateTime.format('yyyy-MM-dd HH:mm:ss', 'GMT'));

        // // Authenticate and get access token
        // List<Outlook_Subscribe__c> configs = [SELECT Id, Access_Token__c, Refresh_Token__c, Expiry_Time__c
        //                                       FROM Outlook_Subscribe__c WHERE Email__c = :recipientEmail LIMIT 1];
        // String accessToken;

        // if (configs.isEmpty() || configs[0].Expiry_Time__c == null || System.now() > configs[0].Expiry_Time__c) {
        //     // Expiry time has passed, refresh the token
        //     System.debug('Refreshing access token');
        //     RefreshTokenService.renewRefreshToken(configs[0].Id);
        //     // After refreshing, get the new access token
        //     configs = [SELECT Id, Access_Token__c, Refresh_Token__c, Expiry_Time__c
        //                FROM Outlook_Subscribe__c WHERE Email__c = :recipientEmail LIMIT 1];
        //     accessToken = configs[0].Access_Token__c;
        // } else {
        //     // Use the existing access token
        //     accessToken = configs[0].Access_Token__c;
        // }
        // System.debug('After checking the token expiry, the token is ' + accessToken);
        // Create the HTTP request to send to Microsoft Graph API
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setBody(eventPayload);

        Http http = new Http();
        HttpResponse res = http.send(req);

        // Check for a successful response
        if (res.getStatusCode() == 201){
            // System.debug('hii i m sorry '+eventUID);
            // System.debug('res'+res.getBody());
            // Parse JSON response to get Event ID

            // // String tim = startTime.format('HH:mm');
            // System.debug('Event created successfully in Outlook Calendar.');

            Appointment__c app = [SELECT Id, Start_Time__c, Appointed_Date__c, Clinic_Resource__r.Name, Clinic_Location__r.Time_Zone__c, Clinic_Location__r.Address_Text__c, Clinic_Location__r.Name, Patient_Account__r.Name, Patient_Account__r.Email__c
                                  FROM Appointment__c
                                  WHERE Id = :eventUID];


                                  // Get the hour and minute
Integer hour24 = app.Start_Time__c.hour(); // 24-hour format
Integer minute = app.Start_Time__c.minute();

// Convert to 12-hour format
String amPm = (hour24 >= 12) ? 'PM' : 'AM';
Integer hour12 = (hour24 == 0) ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);

// Format the time string with leading zero for minutes
String timeStr = String.valueOf(hour12) + ':' + (minute < 10 ? '0' + String.valueOf(minute) : String.valueOf(minute)) + ' ' + amPm;

            String appointedDateStr = app.Appointed_Date__c.format();
            // String timeStr = String.valueOf(app.Start_Time__c.hour()) + ':' + (app.Start_Time__c.minute() < 10 ? '0' + String.valueOf(app.Start_Time__c.minute()) : String.valueOf(app.Start_Time__c.minute()));
           
           
           
            EventService.notifyAppToPatient(app.Clinic_Resource__r.Name, app.Patient_Account__r.Name, app.Patient_Account__r.Email__c, app.Clinic_Location__r.Name, timeStr, appointedDateStr, app.Clinic_Location__r.Address_Text__c, eventUID, 3, app.Clinic_Location__r.Time_Zone__c);

        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ recipientEmail });
        mail.setOrgWideEmailAddressId('0D2Wr0000000Mq9KAE');
        mail.setSubject(eventSubject);
        // mail.setPlainTextBody('You are invited to a meeting. Please find the event details attached and RSVP with Yes, No, or Maybe.');
        //    mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
        // mail.setReplyTo(organizerEmail);
        // mail.setSenderDisplayName('Guardiant Appointment');
        mail.setHtmlBody('<html><body>' + emailBody + '</body></html>');

        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });

        if (results[0].success) {
            System.debug('The email was sent successfully to provider.');
        } else {
            System.debug('The email failed to send to provider: ' + results[0].errors[0].message);
        }*/
      
      
      
      
        } else{
            System.debug('Failed to create event. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
        }
    }

}