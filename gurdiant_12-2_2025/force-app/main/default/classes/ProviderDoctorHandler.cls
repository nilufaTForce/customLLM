public with sharing class ProviderDoctorHandler{
    
    
    public static void duplicateEmail(Account acc){
        String email = acc?.Email__c;
        List<Account> accList = new List<Account>();
        if (email != null){
            accList = [SELECT Id
                       FROM Account
                       where Email__c = :email AND ID != :acc.Id];
        }
        if (!accList.isEmpty()){
            acc.addError('Duplicate email found: ' + accList[0].Id);
        }
    }
    
/*
    @future(callout = true)
    public static void httpCall(String longUrl, String emailID, String name){
        system.debug(longUrl);
        String apiEndpoint = 'https://tinyurl.com/api-create.php?url=' + longUrl;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiEndpoint);
        request.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug('hahh');
        system.debug('hmm' + response.getStatusCode());
        if (response.getStatusCode() == 200){
            system.debug('iii ' + response.getBody()); // Shortened URL


            String body = '';

            body = 'Hi   ' + response.getBody() + '    ' + name + ', <br><br> We are requesting for read access of your outlook calendar with our system. If you agree, please click on the link below: <br>';
            body += '<a href="' + response.getBody() + '" target="__blank">Sync my Outlook Calendar with Salesforce</a>';
            //body += ' <br><br><a href="'+ url + '" style="background-color: #007DFF; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Sync my Outlook Calendar with Salesforce</a><br>';


            // body += '<a href="https://www.google.com" target="__blank">Sync my Outlook Calendar with Salesforce</a>';
            // body = '<a href="https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=0435718d-299b-4c16-9382-edc56963047e&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&state=12345" target="__blank">Sync my Outlook Calendar with Salesforce</a>';


            // Create a new email object
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // Set recipient email addresses
            List<String> toAddresses = new List<String>();
            toAddresses.add(emailID); // Replace with actual recipient's email address
            mail.setToAddresses(toAddresses);
            //OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'araf.tforce@gmail.com' LIMIT 1];
            mail.setOrgWideEmailAddressId('0D2Wr0000000L2rKAE');
            //mail.setBccAddresses(toAddresses2);

            // Set email subject and body
            mail.setSubject('Guardiant Health');
            // mail.setPlainTextBody('Hello, this is a test email sent from Salesforce via Apex!');

            String emailBody = setEmailBody(name);
            System.debug('emailBody---> ' + emailBody);
            // Optional: Set HTML body if you want a richer format
            mail.setHtmlBody('<html><body><h1>Hello!</h1><p>This is a test email sent from Salesforce.</p>' + body + '</body></html>');

            // Send the email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });

            // Check if the email was successfully sent
            if (results[0].isSuccess()){
                System.debug('Email sent successfully to ' + toAddresses[0]);
            } else{
                System.debug('Failed to send email. Error: ' + results[0].getErrors()[0].getMessage());
            }


        } else{
            //    return longUrl;

            System.debug('Error shortening URL: ' + response.getBody());

        }
    }
    */

    public static void sendEmailProviderDoctor(String emailID, String name, Id oweaID){
        Microsoft_Outlook_API__mdt apiCreds = getAPICreds();
        String baseUrl;
        if (emailID != null && emailID.contains('@solve4u.io')) {
            baseUrl = apiCreds.Base_Auth_Url__c + '/' + apiCreds.Tenant_Id__c + '/oauth2/v2.0/authorize';

            // baseUrl = 'https://login.microsoftonline.com/9770ede4-0a7c-46ca-8560-f15e461b0b3a/oauth2/v2.0/authorize';
          
        } else {
            baseUrl = apiCreds.Base_Auth_Url__c +'/oauth2/v2.0/authorize';

            // baseUrl = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
        }
        

     
        // String url = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=' + apiCreds.Client_Id__c + '&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&state=12345';
        String csrf = generateCSRFToken();
        String url = baseUrl+ '?client_id=' + EncodingUtil.urlEncode(apiCreds.Client_Id__c, 'UTF-8') + '&response_type=' + EncodingUtil.urlEncode('code', 'UTF-8') + '&redirect_uri=' + EncodingUtil.urlEncode(apiCreds.Redirect_Url__c, 'UTF-8') + '&response_mode=' + EncodingUtil.urlEncode('query', 'UTF-8') + '&scope=' + EncodingUtil.urlEncode('offline_access Calendars.Read Calendars.ReadWrite User.Read User.Read.All User.ReadBasic.All Directory.Read.All MailboxSettings.Read', 'UTF-8') + '&state=' + csrf;
        // String url = baseUrl+ '?client_id=' + EncodingUtil.urlEncode('0435718d-299b-4c16-9382-edc56963047e', 'UTF-8') + '&response_type=' + EncodingUtil.urlEncode('code', 'UTF-8') + '&redirect_uri=' + EncodingUtil.urlEncode('https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService', 'UTF-8') + '&response_mode=' + EncodingUtil.urlEncode('query', 'UTF-8') + '&scope=' + EncodingUtil.urlEncode('offline_access Calendars.Read Calendars.ReadWrite User.Read User.Read.All User.ReadBasic.All Directory.Read.All MailboxSettings.Read', 'UTF-8') + '&state=' + csrf;
        // httpCall(url, emailID, name);

        String body = '';

        body = 'Hi ' + name + ', <br><br> We are requesting for read access of your outlook calendar with our system. If you agree, please click on the link below: <br>';
        body += '<a href="' + url + '" target="__blank">Sync my Outlook Calendar with Salesforce</a>';
        //body += ' <br><br><a href="'+ url + '" style="background-color: #007DFF; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Sync my Outlook Calendar with Salesforce</a><br>';

        // body += '<a href="https://www.google.com" target="__blank">Sync my Outlook Calendar with Salesforce</a>';
        // body = '<a href="https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=0435718d-299b-4c16-9382-edc56963047e&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&state=12345" target="__blank">Sync my Outlook Calendar with Salesforce</a>';

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> toAddresses = new List<String>();
        toAddresses.add(emailID);

        mail.setSubject('Guardiant Health');
        mail.setToAddresses(toAddresses);
        // mail.setReplyTo('araf.tforce@gmail.com');
        // OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'araf.tforce@gmail.com' LIMIT 1];
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
            
 
        mail.setOrgWideEmailAddressId(owea.Id);
        // mail.setOrgWideEmailAddressId('0D2Wr0000000NavKAE');
        // mail.setOrgWideEmailAddressId(owea.Id);
        if(oweaID != null){
            // mail.setOrgWideEmailAddressId(oweaID);
        }



        // String emailBody = setEmailBody(name);
        mail.setHtmlBody('<html><body>' + body + '</body></html>');
        // mail.setPlainTextBody('asdasdas');
        // mail.setHtmlBody('<html><body><p>Hi there! <br> It looks like the email is working fine!</p></body></html>');

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });

        if (results[0].isSuccess()){
            System.debug('Email-url-> ' + url);
            System.debug('Email sent successfully from ' + mail.getOrgWideEmailAddressId());
        } else{
            System.debug('Failed to send email. Error: ' + results[0].getErrors()[0].getMessage());
        }
    }

    /*
     public static void sendEmailProviderDoctor2(String emailID, String name){

     String body = '';
     Microsoft_Outlook_API__mdt apiCreds = getAPICreds();
     String url = 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=' + apiCreds.Client_Id__c + '&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&state=12345';
     // String encodedUrl = EncodingUtil.urlEncode(url, 'UTF-8');
     // System.debug('encodedUrl-->' + encodedUrl);


     // body = 'Hello ' + name + ', <br><br> We are requesting for read access of your outlook calendar with our system. If you agree, please click on the link below: <br>';
     body = 'Hello ' + name + ', <br><br> We are requesting for read access of your outlook calendar with our system. If you agree, please click on the link below: <br>';
     body += '<a href="' + url + '" target="__blank">Sync my Outlook Calendar with Salesforce</a>';

     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
     email.setToAddresses(new List<String>{ emailID });
     email.setSubject('Guardiant Health');
     email.setSenderDisplayName('Guardiant Health');

     // String emailBody = setEmailBody(name);
     System.debug('body--->' + body);
     // String emailBody = 'setEmailBody(name)';
     email.setReplyTo('support@solve4u.io');
     // email.setToAddresses(new String[] {'support@solve4u.io'});
     email.setHtmlBody('<html><body><p>This is an email</p></body></html>');

     Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
     // System.debug('OAuth email has been sent-->' + emailID + '\n' + results[0]);
     }
     */
    private static String setEmailBody(String name){
        String body = '';
        Microsoft_Outlook_API__mdt apiCreds = getAPICreds();
        //do not delete
       // String url = 'https://login.microsoftonline.com/9770ede4-0a7c-46ca-8560-f15e461b0b3a/oauth2/v2.0/authorize?client_id=' + apiCreds.Client_Id__c + '&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&prompt=admin_consent&state=12345';
        
        
        // String url = apiCreds.Base_Auth_Url__c + '/' + apiCreds.Tenant_Id__c + '/oauth2/v2.0/authorize' +
        // '?client_id=' + EncodingUtil.urlEncode(apiCreds.Client_Id__c, 'UTF-8') +
        // '&response_type=' + EncodingUtil.urlEncode('code', 'UTF-8') +
        // '&redirect_uri=' + EncodingUtil.urlEncode(apiCreds.Redirect_Url__c, 'UTF-8') +
        // '&response_mode=' + EncodingUtil.urlEncode('query', 'UTF-8') +
        // '&scope=' + EncodingUtil.urlEncode('offline_access Calendars.Read User.Read User.Read.All User.ReadBasic.All Directory.Read.All', 'UTF-8') +
        // '&prompt=' + EncodingUtil.urlEncode('admin_consent', 'UTF-8') +
        // '&state=' + EncodingUtil.urlEncode('12345', 'UTF-8');
        String url = apiCreds.Base_Auth_Url__c + '/' + apiCreds.Tenant_Id__c + '/oauth2/v2.0/authorize' +
        '?client_id=' + apiCreds.Client_Id__c +
        '&response_type=code' +
        '&redirect_uri=' + apiCreds.Redirect_Url__c + // No Encoding Here
        '&response_mode=query' +
        '&scope=' + EncodingUtil.urlEncode('offline_access Calendars.Read User.Read User.Read.All User.ReadBasic.All Directory.Read.All', 'UTF-8').replace('+', '%20') +
        '&prompt=admin_consent' +
        '&state=12345';

        // String encodedUrl = EncodingUtil.urlEncode(url, 'UTF-8');
        // System.debug('encodedUrl-->' + encodedUrl);
       // String url = 'https://login.microsoftonline.com/9770ede4-0a7c-46ca-8560-f15e461b0b3a/oauth2/v2.0/authorize?client_id=' + apiCreds.Client_Id__c + '&response_type=code&redirect_uri=https://guardiant--willg.sandbox.my.site.com/services/apexrest/OAuthApiService&response_mode=query&scope=offline_access%20Calendars.Read%20User.Read%20User.Read.All%20User.ReadBasic.All%20Directory.Read.All&prompt=admin_consent&state=12345';
        // String encodedUrl = EncodingUtil.urlEncode(url, 'UTF-8');
        // System.debug('encodedUrl-->' + encodedUrl);


        // body = 'Hello ' + name + ', <br><br> We are requesting for read access of your outlook calendar with our system. If you agree, please click on the link below: <br>';
        body = '<a href="' + url + '" target="__blank">Sync my Outlook Calendar with Salesforce</a>';
        // body += '<a href="'+ url + '" target="__blank">Sync my Outlook Calendar with Salesforce</a>';
        // body += ' <br><br><a href="'+ url + '" style="background-color: #007DFF; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Sync my Outlook Calendar with Salesforce</a><br>';

        return body;
    }

    private static String generateCSRFToken(){
        Blob randomBlob = Crypto.generateAesKey(256);
        String token = EncodingUtil.convertToHex(randomBlob);

        return token;
    }

    private static Microsoft_Outlook_API__mdt getAPICreds(){
        return [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Base_Auth_Url__c,Redirect_Url__c
                FROM Microsoft_Outlook_API__mdt
                WHERE DeveloperName = 'Outlook_API_Settings'
                LIMIT 1];
    }

}