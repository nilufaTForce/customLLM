@isTest
global class AccessTokenHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Fake token response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token": "mockAccessToken", "expires_in": 3600}');
        res.setStatusCode(200);
        return res;
    }
}