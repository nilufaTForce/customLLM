@RestResource(urlMapping = '/cancelOrReschuduleAppointment/*')
    global without sharing class cancelOrReschuduleAppointment {
        
        @HttpPost
        global static void manageAppointment() {
            RestRequest req = RestContext.request;
            String jsonMetadata = req.requestBody.toString();
            System.debug('Json meta data: ' + jsonMetadata);
            Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
            System.debug('parsedJson-->' + parsedJson);
            
            String name ='';
            String userId ='';
            String startTimeStr = '';   // Example: "10:20 PM"
            String appointedDateStr ='';
            String appointedDateOldStr ='';
            String startTimeOldStr = ''; // Example: "03:15 AM"
            String actionType = '';
            String toolId = '';
            String reason = '';
            String email = '';
            String accountConfirmation = '';
            
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
                            name = (String) arguments.get('name');
                            email = (String) arguments.get('email');
                            userId = (String) arguments.get('userId');
                            startTimeStr = (String) arguments.get('startTime');   // Example: "10:20 PM"
                            appointedDateStr = (String) arguments.get('appointedDate');
                            appointedDateOldStr = (String) arguments.get('appointedDateOld');
                            startTimeOldStr = (String) arguments.get('startTimeOld'); // Example: "03:15 AM"
                            actionType = (String) arguments.get('actionType');
                            reason = (String) arguments.get('reason');
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
        
        
        // Convert Date fields
        // Date dob = String.isNotBlank(dobStr) ? Date.valueOf(dobStr) : null;
        Date appointedDateOld = String.isNotBlank(appointedDateOldStr) ? Date.valueOf(appointedDateOldStr) : null;
        Date appointedDate = String.isNotBlank(appointedDateStr) ? Date.valueOf(appointedDateStr) : null;
        
        
        // Convert Time fields
        Time startTimeOld = String.isNotBlank(startTimeOldStr) ? parseTime(startTimeOldStr) : null;
        Time startTime = String.isNotBlank(startTimeStr) ? parseTime(startTimeStr) : null;
        Account patient = getPatient(userId, email);
        
        
        
        if (patient == null) {
            accountConfirmation = 'Patient not found , Provide valid name and date of birth.';
        }else{
            Id patientId = patient.Id;
            List<Appointment__c> appointments = [
                SELECT Id, Start_Time__c, End_Time__c, Appointed_Date__c, Status__c, Clinic_Resource__r.Name , Location_Text__c, Appointment_Type__c, Resource_Type__c, Clinic_Location__c
                FROM Appointment__c 
                WHERE Patient_Account__c = :patientId 
                AND Start_Time__c = :startTimeOld 
                AND Appointed_Date__c = :appointedDateOld
                LIMIT 1
            ];
            
            if (appointments.isEmpty()) {
                accountConfirmation = 'No appointment found.';
            }else{
                
                Appointment__c appointment = appointments[0];
                // String result;
                
                if (actionType == 'cancel') {
                    appointment = cancelAppointment(appointment);
                    accountConfirmation = 'Appointment cancelled successfully.';
                    update appointment;
                } else if (actionType == 'Reschedule') {
                    if(appointedDate == null && startTime == null) {
                        Datetime currentDateTime = System.now();
                        DateTime oldAppointmentDateTime = Datetime.newInstance(appointedDateOld, startTimeOld);
                        Boolean isWithin24Hours = false;
                        if (oldAppointmentDateTime != null) {
                            Datetime twentyFourHoursAgo = currentDateTime.addHours(-24);
                            isWithin24Hours = oldAppointmentDateTime >= twentyFourHoursAgo;
                        }
                        accountConfirmation = 'Appintment Found. Appointment Date: ' + appointment.Appointed_Date__c + '. Start Time: ' + appointment.Start_Time__c + '. Provider Name: ' + appointment.Clinic_Resource__r.Name + '. Location: ' + appointment.Location_Text__c + ', And here is the appointment details --> (' + appointment.Resource_Type__c + ')[Provider type Id], (' + appointment.Appointment_Type__c + ')[Appointment Type Id], (' + appointment.Clinic_Location__c + ')[Group Location Id]';
                        if (!isWithin24Hours) {
                            accountConfirmation += ' Appointment can only be rescheduled within 24 hours of the original appointment.';
                        }
                    } else {
                        // If date is '', use the old date. If time is '', use the previous time.
                        Date finalAppointedDate = (appointedDate != null) ? appointedDate : appointment.Appointed_Date__c;
                        Time finalStartTime = (startTime != null) ? startTime : appointment.Start_Time__c;
                        
                        appointment = rescheduleAppointment(appointment, finalStartTime, finalAppointedDate, reason);
                        accountConfirmation = 'Appointment successfully rescheduled.';
                        update appointment;
                    }
                    
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
            result.result = 'Failed: Tool ID not provided. Failed. ';
            wrapper.results.add(result);
        }
        
        // Serialize to JSON
        String jsonOutput = JSON.serialize(wrapper);
        System.debug(jsonOutput);
        
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(jsonOutput);
        // returnSuccess(toolId, result);
    }
    
    public static Account getPatient(String userId, String email) {
        List<Account> patients = [
            SELECT Id, Name, Email__c 
            FROM Account 
            WHERE Id = :userId LIMIT 1
        ];
        if (patients.isEmpty()) {
            return null;
        } else {
            System.debug('patient email before if : ' + patients[0].Email__c);
            if(patients[0].Email__c == null || patients[0].Email__c == '') {
                System.debug('patients email: ' + patients[0].Email__c);
                patients[0].Email__c = email;
                update patients[0];
            }
            return patients[0];
        }
    }
    
    public static Appointment__c rescheduleAppointment(Appointment__c appointment, Time startTime, Date appointedDate, String reason) {
        if (appointment.Status__c == 'Cancelled') {
            throw new AuraHandledException('Cannot reschedule a cancelled appointment.');
        }
        System.debug('appointment date: ' + appointment.Appointed_Date__c + ' new date: ' + appointedDate);
        Integer startMinutes = (appointment.Start_Time__c.hour() * 60) + appointment.Start_Time__c.minute();
        Integer endMinutes = (appointment.End_Time__c.hour() * 60) + appointment.End_Time__c.minute();
        appointment.Start_Time__c = startTime;
        appointment.End_Time__c = startTime.addMinutes(endMinutes - startMinutes);
        appointment.Appointed_Date__c = appointedDate;
        appointment.Description__c = reason;
        return appointment;
    }
    
    public static Appointment__c cancelAppointment(Appointment__c appointment) {
        if (appointment.Status__c == 'Cancelled') {
            throw new AuraHandledException('Appointment already cancelled.');
        }
        appointment.Status__c = 'Cancelled';
        return appointment;
    }
    
    // Helper function to parse time in "hh:mm a" format (e.g., "10:20 PM")
    public static Time parseTime(String timeStr) {
        if (timeStr == null || timeStr == '') {
            return null;
        }
        
        List<String> parts = timeStr.split(' ');
        if (parts.size() != 2) {
            throw new IllegalArgumentException('Invalid time format: ' + timeStr);
        }
        
        String timePart = parts[0]; // "10:20"
        String period = parts[1];   // "AM" or "PM"
        
        List<String> timeValues = timePart.split(':');
        if (timeValues.size() != 2) {
            throw new IllegalArgumentException('Invalid time format: ' + timeStr);
        }
        
        Integer hours = Integer.valueOf(timeValues[0]);
        Integer minutes = Integer.valueOf(timeValues[1]);
        Integer seconds = 0; // Defaulting seconds to 0
        
        if (period == 'PM' && hours != 12) {
            hours += 12;
        } else if (period == 'AM' && hours == 12) {
            hours = 0;
        }
        
        return Time.newInstance(hours, minutes, seconds, 0);
    }
    
    public static void returnSuccess(String toolId, String result) {
        ToolResult response = new ToolResult();
        response.toolCallId = toolId;
        response.result = result;
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    public static void returnError(String toolId, String errorMessage) {
        ToolResult response = new ToolResult();
        response.toolCallId = toolId;
        response.result = 'Error: ' + errorMessage;
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    public class ResultWrapper {
        public List<ToolResult> results = new List<ToolResult>(); // Initialize the list
    }
    
    public class ToolResult {
        public String toolCallId;
        public String result;
    }
}