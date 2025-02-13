@RestResource(urlMapping = '/getAvailabilityAPI/*')
global without sharing class GetAvailabilityAPI {
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        
        String jsonMetadata = req.requestBody.toString();
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
        System.debug('parsedJson-->' + parsedJson);
        String toolId;
        String appdate = '';
        String providerTypeId = '';
        String excep = '';
        String groupLocationId = '';
        String appointmentTypeId = '';
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
                        providerTypeId = (String) arguments.get('providerTypeId');
                        groupLocationId = (String) arguments.get('groupLocationId');
                        appointmentTypeId = (String) arguments.get('appointmentTypeId');
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
        System.debug('Tool ID: ' + JSON.serializePretty(toolId));
        System.debug('Date: ' + appdate);
        System.debug('Provider Type: ' + providerTypeId);
        System.debug('groupLocationId: ' + groupLocationId);
        Date appointmentDate;
        try {
            appointmentDate = Date.valueOf(appdate);
        } catch (Exception e) {
            System.debug('Error parsing date: ' + e.getMessage());
        }
        
        // Example of creating the dynamic JSON response
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.results = new List<ToolResult>();
        List<Resource_Type__c> providerResources = new List<Resource_Type__c>();
        List<Clinic_Location__c> clinicLocation = new List<Clinic_Location__c>();
        Appointment_Type__c apptType = new Appointment_Type__c();
        if (providerTypeId != null) {
            providerResources = [SELECT Id, Name FROM Resource_Type__c WHERE Id = :providerTypeId LIMIT 1];
            clinicLocation = [SELECT Id, Name FROM Clinic_Location__c WHERE Id = :groupLocationId LIMIT 1];
        }
        String duration = '';
        Integer durationInMinutes = 0;
        if (appointmentTypeId != null) {
            apptType = [SELECT Id, Name, Duration__c FROM Appointment_Type__c WHERE Id = :appointmentTypeId LIMIT 1];
            duration = apptType.Duration__c;
            durationInMinutes = Integer.valueOf(duration.split(' ')[0]);
        }
        List<Clinic_Resource__c> providers = [SELECT Id FROM Clinic_Resource__c WHERE Clinic_Location__c = :groupLocationId AND Resource_Type__c = :providerTypeId LIMIT 1];
        if (providers.isEmpty()) {
            ToolResult result = new ToolResult();
            result.toolCallId = toolId;
            result.result = 'Unfortunatly there is no provider available for the selected category.';
            wrapper.results.add(result);
        } else {
            if (toolId != null && providerResources != null) {
                ToolResult result = new ToolResult();
                result.toolCallId = toolId;
                if(excep != '') {
                    result.result = 'Failed to save records';
                } else {
                    String availabilityResults = 'Availabilities on ' + appointmentDate.format() + ': ';
                    Integer count = 1;
                    Integer dayCount = 1;
                    // Loop through each provider resource and build the string
                    while (dayCount < 31) {
                        count = 1;
                        for (Resource_Type__c providerResource : providerResources) {
                            String availability = availability(appointmentDate, providerResource, clinicLocation[0], durationInMinutes);
                            availabilityResults += 'Availability ' + count + ' : ' + availability + ', ';
                            count++;
                        }
                        if (availabilityResults.contains('No')) {
                            // Increment the date by 1 day and clear availabilityResults for the next loop
                            appointmentDate = appointmentDate.addDays(1);
                            availabilityResults = 'Availabilities on ' + appointmentDate.format() + ': ';
                            dayCount++;
                        } else {
                            // Exit the loop if no "No" is found
                            break;
                        }
                    }
                    if(availabilityResults.contains('Availability')) {
                        result.result = availabilityResults;
                    } else {
                        result.result = 'No availabilities found for the next 31 days.';
                    }
                }
                wrapper.results.add(result);
            } else {
                ToolResult result = new ToolResult();
                result.toolCallId = null;
                result.result = 'Failed: Tool ID not provided.';
                wrapper.results.add(result);
            }
        }
        // Add logic to populate the response
        
        
        // Serialize to JSON
        String jsonOutput = JSON.serialize(wrapper);
        System.debug(jsonOutput);
        
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(jsonOutput);
    }
    
    
    global static String availability(Date appointmentDate, Resource_Type__c providerType, Clinic_Location__c loc, Integer durationInMinutes) {
        System.debug('Date: ' + appointmentDate);
        System.debug('Date: ' + providerType);
        List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
        String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];
        
        // Query to find availabilities that match the given criteria
        List<Availability__c> availabilities = [
            SELECT Id, 
                   Day__c, 
                   Active__c, Clinic_Resource__c,
                   Clinic_Resource__r.Resource_Type__c,  Clinic_Resource__r.Clinic_Location__c,
                   Clinic_Resource__r.Id, 
                   Clinic_Resource__r.Name, 
                   Start_Shift__c, 
                   End_Shift__c
            FROM Availability__c
            WHERE Day__c = :dayOfWeek
              AND Active__c = true
              AND Clinic_Resource__r.Resource_Type__c = :providerType.Id
              AND Clinic_Resource__r.Clinic_Location__c = :loc.Id
        ];
        System.debug('Availabilities: ' + availabilities);
        
        if (availabilities.isEmpty()) {
            return 'No availabilities found for the given criteria.';
        }
        
        Set<Id> resourceIds = new Set<Id>();
        Map<Id, List<Map<String, Time>>> resourceSlotsMap = new Map<Id, List<Map<String, Time>>>();
        Map<Id, String> resourceNamesMap = new Map<Id, String>();
        // Populate resource IDs
        for (Availability__c availability : availabilities) {
            resourceIds.add(availability.Clinic_Resource__r.Id);
            resourceSlotsMap.put(availability.Clinic_Resource__r.Id, new List<Map<String, Time>>());
            resourceNamesMap.put(availability.Clinic_Resource__r.Id, availability.Clinic_Resource__r.Name); // Store the name
        }
        System.debug('Resource Slots Map; ' + resourceSlotsMap);
        
        // Query appointments for the given date and matching resources
        List<Appointment__c> appointments = [
            SELECT Id, 
                   Appointed_Date__c, 
                   Start_Time__c, 
                   End_Time__c,
                   Clinic_Resource__c, 
                   Clinic_Resource__r.Name
            FROM Appointment__c
            WHERE Appointed_Date__c = :appointmentDate
              AND Clinic_Resource__c IN :resourceIds
            ORDER BY Start_Time__c ASC
        ];
        
        // Process each availability and calculate free slots
        for (Availability__c availability : availabilities) {
            List<Map<String, Time>> availableSlots = new List<Map<String, Time>>();
            List<Appointment__c> resourceAppointments = new List<Appointment__c>();
            // Filter appointments for the current resource
            for (Appointment__c appointment : appointments) {
                if (appointment.Clinic_Resource__c == availability.Clinic_Resource__r.Id) {
                    resourceAppointments.add(appointment);
                }
            }
            
            Time shiftStart = availability.Start_Shift__c;
            Time shiftEnd = availability.End_Shift__c.addMinutes(-durationInMinutes);
            System.debug('Shift Start: ' + shiftStart + '; Shift End: ' + shiftEnd);
            // Calculate available slots based on filtered appointments
            for (Integer i = 0; i < resourceAppointments.size(); i++) {
                Appointment__c currentAppointment = resourceAppointments[i];
                System.debug('Processing Appointment: ' + currentAppointment);
                
                // Handle the first slot
                if (i == 0 && currentAppointment.Start_Time__c > shiftStart && currentAppointment.Start_Time__c < shiftEnd) {
                    System.debug('First slot found: shiftStart=' + shiftStart + ', currentAppointment.Start_Time__c=' + currentAppointment.Start_Time__c);
                    availableSlots.add(new Map<String, Time>{
                        'start' => shiftStart,
                        'end' => currentAppointment.Start_Time__c.addMinutes(-durationInMinutes)
                    });
                }
                
                // Handle slots between appointments
                if (i > 0) {
                    Appointment__c previousAppointment = resourceAppointments[i - 1];
                    System.debug('Previous Appointment: ' + previousAppointment);
                    if (currentAppointment.Start_Time__c > previousAppointment.End_Time__c) {
                        System.debug('Slot between appointments found: previousAppointment.End_Time__c=' + previousAppointment.End_Time__c + ', currentAppointment.Start_Time__c=' + currentAppointment.Start_Time__c);
                        availableSlots.add(new Map<String, Time>{
                            'start' => previousAppointment.End_Time__c,
                            'end' => currentAppointment.Start_Time__c
                        });
                    }
                }
                
                // Handle the last slot
                if (i == resourceAppointments.size() - 1 && currentAppointment.End_Time__c < shiftEnd) {
                    System.debug('Last slot found: currentAppointment.End_Time__c=' + currentAppointment.End_Time__c + ', shiftEnd=' + shiftEnd);
                    availableSlots.add(new Map<String, Time>{
                        'start' => currentAppointment.End_Time__c,
                        'end' => shiftEnd
                    });
                }
            }
            
            // Log the available slots after processing
            System.debug('Available Slots when resouceAppointments are available: ' + availableSlots);
            
            
            // If there are no appointments, the entire shift is available
            if (resourceAppointments.isEmpty()) {
                availableSlots.add(new Map<String, Time>{
                    'start' => shiftStart,
                    'end' => shiftEnd
                });
            }
            
            // Add slots to the map
            resourceSlotsMap.put(availability.Clinic_Resource__r.Id, availableSlots);
        }
        
        String result = '';
        
        for (Id resourceId : resourceSlotsMap.keySet()) {
            List<Map<String, Time>> slots = resourceSlotsMap.get(resourceId);
            String resourceSlotsStr = '';
            
            if (slots.isEmpty()) {
                resourceSlotsStr = 'No available slots';
            } else {
                for (Map<String, Time> slot : slots) {
                    Time startTime = slot.get('start');
                    Time endTime = slot.get('end');
                    String startFormatted = formatTimeToAMPM(startTime);
                    String endFormatted = formatTimeToAMPM(endTime);
                    
                    if (!String.isEmpty(resourceSlotsStr)) {
                        resourceSlotsStr += ' / ';
                    }
                    resourceSlotsStr += startFormatted + ' - ' + endFormatted;
                }
            }
            String resourceName = resourceNamesMap.get(resourceId);
            // Append the resource availability string in the required format
            if (!String.isEmpty(result)) {
                result += ' , '; // Add a comma separator for entries
            }
            result += '(' + resourceSlotsStr + ') -> ' + resourceId + ' (' + resourceName + ')';
        }
        
        System.debug('Available Slots: ' + result);
        return result;
    }
    public static String formatTimeToAMPM(Time timef) {
        Integer hour = timef.hour();
        Integer minute = timef.minute();
        String period = hour >= 12 ? 'PM' : 'AM';
        
        // Convert to 12-hour format
        if (hour == 0) {
            hour = 12; // Midnight
        } else if (hour > 12) {
            hour -= 12;
        }
        
        // Format minutes to always have two digits
        String minuteStr = minute < 10 ? '0' + minute : String.valueOf(minute);
        
        return hour + ':' + minuteStr + ' ' + period;
    }
    public class ResultWrapper {
        public List<ToolResult> results = new List<ToolResult>(); // Initialize the list
    }
    
    public class ToolResult {
        public String toolCallId;
        public String result;
    }
}