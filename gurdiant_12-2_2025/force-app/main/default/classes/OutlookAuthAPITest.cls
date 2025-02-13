@isTest
private class OutlookAuthAPITest {

    @isTest
    static void testPostHandler() {
        // Create mock request body
        String requestBody = '{"params": {"validationToken": "sampleValidationToken"}}';

        // Create a mock RestRequest and RestResponse
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestResponse res = new RestResponse();

        // Set the mock request and response in RestContext
        RestContext.request = req;
        RestContext.response = res;

        // Call the postHandler method
        Test.startTest();
        OutlookOAuthAPIService.postHandler();
        Test.stopTest();

        // Assert the response
        System.assertEquals(200, res.statusCode);
        System.assertEquals('sampleValidationToken', res.responseBody.toString());
    }

    // Test GET handler method
    @isTest
    static void testGetHandler() {
        // Create mock request body
        String requestBody = '{"params": {"code": "sampleCode"}}';

        // Create a mock RestRequest and RestResponse
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestResponse res = new RestResponse();

        // Set the mock request and response in RestContext
        RestContext.request = req;
        RestContext.response = res;

        // Call the getHandlers method
        Test.startTest();
        OutlookOAuthAPIService.getHandlers();
        Test.stopTest();

        // Assert the response
        System.assertEquals(200, res.statusCode);
        System.assertEquals('Successfully Authenticated', res.responseBody.toString());
    }

    // Test createOutlookSubscription method (make it public first)
    @isTest
    static void testCreateOutlookSubscription() {
        // Insert an Outlook_Subscribe__c record for testing
        Outlook_Subscribe__c os = new Outlook_Subscribe__c();
        os.Access_Token__c = 'testAccessToken';
        os.Refresh_Token__c = 'testRefreshToken';
        insert os;

        // Call the method
        Test.startTest();
        OutlookOAuthAPIHandler.createOutlookSubscription(os.Id);
        Test.stopTest();

        // Fetch the updated Outlook_Subscribe__c record and assert the subscription
        os = [SELECT Id, Subscribe_ID__c FROM Outlook_Subscribe__c WHERE Id = :os.Id];
        System.assertNotEquals(null, os.Subscribe_ID__c, 'Subscription ID should be populated');
    }
}