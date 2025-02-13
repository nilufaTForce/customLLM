@RestResource(urlMapping = '/getProviderTypeAPI/*')
    global without sharing class GetProvideTypesAPI {
        @HttpPost
        global static void postHandler(){
            RestRequest req = RestContext.request;
            String jsonMetadata = req.requestBody.toString();
            System.debug('Json meta data: ' + jsonMetadata);
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
            System.debug('parsedJson-->' + parsedJson);
            String toolId;
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
                    // }
                } else {
                    System.debug('No toolCalls found.');
                }
            } else {
                System.debug('toolCalls not found within message.');
            }
        } else {
            System.debug('message key not found.');
        }
        List<Resource_Category__c> resourceCategories = [SELECT Id, Name FROM Resource_Category__c];
        
        // Query all Appointment Types and Provider Types for the distinct Resource Categories
        List<Appointment_Type__c> apptTypes = [SELECT Id, Name, Resource_Category__c FROM Appointment_Type__c WHERE Resource_Category__c IN :resourceCategories];
        List<Resource_Type__c> providerTypes = [SELECT Id, Name, Resource_Category__c FROM Resource_Type__c WHERE Resource_Category__c IN :resourceCategories];
        
        // Maps to store Appointment Types and Provider Types by Resource Category
        Map<Id, List<Appointment_Type__c>> categoryToApptTypes = new Map<Id, List<Appointment_Type__c>>();
        Map<Id, List<Resource_Type__c>> categoryToProviderTypes = new Map<Id, List<Resource_Type__c>>();
        
        // Populate the maps
        for (Appointment_Type__c apptType : apptTypes) {
            if (!categoryToApptTypes.containsKey(apptType.Resource_Category__c)) {
                categoryToApptTypes.put(apptType.Resource_Category__c, new List<Appointment_Type__c>());
            }
            categoryToApptTypes.get(apptType.Resource_Category__c).add(apptType);
        }
        
        for (Resource_Type__c providerType : providerTypes) {
            if (!categoryToProviderTypes.containsKey(providerType.Resource_Category__c)) {
                categoryToProviderTypes.put(providerType.Resource_Category__c, new List<Resource_Type__c>());
            }
            categoryToProviderTypes.get(providerType.Resource_Category__c).add(providerType);
        }
        
        // Build the required string
        String resultString = '';
        Integer categoryCounter = 1;
        
        for (Resource_Category__c resourceCategory : resourceCategories) {
            List<Appointment_Type__c> apptTypeList = categoryToApptTypes.get(resourceCategory.Id);
            List<Resource_Type__c> providerTypeList = categoryToProviderTypes.get(resourceCategory.Id);
            
            String apptTypeString = '';
            if (apptTypeList != null && !apptTypeList.isEmpty()) {
                for (Integer i = 0; i < apptTypeList.size(); i++) {
                    apptTypeString += (i + 1) + '. ' + apptTypeList[i].Name + '(' + apptTypeList[i].Id + ')';
                    if (i < apptTypeList.size() - 1) {
                        apptTypeString += ', ';
                    }
                }
            } else {
                apptTypeString = 'No Appointment Types';
            }
            
            String providerTypeString = '';
            if (providerTypeList != null && !providerTypeList.isEmpty()) {
                for (Integer i = 0; i < providerTypeList.size(); i++) {
                    providerTypeString += (i + 1) + '. ' + providerTypeList[i].Name + '(' + providerTypeList[i].Id + ')';
                    if (i < providerTypeList.size() - 1) {
                        providerTypeString += ', ';
                    }
                }
            } else {
                providerTypeString = 'No Provider Types';
            }
            
            // Append to result string
            resultString += categoryCounter + '. ' + resourceCategory.Name + '(' + resourceCategory.Id + ')' +
                ' [Care Category] -> (' + apptTypeString + ') [Appointment Types], (' + providerTypeString + ') [Provider Types].\n';
            
            categoryCounter++;
        }
        
        // Output the final result string
        System.debug('Result String: ' + resultString);
        
        // Example of creating the dynamic JSON response
        ResultWrapper wrapper = new ResultWrapper();
        
        if (toolId != null) {
            ToolResult result = new ToolResult();
            result.toolCallId = toolId;
            result.result = 'Care Category -> Appointment Types & Provider Types with Ids in Brackets\n' +
                resultString + '\n. And Current Date is ' + Date.today() + ' And Current Day is ' + DateTime.now().format('EEEE');
            System.debug(result);
            wrapper.results.add(result);
        } else {
            ToolResult result = new ToolResult();
            result.toolCallId = null;
            result.result = 'Failed: Tool ID not provided. Available types: ' + resultString;
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