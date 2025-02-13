@RestResource(urlMapping = '/guardiantAPI/*')
global without sharing class APIService{

    // HTTP POST method to handle cancellation of appointments
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        
        String jsonMetadata = req.requestBody.toString();
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
        System.debug('parsedJson-->' + parsedJson);
        String toolId;
        String name = 'Anonymous';
         String age = '';
         String excep = '';
        // Create the JSON dynamically
        if (parsedJson.containsKey('message')) {
            Map<String, Object> message = (Map<String, Object>) parsedJson.get('message');
            
            // Check if toolCalls exists within the message object
            if (message.containsKey('toolCalls')) {
                List<Object> toolCalls = (List<Object>) message.get('toolCalls');
                
                if (!toolCalls.isEmpty()) {
                    // Extract the first toolCall
                    Map<String, Object> toolCall = (Map<String, Object>) toolCalls[0];
        
                    // Extract the ID
                    toolId = (String) toolCall.get('id');
                    System.debug('Tool ID: ' + toolId);
        
                    Map<String, Object> function = (Map<String, Object>) toolCall.get('function');
                    if (function != null && function.containsKey('arguments')) {
                        Map<String, Object> arguments = (Map<String, Object>) function.get('arguments');
                        name = (String) arguments.get('name');
                        age = (String) arguments.get('age');
                    }
                } else {
                    System.debug('No toolCalls found.');
                }
            } else {
                System.debug('toolCalls not found within message.');
            }
        } else {
            System.debug('message key not found.');
        }
         Temp_App__c tempApp = new Temp_App__c();
         tempApp.Name = name;
         tempApp.Age__c = Integer.valueOf(age);
         try {
            insert tempApp;
         } catch(Exception e) {
             System.debug('Error inserting the record');
             excep = e.getMessage();
         }
         

         // Example of creating the dynamic JSON response
         ResultWrapper wrapper = new ResultWrapper();
         wrapper.results = new List<ToolResult>();

         // Add logic to populate the response
         if (toolId != null) {
             ToolResult result = new ToolResult();
             result.toolCallId = toolId;
             if(excep != '') {
                result.result = 'Failed to save records';
             } else {
                result.result = 'Data saved';
             }
             wrapper.results.add(result);
         } else {
             ToolResult result = new ToolResult();
             result.toolCallId = null;
             result.result = 'Failed: Tool ID not provided.';
             wrapper.results.add(result);
         }
        
        // Serialize to JSON
        String jsonOutput = JSON.serialize(wrapper);
        System.debug(jsonOutput);

        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(jsonOutput);
        // return jsonOutput;
        /*
        // Assuming the request body is a single appointment ID
        Id appointmentId;
        Map<String, Object> jsonMap;
        try {
            // appointmentId = (Id) JSON.deserialize(jsonMetadata, String.class);
            jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
            appointmentId = (Id) jsonMap.get('appointmentId');
            
        } catch (Exception e) {
            return 'Invalid JSON format or Appointment ID';
        }
        
        List<Appointment__c> appList = [SELECT Id, Status__c FROM Appointment__c WHERE Id = :appointmentId AND Status__c = 'Accepted'];
        
        
        if (appList.isEmpty()) {
            return 'Your Appointment has already been cancelled.';
        }
        
        appList[0].Status__c = 'Cancelled';
        //  appList[0].Description__c = jsonMetadata;
        Database.update(appList, true);
        return 'Your appointment has been cancelled';
        */
        
    }
    
    // HTTP GET method to handle actions related to appointments
    @HttpGet
    global static String appointmentActionHandler(){
        RestRequest req = RestContext.request;
        String recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        System.debug('Request Found-->' + JSON.serializePretty(req));
        //List<Appointment__c> appList = [SELECT Id, Status__c FROM Appointment__c WHERE Id = :recordId];
        
        
        // Create the JSON dynamically
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.results = new List<ToolResult>();
        
        // Add a result
        ToolResult result = new ToolResult();
        result.toolCallId = 'Call-Id';
        result.result = 'Sample reply result';
        wrapper.results.add(result);
        
        // Serialize to JSON
        String jsonOutput = JSON.serialize(wrapper);
        System.debug(jsonOutput);

        return jsonOutput;
        // return cancelAppointment(recordId);
        //return 'Req params '+ req + '\nRecord ID ' + recordId + '\nApplist ' + appList + '\nSuccess';
        
        
        
        // System.debug('RestContext.request-->' + req);
        // return JSON.serialize(req);
        
        /*String accessToken = '';
        if (String.isEmpty(recordId)) {
            return 'Invalid URL';
        }
        
        accessToken = getAccessToken();
        
        return cancelAppointment(accessToken, recordId);*/
    }
    
    // Method to cancel an appointment via an external API
    private static String cancelAppointment( String recordId){
        if (String.isEmpty(recordId)){
            return 'Invalid record ID';
        }
        List<Appointment__c> appList = [SELECT Id, Name, Clinic_Resource__r.Name, Clinic_Resource__r.Email__c, Status__c FROM Appointment__c WHERE Id = :recordId LIMIT 1];
        if (appList.isEmpty()) {
            return 'No appointment found with the provided IDs';
        }
        Appointment__c appointment = appList[0];
        appointment.Status__c = 'Cancelled';
        Database.update(appointment, true);
        
        return 'Your appointment has been cancelled.' ;
        /*String endpoint = 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/guardiantAPI/';
        
        // Set up the HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        
        // Set the body for the request (assumes you're sending a JSON body)
        String requestBody = JSON.serialize(new Map<String, String>{ 'appointmentId' => recordId });
        req.setBody(requestBody);
        
        Http http = new Http();
        String response = 'No response';
        
        try{
            // Send the POST request
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200){
                response = res.getBody();
            } else{
                response = 'Failed to make POST request: ' + res.getStatusCode() + ' ' + res.getStatus();
                System.debug('Failed to make POST request: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
        } catch (Exception e){
            response = e.getMessage();
            System.debug('Exception: ' + e.getMessage());
        }
        
        return response;*/
    }
    
    // Method to obtain an access token
    private static String getAccessToken(){
        API_Config__mdt apiConfig = [
            SELECT OAuth_Token_Endpoint__c 
            FROM API_Config__mdt	 
        
            LIMIT 1
        ];
        String endpoint = apiConfig.OAuth_Token_Endpoint__c;
        //do not delete
        //String endpoint = 'https://guardiant--willg.sandbox.my.salesforce.com/services/oauth2/token';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        // Build the request body
        String body = 'grant_type=password' +
            '&client_id=3MVG9o0Rj_GRmEuhgJGdYiecC4nWCNc_UD._J25IceU_2FbirBJKBrL.FpKCBiWFUQOrSPnurqc7ZUfx9W29n' +
            '&client_secret=1B0E6BBF115C6813EF945C2E45F4E2393CB714E60D42EB5797EA3D78BB06BD6F' +
            '&username=saiful.lightcode@gradiant.com' +
            '&password=Salesforce2024@';
        
        req.setBody(body);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200){
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        } else{
            System.debug('Failed to obtain access token: ' + res.getBody());
            return null;
        }
    }
    // Define the main wrapper class
    public class ResultWrapper {
        public List<ToolResult> results;
    }
    
    // Define the ToolResult class separately
    public class ToolResult {
        public String toolCallId;
        public String result;
    }
    
}