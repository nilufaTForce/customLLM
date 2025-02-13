@RestResource(urlMapping = '/CheckUserExistanceAPI/*')
    global without sharing class CheckUserExistanceAPI {
        @HttpPost
        global static void postHandler(){
            RestRequest req = RestContext.request;
            String jsonMetadata = req.requestBody.toString();
            System.debug('Json meta data: ' + jsonMetadata);
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
            System.debug('parsedJson-->' + parsedJson);
            String toolId;
            String name = '';
            String excep = '';
            String gender = '';
            String age = '';
            String email = '';
            String phone = '';
            String dob = '';
            // Create the JSON dynamically
            if (parsedJson.containsKey('message')) {
                Map<String, Object> message = (Map<String, Object>) parsedJson.get('message');
                
                // Check if toolCalls exists within the message object
                if (message.containsKey('toolCalls')) {
                    List<Object> toolCalls = (List<Object>) message.get('toolCalls');
                    
                    if (!toolCalls.isEmpty()) {
                        // Extract the first toolCall
                        Map<String, Object> toolCall = (Map<String, Object>) toolCalls[0];
                        toolId = (String) toolCall.get('id');
                        Map<String, Object> function = (Map<String, Object>) toolCall.get('function');
                        if (function != null && function.containsKey('arguments')) {
                            Map<String, Object> arguments = (Map<String, Object>) function.get('arguments');
                            email = (String) arguments.get('email');
                            name = (String) arguments.get('name');
                            age = (String) arguments.get('age');
                            phone = (String) arguments.get('phone');
                            dob  = (String) arguments.get('date_of_birth');
                            
                        }
                        // Extract the ID
                        
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
        String accountConfirmation = '';
        if((email == '' || email == null) &&  (phone == '' || phone == null)){
            // String accountConfirmation = '';
            Date convertedDate = Date.valueOf(dob);
            Account newAccount;
            
            List<Account> accounts = [SELECT Id, Name, Email__c, Phone, Gender__c, Age__c, Date_Of_Birth__c FROM Account WHERE Name = :name  AND Date_Of_Birth__c = :convertedDate];
            if (!accounts.isEmpty()) {
                newAccount = accounts[0];
                accountConfirmation = 'Welcome back, ' + newAccount.Name + '(' + newAccount.Id + ')[User ID].  We hope you are well.';
            }else{
                
                accountConfirmation = 'No Account found.';
            }
        }else{
            Account newAccount;
            List<Account> existingAccount = [SELECT Id, Name, Email__c, Phone, Gender__c, Age__c, Date_Of_Birth__c FROM Account WHERE Phone = :phone LIMIT 1];
            if(!existingAccount.isEmpty()){
                newAccount = existingAccount[0];
                accountConfirmation = 'Account Found. Here is the user Id ->' + '(' + newAccount.Id + ').  Welcome back to Guardant';
                if(newAccount.Email__c == null || newAccount.Email__c == ''){
                    accountConfirmation += '\nYou have not given an email yet. Please provide your email to receive updated patient appointment details.';
                }
            } else{
                Date convertedDate = Date.valueOf(dob);
                newAccount = new Account(
                    Name = name,
                Date_Of_Birth__c = convertedDate,
                Email__c = email,
                Phone = phone  );
                
                try {
                    insert newAccount;
                    newAccount = [SELECT Id FROM Account WHERE Id = :newAccount.Id];
                    accountConfirmation = 'Account Created. Here is the user Id ->' + '(' + newAccount.Id + ').  Welcome to Guardant';
                } catch (DmlException e) {
                    System.debug('Error creating Account: ' + e.getMessage());
                    accountConfirmation = 'Failed to create account.';
                }
            }
        }
        
        
        
        
        // Example of creating the dynamic JSON response
        ResultWrapper wrapper = new ResultWrapper();
        
        // Add logic to populate the response
        if (toolId != null) {
            ToolResult result = new ToolResult();
            result.toolCallId = toolId;
            result.result = accountConfirmation;
            System.debug(result);
            wrapper.results.add(result);
        } else {
            ToolResult result = new ToolResult();
            result.toolCallId = null;
            result.result = 'Failed: Tool ID not provided. Failed';
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