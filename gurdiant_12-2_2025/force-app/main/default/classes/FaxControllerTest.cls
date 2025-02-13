@isTest
public class FaxControllerTest {

    @testSetup
    static void setup() {
        // Setup Ringcentral_Credentials__c object with mock data
        Ringcentral_Credentials__c rc = new Ringcentral_Credentials__c(
            API_Url__c = 'https://api.ringcentral.com',
            App_Key__c = 'mockAppKey',
            App_Secret__c = 'mockAppSecret',
            Username__c = 'mockUsername',
            Extension__c = 'mockExtension',
            Password__c = 'mockPassword'
        );
        insert rc;

        // Create a Lead record with a fax number
        Lead leadRecord = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            FAX_REPORT_TO__c = '(555) 123-4567'
        );
        insert leadRecord;

        // Create a ContentDocument and ContentVersion to simulate the PDF
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test PDF',
            PathOnClient = 'TestPDF.pdf',
            VersionData = Blob.valueOf('Test PDF Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Simulate the attachment to a document by linking ContentDocument and Lead
        ContentVersion cd = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = leadRecord.Id,
            ContentDocumentId = cd.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
    }

    @isTest
    static void testSendFaxAction() {
        // Mocking HTTP callout
        Test.setMock(HttpCalloutMock.class, new FaxControllerHttpMock());

        // Fetch a Lead record created in the setup
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        // Call the sendFaxAction method
        String result = FaxController.sendFaxAction(testLead.Id);
        Test.stopTest();
    }

    // @isTest
    // static void testGetAccessToken() {
    //     // Mocking HTTP callout for getAccessToken
    //     Test.setMock(HttpCalloutMock.class, new AccessTokenHttpMock());

    //     Test.startTest();
    //     // Simulate calling private method by accessing getAccessToken via reflection
    //     String accessToken = (String) FaxController.class.getDeclaredMethod('getAccessToken').invoke(null);
    //     Test.stopTest();
    // }
}