@RestResource(urlMapping = '/bookAppointmentAPI/*')
global without sharing class BookAppointmentAPI {
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        String jsonMetadata = req.requestBody.toString();
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
        System.debug('parsedJson-->' + parsedJson);
        String toolId;
        String appdate = '';
        String providerId = '';
        String name = '';
        String start_time = '';
        String excep = '';
        String gender = '';
        String age = '';
        String email = '';
        String appointmentTypeId = '';
        String groupLocationId = '';
        String categoryId = '';
        String providerTypeId = '';
        String userId = '';
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
                        appdate = (String) arguments.get('date');
                        providerId = (String) arguments.get('providerId');
                        start_time = (String) arguments.get('time');
                        userId = (String) arguments.get('userId');
                        email = (String) arguments.get('email');
                        providerTypeId = (String) arguments.get('providerTypeId');
                        appointmentTypeId = (String) arguments.get('appointmentTypeId');
                        groupLocationId = (String) arguments.get('groupLocationId');
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

        System.debug('appdate-->' + appdate);
        System.debug('providerId-->' + providerId);
        System.debug('start_time-->' + start_time);
        System.debug('userId-->' + userId);
        System.debug('email-->' + email);
        System.debug('providerTypeId-->' + providerTypeId);
        System.debug('appointmentTypeId-->' + appointmentTypeId);
        System.debug('groupLocationId-->' + groupLocationId);
        System.debug('categoryId-->' + categoryId);

        String accountCOnfirmation = '';
        List<String> start_time_parts = start_time.split(' '); // Splits into ['3:01', 'PM']
        String hourMinute = start_time_parts[0]; // '3:01'
        String meridian = start_time_parts[1]; // 'PM'
        // Further split the hour and minute
        List<String> hourMinuteParts = hourMinute.split(':');
        Integer hour = Integer.valueOf(hourMinuteParts[0]); // Extract hour
        Integer minute = Integer.valueOf(hourMinuteParts[1]); // Extract minute
        // Convert to 24-hour format based on AM/PM
        if (meridian == 'PM' && hour != 12) {
            hour += 12;
        } else if (meridian == 'AM' && hour == 12) {
            hour = 0;
        }
        Time appointmentTime = Time.newInstance(hour, minute, 0, 0);
        // Clinic_Resource__c provider = [SELECT Id,Appointment_Type__c,Appointment_Type__r.Resource_Category__c,Clinic_Location__c,Clinic_Location__r.Provider_Company__c,Resource_Type__c,Name FROM Clinic_Resource__c WHERE Id = :providerId];
        Clinic_Location__c groupLocation = [SELECT Id, Provider_Company__c FROM Clinic_Location__c WHERE Id = :groupLocationId];
        String appDuration = [SELECT Id,Duration__c FROM Appointment_Type__c WHERE Id = :appointmentTypeId].Duration__c;
        Integer durationMinutes = Integer.valueOf(appDuration.split(' ')[0]);
        // Calculate End Time
        Time endTime = appointmentTime.addMinutes(durationMinutes);
        Id appointmentRecordTypeId = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Appointment').getRecordTypeId();
        Appointment__c app = new Appointment__c();
        app.RecordTypeId = appointmentRecordTypeId;
        app.Patient_Account__c = userId;
        app.Appointed_Date__c = Date.valueOf(appdate);
        app.Start_Time__c = appointmentTime;
        app.End_Time__c = endTime;
        app.Provider_Company__c = groupLocation.Provider_Company__c;
        app.Clinic_Resource__c = providerId;
        app.Appointment_Type__c = appointmentTypeId;
        app.Resource_Category__c = categoryId;
        app.Clinic_Location__c = groupLocationId;
        app.Resource_Type__c = providerTypeId;
        app.Telehealth__c = 'No';
        // app.Meet_Link_Url__c = '';
        app.From_Vapi__c = true;
        app.Status__c = 'Accepted';
        try {
            insert app;
            app = [SELECT Time_Zone__c FROM Appointment__c WHERE Id = :app.Id LIMIT 1];
            accountConfirmation += 'The Time Zone for the appointment is ' + app.Time_Zone__c;
        } catch (Exception e) {
            excep = e.getMessage();
        }
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.results = new List<ToolResult>();
        // Add logic to populate the response
        if (toolId != null) {
            ToolResult result = new ToolResult();
            result.toolCallId = toolId;
            if(excep != '') {
                result.result = 'Failed to save records';
            } else {
                result.result = 'Appointment Booked and ' + accountConfirmation;
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