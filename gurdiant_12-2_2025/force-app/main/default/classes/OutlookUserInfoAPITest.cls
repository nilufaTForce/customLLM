@isTest
private class OutlookUserInfoAPITest {
    
 // Mock class for simulating HTTP response
 private class MockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id": "12345", "mail": "user@example.com"}');
        res.setStatusCode(200);
        return res;
    }
}

@isTest
static void testUpdateSubUserId() {
 
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    
    String testAccessToken = 'dummyAccessToken';
    
    String result = OutlookUserInfoAPI.updateSubUserId(testAccessToken);

    List<String> resultParts = result.split('::');
    
}
}