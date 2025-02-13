// @RestResource(urlMapping='/guardiantAPI2/*')
global without sharing class APIService2 {

    // @HttpPost
    // global static String handlePost() {
    //     RestRequest req = RestContext.request;

    //     String jsonMetadata = req.requestBody.toString();
        
    //     System.debug('Request Found Request-->' + JSON.serializePretty(req));
    //     System.debug('Request Found jsonMetadata-->' + JSON.serializePretty(jsonMetadata));

    //     // Create the JSON dynamically
    //     ResultWrapper wrapper = new ResultWrapper();
    //     wrapper.results = new List<ToolResult>();
        
    //     // Add a result
    //     ToolResult result = new ToolResult();
    //     result.toolCallId = 'Call-Id';
    //     result.result = 'Age of the doctor is 10';
    //     wrapper.results.add(result);

    //     String jsonOutput = JSON.serialize(wrapper);

    //     RestResponse res = RestContext.response;
    //     res.statusCode = 200;
    //     // res.responseBody = Blob.valueOf(jsonOutput);

    //     return jsonOutput;
    // }

    // @HttpGet
    // global static void handleGet() {
    //     RestResponse res = RestContext.response;        
    //     res.statusCode = 200;
    // }


    // // Define the main wrapper class
    // public class ResultWrapper {
    //     public List<ToolResult> results;
    // }
    
    // // Define the ToolResult class separately
    // public class ToolResult {
    //     public String toolCallId;
    //     public String result;
    // }

}