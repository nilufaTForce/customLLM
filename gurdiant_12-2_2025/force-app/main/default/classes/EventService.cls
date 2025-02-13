public without sharing class EventService{
    public static void sendOutlookEventAsync(String doctorEmail, String patientName, String doctorName, String providerName, String location, Id eventUID, String startTimeText, String duration, Date appointedDate, Time startTime, Time endTime, String groupTimeZone, String meetlink, Appointment__c app, DateTime startDateTime, DateTime endDateTime){

        // Reconstruct the EmailWrapper object inside the future method
        EventHandler.EmailWrapper emailWrapper = new EventHandler.EmailWrapper();
        emailWrapper.patientName = patientName;
        emailWrapper.doctorName = doctorName;
        emailWrapper.providerName = providerName;
        emailWrapper.doctorEmail = doctorEmail;
        emailWrapper.location = location;
        emailWrapper.eventUID = String.valueOf(eventUID); // Convert ID to String
        emailWrapper.startTimeText = startTimeText;
        emailWrapper.duration = duration;
        emailWrapper.appointedDate = appointedDate;
        emailWrapper.startTime = startTime;
        emailWrapper.endTime = endTime;
        emailWrapper.groupTimeZone = groupTimeZone;
        emailWrapper.meetlink = meetlink;
        


        // System.debug(startTime);
        // System.debug(endTime);

        // Call the existing method to send the Outlook event
        // Call the existing method to send the Outlook event

        sendOutlookEvent(emailWrapper, app, startDateTime, endDateTime); // Otherwise, use the regular event method
        System.debug('sendOutlookEvent');
    }

    //support@solve4u.io
    // public static void sendOutlookEvent(String recipientEmail) {
    public static void sendOutlookEvent(EventHandler.EmailWrapper emailWrapper, Appointment__c app, DateTime startDateTimee, DateTime endDateTimee){


        String recipientEmail = emailWrapper.doctorEmail;

        // if (String.isEmpty(recipientEmail) || String.isBlank(recipientEmail)){
        //     return;
        // }

        EmailServicesFunction emailFunction = [SELECT Id
                                               FROM EmailServicesFunction
                                               WHERE FunctionName = 'Inbound Appointment Emails'];
        EmailServicesAddress emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName
                                                     FROM EmailServicesAddress
                                                     WHERE FunctionId = :emailFunction.Id];
        // System.debug('Email Service Address: ' + emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName);

        String recordtypeName;
        Id providerID = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Unavailable').getRecordTypeId();
        if (app.RecordTypeId == providerID) recordtypeName = 'unavailable';
        else recordtypeName = 'appointment';
        String eventSubject = emailWrapper.providerName + ': ' + emailWrapper.location;
        String eventLocation = emailWrapper.location;
        // Date startTime = emailWrapper.startDate;
        // Date endTime = emailWrapper.endDate;
        DateTime startDateTime =startDateTimee;
        system.debug('Record Type Name: ' + recordtypeName);
        system.debug('Doctor Name: ' + emailWrapper.doctorName);
        system.debug(emailWrapper.startTime+' '+emailWrapper.appointedDate );
        system.debug('Hi , '+startDateTime+'   '+startDateTime.format()+'   '+startDateTime.time());
        DateTime endDateTime = endDateTimee;
        String emailBody = 'Hello ' + emailWrapper.doctorName + ',<br> ' + 'This is to notify that an ' + recordtypeName + ' has been scheduled on <strong>' + ' ' + emailWrapper.startTimeText + ' ' + emailWrapper.groupTimeZone + '</strong>.';
        // String organizerEmail = 'araf.tforce@gmail.com';  // Replace with actual organizer's email
        // String organizerEmail = emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName;  // Replace with actual organizer's email

        Microsoft_Outlook_API__mdt config =  [SELECT Endpoint__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];

      
        String apiUrl = config.Endpoint__c + '/v1.0/me/events'; // Concatenate with the required path
        //do not delete
       // String apiUrl = 'https://graph.microsoft.com/v1.0/me/events';

        // Prepare the event payload
        String eventPayload = '{"subject": "' + eventSubject + '",' + 
                           '"start": {"dateTime": "' + startDateTime.format() + '", "timeZone": "UTC"},' + 
                           '"end": {"dateTime": "' + endDateTime.format() + '", "timeZone": "UTC"},' + 
                           '"location": {"displayName": "' + eventLocation + '"},' + 
                           '"attendees": [{"emailAddress": {"address": "' + recipientEmail + '"}, "type": "required"}],' + 
                           '"body": {"contentType": "HTML", "content": "' + emailBody + '"},' + 
                           '"reminderMinutesBeforeStart": 15}';  // Set reminder 15 minutes before

        // Authenticate and get access token
        List<Outlook_Subscribe__c> configs = [SELECT Id, Access_Token__c, Refresh_Token__c, Expiry_Time__c
                                              FROM Outlook_Subscribe__c
                                              WHERE Email__c = :recipientEmail
                                              LIMIT 1];
        String accessToken;
        if (configs.size() == 0){
            System.debug('The following providers outlook is not connected. Please authenticate providers outlook and try again.');
            // app.addError('Error: The following providers outlook is not connected. Please authenticate providers outlook and try again.');
            // // throw new EventServiceException('No config found');
            return;
        }
        //throw new EventServiceException('Application not subscribed to Outlook. Please connect your Outlook account.');

        // For the purpose of the demo, I'll simply create a new config)

        if (configs[0].Expiry_Time__c == null || System.now() > configs[0].Expiry_Time__c){
            // System.debug('Refresh token');
            // Expiry time has passed, so refresh the token

            RefreshTokenService.renewRefreshToken(configs[0].Id);
            List<Outlook_Subscribe__c> os = [SELECT Id, Access_Token__c, Refresh_Token__c, Expiry_Time__c
                                             FROM Outlook_Subscribe__c
                                             WHERE Email__c = :recipientEmail
                                             LIMIT 1];

            // After refreshing, return the new access token
            accessToken = os[0].Access_Token__c;


            // system.debug(recipientEmail + ' huhu ' + configs[0].Access_Token__c + 'yyyyyyy' + os[0].Access_Token__c);
            // system.debug('huu conf ' + configs[0].Access_Token__c);
            // system.debug('huu os ' + os[0].Access_Token__c);
            // if (configs[0].Access_Token__c == os[0].Access_Token__c){
            //     system.debug('equal');
            // } else{
            //     system.debug('not equal');
            // }

        } else{
            // System.debug('Access token');
            accessToken = configs[0].Access_Token__c;
        }

        // if(emailWrapper.patientName == null || emailWrapper.patientName == '') {
            EventService.enqueueEventJob(eventSubject, startDateTime, endDateTime, eventLocation, recipientEmail, emailBody, accessToken, emailWrapper.eventUID);
        //}
        // EventServiceQueueable queueableJob = new EventServiceQueueable(eventSubject, startDateTime, endDateTime,
        // eventLocation, recipientEmail, emailBody);
        //  System.enqueueJob(queueableJob);

        // String apiUrl = 'https://graph.microsoft.com/v1.0/me/events';

        // // Prepare the event payload
        // String eventPayload = '{"subject": "' + eventSubject + '",' +
        //                     '"start": {"dateTime": "' + startDateTime.format() + '", "timeZone": "UTC"},' +
        //                     '"end": {"dateTime": "' + endDateTime.format() + '", "timeZone": "UTC"},' +
        //                     '"location": {"displayName": "' + eventLocation + '"},' +
        //                     '"attendees": [{"emailAddress": {"address": "' + recipientEmail + '"}, "type": "required"}],' +
        //                     '"body": {"contentType": "HTML", "content": "' + emailBody + '"},' +
        //                     '"reminderMinutesBeforeStart": 15}';  // Set reminder 15 minutes before

        // // Authenticate and get access token
        // List<Outlook_Subscribe__c> configs = [SELECT Id, Access_Token__c, Refresh_Token__c, Expiry_Time__c FROM Outlook_Subscribe__c WHERE Email__c = :recipientEmail LIMIT 1];
        // String accessToken;
        // if (configs[0].Expiry_Time__c == null || System.now() > configs[0].Expiry_Time__c) {
        //     System.debug('Refresh token');
        //     // Expiry time has passed, so refresh the token
        //     RefreshTokenService.renewRefreshToken(configs[0].Id);
        //     List<Outlook_Subscribe__c> os = [SELECT Id, Access_Token__c, Refresh_Token__c, Expiry_Time__c FROM Outlook_Subscribe__c WHERE Email__c = :recipientEmail LIMIT 1];

        //     // After refreshing, return the new access token
        //     accessToken = os[0].Access_Token__c;
        // } else {
        //     System.debug('Access token');
        //     accessToken = configs[0].Access_Token__c;
        // }
        // // Send the POST request to create the event
        // HttpRequest req = new HttpRequest();
        // req.setEndpoint(apiUrl);
        // req.setMethod('POST');
        // req.setHeader('Authorization', 'Bearer ' + accessToken);
        // req.setHeader('Content-Type', 'application/json');
        // req.setBody(eventPayload);

        // Http http = new Http();
        // HttpResponse res = http.send(req);

        // // Check for a successful response
        // if (res.getStatusCode() == 201) {
        //     System.debug('Event created successfully in Outlook Calendar.');
        // } else {
        //     System.debug('Failed to create event. Status Code: ' + res.getStatusCode() + ', Response: ' + res.getBody());
        // }


        // Generate the .ics content without RSVP and Accept/Reject buttons
        if (String.isNotEmpty(emailWrapper.meetlink)){
            emailBody += '<br><br>You can join virtually using the following link: <a href="' + emailWrapper.meetlink + '" target="_blank">Join Meeting</a>';
        }

        /*
        String icsContent = 'BEGIN:VCALENDAR\n' + 
                     'VERSION:2.0\n' + 
                     'PRODID:-//Salesforce.com//iCal4j 1.0//EN\n' + 
                     'METHOD:REQUEST\n' +     // RSVP functionality
        'BEGIN:VEVENT\n' +   // 'UID:' + Datetime.now().getTime() + '@guardiant.com\n' +  // Unique ID
        'UID:' + emailWrapper.eventUID +      // Unique ID
        'DTSTAMP:' + formatICSDate(Datetime.now()) + '\n' + 
                     'DTSTART:' + formatICSDate(startDateTime) + '\n' + 
                     'DTEND:' + formatICSDate(endDateTime) + '\n' + 
                     'SUMMARY:' + eventSubject + '\n' + 
                     'LOCATION:' + eventLocation + '\n' + 
                     'ORGANIZER;CN=Guardiant Appointment:mailto:' + organizerEmail + '\n' + 
                     'ATTENDEE;CN=Attendee:RSVP=TRUE:mailto:' + organizerEmail + '\n' +     // Enable RSVP
        'STATUS:CONFIRMED\n' +     // Event status
        'SEQUENCE:0\n' + 
                     'TRANSP:OPAQUE\n' + 
                     'BEGIN:VALARM\n' +     // Reminder alert 15 minutes before
        'TRIGGER:-PT15M\n' + 
                     'ACTION:DISPLAY\n' + 
                     'DESCRIPTION:Reminder\n' + 
                     'END:VALARM\n' + 
                     'END:VEVENT\n' + 
                     'END:VCALENDAR';
        */

        // Create email attachment with .ics content
        // Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        // attachment.setFileName(emailWrapper.patientName + '.ics');
        // attachment.setBody(Blob.valueOf(icsContent));
        // attachment.setContentType('text/calendar; method=REQUEST');  // RSVP-enabled

        // Prepare and send email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
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
        }
    }

    // Helper method to format DateTime in iCalendar format
    private static String formatICSDate(Datetime dt){
        return dt.formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'');
    }

    @future(callout = true)
    public static void enqueueEventJob(String eventSubject, DateTime startDateTime, DateTime endDateTime, String eventLocation, String recipientEmail, String emailBody, String accessToken, String eventUID){
        EventServiceQueueable queueableJob = new EventServiceQueueable(eventSubject, startDateTime, endDateTime, eventLocation, recipientEmail, emailBody, accessToken, eventUID);
        System.enqueueJob(queueableJob);
    }

    public static void notifyAppToPatient(String providerName, String patientName, String emailID, String clinicName, String timeT, String dateT, String location, Id appId, Integer statusIndex, String timezone){
        //
        //System.debug(' i m here');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ emailID });
        email.setOrgWideEmailAddressId('0D2Wr0000000Mq9KAE');
        email.setSubject('Guardiant Appointment');
        // email.setSenderDisplayName('Guardiant Appointment');
        // Fetch meetLink value
        String meetLink = '';
        try{
            Appointment__c app = [SELECT Meet_Link_Url__c, Telehealth__c
                                  FROM Appointment__c
                                  WHERE Id = :appId
                                  LIMIT 1];
            meetLink = app.Meet_Link_Url__c;
            if (String.isBlank(meetLink) && app.Telehealth__c == 'Yes'){
                meetLink = 'https://meet.google.com/jhf-xzck-uce';
            }
        } catch (Exception e){
            System.debug('Error fetching appointment: ' + e.getMessage());
            meetLink = ''; // Default fallback if the query fails
        }

        String emailBody = generatePatAppBody(providerName, patientName, timeT, dateT, clinicName, location, appId, statusIndex, timezone, meetLink);
        email.setHtmlBody('<html><body>' + emailBody + '</body></html>');
        if (Test.isRunningTest()){
            return; // Reserve capacity for up to 10 emails in test context
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });

        if (results[0].success) {
            System.debug('The email was sent successfully to patient.');
        } else {
            System.debug('The email failed to send to patient: ' + results[0].errors[0].message);
        }
    }

    private static String generatePatAppBody(String providerName, String patientName, String timeT, String dateT, String clinicName, String location, Id appId, Integer statusIndex, String timezone, String meetLink){
        String body = '';
        API_Config__mdt apiConfig = [
                                    SELECT Base_URL__c 
                                    FROM API_Config__mdt	 
                                    WHERE API_Name__c = 'Guardian API' 
                                    LIMIT 1
                                ];
        String url = apiConfig.Base_URL__c + appId;

        //do not delete
        // String url = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/guardiantAPI/' + appId;
        // String script = generateScript();
        if (statusIndex == 1){
            body = 'Hello ' + patientName + ',<br>' + 'Your appointment is booked to ' + providerName + ', at <strong>' + timeT + ' ' + timezone + ', ' + dateT + '</strong> at ' + clinicName + ', ' + location + '.<br><br>';
            body += '<div style="margin: 10px;"><a id="fetchToken" href="' + url + '" style="background-color: #FF4B4B; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Cancel</a>&nbsp;&nbsp;';
            body += '<a href="www.google.com" style="background-color: #007DFF; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reschedule</a></div>';

            // if(!String.isBlank(meetLink)) {
            //     body += '<br><br>You can join virtually using the following link: <a href="' + meetlink + '" target="_blank">Join Meeting</a>';
            //     }
            // body += '</div>';


        } else if (statusIndex == 2){
            body = 'Hello ' + patientName + ',<br>' + 'Your appointment with ' + providerName + ', at ' + clinicName + ', ' + location + ', ' + ' on <strong>' + timeT + ' ' + timezone + ', ' + dateT + '</strong> has been canceled. Please click on \'Reschedule\' to reschedule your appointment.<br><br>';
            body += '<div style="margin: 10px;"><a href="www.google.com" style="background-color: #007DFF; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reschedule</a></div>';
        } else if (statusIndex == 3){
            // Accepted status
            body = 'Hello ' + patientName + ',<br>' + 'Your appointment with ' + providerName + ', at ' + clinicName + ', ' + location + ', ' + ' on <strong>' + timeT + ' ' + timezone + ', ' + dateT + '</strong> has been accepted.';
            if (!String.isBlank(meetLink)){
                body += '<br><br>You can join virtually using the following link: <a href="' + meetlink + '" target="_blank">Join Meeting</a>';
            }
            // body += '<div style="margin: 10px;">' + 
            //         '<a href="www.google.com" style="background-color: #007DFF; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">View Details</a>' + 
            //         '</div>';
           
            body += '</div>';
        }

        body = '<html><body>' + body + '</body></html>';
        return body;
    }

    public static void notifyCancelToPatient(Appointment__c app, Integer choice){
        // System.debug('notifyCancelToPatient--->' + app);
        // System.debug('meet-->' + app.Meet_Link_Url__c);

        String status = 'Accepted';
        if (choice == 1){
            status = 'Cancelled';
        }

        // Query the Clinic Resource
        // System.debug('Clinic_Resource__c--->' + app.Clinic_Resource__c);
        if (app.Clinic_Resource__c != null){
            List<Clinic_Resource__c> provider = [SELECT Id, Name, Email__c
                                                 FROM Clinic_Resource__c
                                                 WHERE Id = :app.Clinic_Resource__c
                                                 LIMIT 1];
            // System.debug('Provider: ' + provider);
            // system.debug('clinic' + app.Clinic_Resource__c);
            List<Account> patient = [SELECT Id, Email__c, Name
                                     FROM Account
                                     WHERE Id = :app.Patient_Account__c
                                     LIMIT 1];
            // System.debug('Patient: ' + patient);
            // System.debug(app.Provider_Company__c);
            List<Provider_Company__c> company;

            if (app.Provider_Company__c != null){
                company = [SELECT Id, Name
                           FROM Provider_Company__c
                           WHERE Id = :app.Provider_Company__c
                           LIMIT 1];
            }
            String providerEmail = provider[0].Email__c;
            String providerName = provider[0].Name;
            String patientEmail = patient[0].Email__c;
            String patientName = patient[0].Name;
            Time startTime = app.Start_Time__c;
            Datetime dateTimeValue = Datetime.newInstance(Date.today(), startTime);
            String formattedTime = dateTimeValue.format('hh:mm a');
            String appointedDate = app.Appointed_Date__c.format();
            String[] dateparts = appointedDate.split(' ');
            if (company == null || company.isEmpty()){
                Clinic_Location__c clinicLocation = [SELECT Provider_Company__c
                                                     FROM Clinic_Location__c
                                                     WHERE Id = :app.Clinic_Location__c
                                                     LIMIT 1];
                // Safely fetch company details if not already fetched
                company = [SELECT Id, Name
                           FROM Provider_Company__c
                           WHERE Id = :clinicLocation.Provider_Company__c
                           LIMIT 1];
                //System.debug(company[0].Name);
            }
            String onlyDate = dateparts[0];
            /*if (!provider.isEmpty()) {

             if (String.isNotBlank(provider[0].Email__c)) {


             // Prepare and send email
             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
             email.setToAddresses(new String[] { providerEmail });
             email.setOrgWideEmailAddressId('0D2Wr0000000L4TKAU');
             email.setSubject('Appointment with ' + patientName + ' has been ' + app.Status__c );
             // email.setSenderDisplayName('Guardiant Appointment');
             String emailBody = '<html><body><p>Dear ' + providerName + ',</p>' +
             '<p>Your appointment with ' + patientName + ', at ' + company[0].Name + ', ' + app.Location_Text__c +
             ', on <strong>' + formattedTime + ' , ' + app.Time_Zone__c + ', ' + onlyDate +
             '</strong> has been ' + status + '.</p>';
             email.setHtmlBody(emailBody);


             try {
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
             System.debug('Appointment updated and email sent to provider ' + providerEmail);
             } catch (Exception ex) {
             System.debug('Email could not be sent due to the following error: ' + ex.getMessage());
             }
             } else {
             System.debug('Provider email is blank for Clinic Resource ID: ' + app.Clinic_Resource__c);
             }
             } else {
             System.debug('No Clinic Resource found for Appointment ID: ' + app.Id);
             }*/
            if (!patient.isEmpty()){

                if (String.isNotBlank(patient[0].Email__c)){
                    String emailBody;
                    // Integer statusIndex;
                    // if(app.Status__c == 'Cancelled'){
                    //     statusIndex = 2;
                    // } else {
                    //     statusIndex = 1;
                    // }
                    // EventService.notifyAppToPatient(providerName, patientName, patient[0].Email__c, company[0].Name, formattedTime, onlyDate, app.Location_Text__c, app.Id, statusIndex, app.Time_Zone__c);
                    // Check if the appointment's status is 'Accepted' and a meeting link is provided
                    if (app.Status__c == 'Accepted' && String.isNotBlank(app.Meet_Link_Url__c)){
                        // Email body for 'Accepted' status with meeting link
                        emailBody = '<html><body><p>Dear ' + patientName + ',</p>' + 
                                     '<p>Your appointment with ' + providerName + ' ' + 
                                     'on <strong>' + formattedTime + ' , ' + app.Time_Zone__c + ', ' + onlyDate + '</strong> has been ' + status + '.</p>' + 
                                     '<p>You can join the meeting using the following link: <a href="' + app.Meet_Link_Url__c + '">' + app.Meet_Link_Url__c + '</a></p>' + 
                                     '<p>Thank you.</p></body></html>';
                    } else{
                        // Email body for other statuses without a meeting link
                        emailBody = '<html><body><p>Dear ' + patientName + ',</p>' + 
                                     '<p>Your appointment with ' + providerName + ', at ' + company[0].Name + ', ' + app.Location_Text__c + ', ' + 
                                     'on <strong>' + formattedTime + ' , ' + app.Time_Zone__c + ', ' + onlyDate + '</strong> has been ' + status + '.</p>' + 
                                     '<p>Thank you.</p></body></html>';
                    }

                    // // Prepare and send email to patient
                    Messaging.SingleEmailMessage patientEmailMessage = new Messaging.SingleEmailMessage();
                    OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
            
 
                    patientEmailMessage.setOrgWideEmailAddressId(owea.Id);
                    // patientEmailMessage.setOrgWideEmailAddressId('0D2Wr0000000L2rKAE');
                    // patientEmailMessage.setSenderDisplayName('Guardiant Appointment');
                    patientEmailMessage.setToAddresses(new String[]{ patientEmail });
                    patientEmailMessage.setSubject('Appointment with ' + providerName + ' has been ' + app.Status__c);
                    // patientEmailMessage.setSenderDisplayName('Guardiant Appointment');
                    patientEmailMessage.setHtmlBody(emailBody);
                    try{
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ patientEmailMessage });
                        // System.debug('Appointment updated and email sent to patient ' + patientEmail);
                    } catch (Exception ex){
                        System.debug('Email to patient could not be sent due to the following error: ' + ex.getMessage());
                    }
                } else{
                    System.debug('Patient email is blank for Patient Account ID: ' + app.Patient_Account__c);
                }
            } else{
                System.debug('No Patient Account found for Appointment ID: ' + app.Id);
            }
        } else{
            System.debug('No Clinic Resource linked to this appointment: ' + app.Id);
        }
    }

    // Your appointment with Guardiant Health on Friday, October 25th, 2024 at 2:00 PM PST has been canceled.
    // Please let us know if you need to reschedule.
    // Hello, your appointment time is at 12:30 PM PST at [location, address]
}