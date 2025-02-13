global class IncomingEmailHandler implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        System.debug('email => ' + email);
        System.debug('envelope => ' + envelope);
        String appointmentID = email.textAttachments[0].body.split('UID')[1];
        Integer i = appointmentID.indexOf('a1l'); // Appointment ID format always starts with a1l

        // System.debug('appointmentID-->' + appointmentID);
        // List<String> status = appointmentID.split('LANGUAGE=en-US:')[1].split(':')[0];
        // System.debug('status-0->' + appointmentID.split('SUMMARY;LANGUAGE=')[0]);
        // System.debug('status-1->' + appointmentID.split('SUMMARY;LANGUAGE=')[1].split(':')[1].split(':')[0]);
        String status = appointmentID.split('SUMMARY;LANGUAGE=')[1].split(':')[1].split(':')[0];
        
        
        appointmentID = appointmentID.substring(i, i + 18);

        Appointment__c app;
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try{
            app = [SELECT Id, Patient_Account__c, Clinic_Location__c, Doctor_Text__c, Start_Time__c, Appointed_Date__c, Status__c FROM Appointment__c WHERE Id = :appointmentID LIMIT 1];
        }catch(Exception e){
            System.debug('Exception on IncomingEmailHandler.handleInboundEmail-->' + e.getMessage());
            return result;
        }

        /*app.Status__c = status;
        Database.update(app, true);
        EventHandler.emailToPatient(app);*/

        // Create a new Case from the email
        // Case newCase = new Case(
        //     Subject = email.subject,
        //     Description = email.plainTextBody,
        //     Status = 'New'
        // );
        // insert newCase;
        
        // Optionally attach files
        /*
        Attachment att = new Attachment();
        if (email.binaryAttachments != null) {
            for (Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments) {
                att.Name = attachment.filename;
                att.Body = attachment.body;
                att.ParentId = 'a1RWr000000OXyvMAG';
                // insert att;
            }
        }
        
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.RelatedToId = 'a1RWr000000OXyvMAG'; // Associate with custom object
        emailMessage.FromAddress = email.fromAddress; // Sender's email address
        emailMessage.ToAddress = String.join(email.toAddresses, ';'); // Recipient(s)
        emailMessage.Subject = email.subject; // Email subject
        emailMessage.TextBody = email.plainTextBody; // Plain text body (fallback if HTML is unavailable)
        emailMessage.HtmlBody = email.htmlBody; // HTML body if available
        emailMessage.Status = '3'; // Set to 'Sent' (or other appropriate status)
        emailMessage.Incoming = true; // Mark as incoming email
        emailMessage.MessageDate = System.now(); // Date of email
        
        // Insert the EmailMessage record
        // insert emailMessage;
         */
        // System.debug('inbound working-->' + att);
        // List<String> appointmentID = email.textAttachments[0].body.split('UID');

        // String s = 'SUMMARY;LANGUAGE=en-US:Declined: [Appointment]';
        // Integer i = s.indexOf('LANGUAGE=en-US:');
        // Integer j = s.indexOf(': [Appointment]');
        // System.debug(s.subString(j - i, j));

        // System.debug('status-[0]->' + status[0]);
        // status = status[1].split(':');
        // System.debug('status-[1]->' + status[0]);
        
        // System.debug('Appointment-->' + app);
        // System.debug('appointmentID-->' + appointmentID);
        // System.debug('emailMessage-->' + emailMessage);
        
        return result;
    }
}