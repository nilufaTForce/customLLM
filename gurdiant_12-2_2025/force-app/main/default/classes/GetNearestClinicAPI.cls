@RestResource(urlMapping = '/getNearestClinicAPI/*')
global without sharing class GetNearestClinicAPI {
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        String jsonMetadata = req.requestBody.toString();
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
        System.debug('parsedJson-->' + parsedJson);
        String toolId;
        String streetNumber = '';
        String nameOfAddressLine = '';
        String city = '';
        String state = '';
        String excep = '';
        String categoryId = '';
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
                    Map<String, Object> function = (Map<String, Object>) toolCall.get('function');
                    if (function != null && function.containsKey('arguments')) {
                        Map<String, Object> arguments = (Map<String, Object>) function.get('arguments');
                        streetNumber = (String) arguments.get('streetNumber');
                        nameOfAddressLine = (String) arguments.get('nameOfAddressLine');
                        city = (String) arguments.get('city');
                        state = (String) arguments.get('state');
                        categoryId = (String) arguments.get('categoryId');
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
        String address = '';
        if (streetNumber == '' || streetNumber == null) {
            address = nameOfAddressLine + ', ' + city + ', ' + state;
        } else if ((streetNumber == '' || streetNumber == null) && (nameOfAddressLine == '' || nameOfAddressLine == null)) {
            address = city + ', ' + state;
        } else {
            address = streetNumber + ' ' + nameOfAddressLine + ', ' + city + ', ' + state;
        }
        
        String nearestClinicId = DistanceService.getClosestClinicLocationId(address, categoryId);
        System.debug('Nearest Clinic Id: ' + nearestClinicId);
        Clinic_Location__c nearestClinic = [ SELECT Id, Name, Address__c FROM Clinic_Location__c WHERE Id = :nearestClinicId ];
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.results = new List<ToolResult>();
        // Add logic to populate the response
        if (toolId != null) {
            ToolResult result = new ToolResult();
            result.toolCallId = toolId;
            if(excep != '') {
                result.result = 'Failed to save records';
            } else {
                System.Address tempAddress = nearestClinic.Address__c;
                String formattedAddress = 
                    (tempAddress.getStreet() != null ? tempAddress.getStreet() + ', ' : '') +
                    (tempAddress.getCity() != null ? tempAddress.getCity() + ', ' : '') +
                    (tempAddress.getState() != null ? tempAddress.getState() + ' ' : '') +
                    (tempAddress.getPostalCode() != null ? tempAddress.getPostalCode() + ', ' : '') +
                    (tempAddress.getCountry() != null ? tempAddress.getCountry() : '');
                result.result = 'Ids are in Braces -> Nearest Clinic; ' + nearestClinic.Name + ' (' + nearestClinic.Id + ')' + ' - ' + formattedAddress + ' (clinic address)';
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
    }
    public class ResultWrapper {
        public List<ToolResult> results = new List<ToolResult>(); // Initialize the list
    }
    
    public class ToolResult {
        public String toolCallId;
        public String result;
    }
}