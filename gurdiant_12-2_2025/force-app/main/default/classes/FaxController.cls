public with sharing class FaxController {
    
    private static String getAccessToken(){
 
        // if (!Cache.Org.contains('ringcentralAccessToken')) {
            Ringcentral_Credentials__c rc = Ringcentral_Credentials__c.getOrgDefaults();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(rc.API_Url__c + '/restapi/oauth/token');
            req.setMethod('POST');
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(rc.App_Key__c + ':' + rc.App_Secret__c));
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
            req.setBody('grant_type=password&username=' + rc.Username__c + '&extension=' + rc.Extension__c + '&password=' + rc.Password__c);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Map<String, String> responseData = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
            String accessToken = responseData.get('access_token');
            //   Cache.Org.put('ringcentralAccessToken', accessToken, Integer.valueOf(responseData.get('expires_in')));
            return accessToken;
        // }
        // return null;
        // return String.valueOf(Cache.Org.get('ringcentralAccessToken'));
        
    }
    
    @AuraEnabled(cacheable=false)
    public static String sendFaxAction(String leadId) {
        Lead leadRecord = [Select Id, FAX_REPORT_TO__c from Lead Where Id =: leadId];
        String receiverFaxNumber = '+1' + leadRecord.FAX_REPORT_TO__c.replaceAll('[^0-9]', '');
        ContentDocument pdfDocument = [SELECT LatestPublishedVersionId FROM ContentDocument];
        ContentVersion pdfVersion = [select Id, Title, ContentDocumentId, FileExtension, versionData from ContentVersion where Id = :pdfDocument.LatestPublishedVersionId limit 1];
        string fileName = pdfVersion.Id;
        if (pdfVersion.FileExtension != null && pdfVersion.FileExtension != ''){
            fileName = fileName + '.' + pdfVersion.FileExtension;
        }        
        string contentType = EinsteinVision_HttpBodyPart.GetContentType();
        //  Compose the form
        string form64 = '';
        form64 += EinsteinVision_HttpBodyPart.WriteBoundary();
        form64 += EinsteinVision_HttpBodyPart.WriteBodyParameter('to', receiverFaxNumber);
        form64 += EinsteinVision_HttpBodyPart.WriteBoundary();
        form64 += EinsteinVision_HttpBodyPart.WriteBodyParameter('coverIndex', '0');
        form64 += EinsteinVision_HttpBodyPart.WriteBoundary();
        form64 += EinsteinVision_HttpBodyPart.WriteBlobBodyParameter('attachment', EncodingUtil.base64Encode(pdfVersion.versionData), fileName);
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        Ringcentral_Credentials__c rc = Ringcentral_Credentials__c.getOrgDefaults();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(rc.API_Url__c + '/restapi/v1.0/account/~/extension/~/fax');
        req.setMethod('POST');
        String authorizationHeader = 'Bearer ' + getAccessToken();
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Length', contentLength);
        req.setHeader('Content-Type', contentType);
        req.setTimeout(120000);
        req.setBodyAsBlob(formBlob);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        return 'done';
    }
}