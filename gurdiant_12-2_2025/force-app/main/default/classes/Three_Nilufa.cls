public without sharing class Three_Nilufa {
    @future (callout=true)
    public static void fetchSubscriptionsAndNotify(String accessToken) {
        Microsoft_Outlook_API__mdt cred = [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
        Base_Auth_Url__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];
        String subscriptionsUrl = cred.Outlook_Subscription_Api__c +'/' ;
        //do not delete
        //String subscriptionsUrl = 'https://graph.microsoft.com/v1.0/subscriptions/';
    
        if (String.isNotEmpty(accessToken)) {
            
            // Prepare HTTP request to fetch subscriptions
            HttpRequest req = new HttpRequest();
            req.setEndpoint(subscriptionsUrl);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Accept', 'application/json');
    
            Http http = new Http();
            HttpResponse res = http.send(req);
    
            // Handle the response
            if (res.getStatusCode() == 200) {
                System.debug('Successfully fetched subscriptions: ' + res.getBody());
    
                // Extract subscription ID
                String subscriptionId = extractSubscriptionId(res.getBody());
                if (String.isNotEmpty(subscriptionId)) {
                    // Directly delete the subscription by calling the Microsoft Graph API DELETE endpoint
                    deleteSubscription(subscriptionId, accessToken);
                }
            } else {
                System.debug('Error fetching subscriptions: ' + res.getBody());
            }
        } else {
            System.debug('No access token available.');
        }
    }
    
    // Helper method to extract subscription ID from the response (assuming JSON format)
    // private static String extractSubscriptionId(String responseBody) {
    //     Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    //     List<Object> subscriptions = (List<Object>) jsonResponse.get('value');
    //     if (!subscriptions.isEmpty()) {
    //         Map<String, Object> subscription = (Map<String, Object>) subscriptions.get(0);
    //         return (String) subscription.get('id');
    //     }
    //     return null;
    // }
    private static String extractSubscriptionId(String responseBody) {
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> subscriptions = (List<Object>) jsonResponse.get('value');
        
        // Iterate through the subscriptions
        for (Object subscriptionObj : subscriptions) {
            Map<String, Object> subscription = (Map<String, Object>) subscriptionObj;
            
            // Get the notification URL
            String notificationUrl = (String) subscription.get('notificationUrl');
            
            // Check if the notification URL matches the specified one
            if (notificationUrl != null && notificationUrl == 'https://guardiant--willg.sandbox.my.site.com/services/apexrest/outlookapiservice') {
                // Return the subscription ID if the URL matches
                return (String) subscription.get('id');
            }
        }
        
        // If no matching subscription is found, return null
        return null;
    }
    
    
    // Helper method to delete a subscription
    private static void deleteSubscription(String subscriptionId, String accessToken) {
        Microsoft_Outlook_API__mdt cred = [SELECT Endpoint__c, Client_Id__c, Client_Secret__c, Version__c, Tenant_Id__c,Redirect_Url_Outlook__c, Redirect_Url__c,Outlook_Subscription_Api__c,
        Base_Auth_Url__c
        FROM Microsoft_Outlook_API__mdt
        WHERE DeveloperName = 'Outlook_API_Settings'
        LIMIT 1];
        String deleteUrl = cred.Outlook_Subscription_Api__c +'/'+ subscriptionId ;
        // do not delete
        //String deleteUrl = 'https://graph.microsoft.com/v1.0/subscriptions/' + subscriptionId;
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(deleteUrl);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
    
        Http http = new Http();
        HttpResponse res = http.send(req);
    
        if (res.getStatusCode() == 204) {
            System.debug('Successfully deleted subscription: ' + subscriptionId);
        } else {
            System.debug('Error deleting subscription: ' + res.getBody());
        }
    
    }


//     public static void availability(Date appointmentDate, Resource_Type__c providerType) {
       
    
      
//         List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};

//     // Get the day of the week as a string
//     String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];
    
      
//         // Query to find availabilities that match the given criteria
//         List<Availability__c> availabilities = [
//             SELECT Id, 
//                    Day__c, 
//                    Active__c, 
//                    Clinic_Resource__r.Resource_Type__c, 
//                    Clinic_Resource__r.Name, 
//                    Start_Shift__c, 
//                    End_Shift__c
//             FROM Availability__c
//             WHERE Day__c = :dayOfWeek
//               AND Active__c = true
//               AND Clinic_Resource__r.Resource_Type__c = :providerType.Id
//         ];
//         if (availabilities.isEmpty()) {
//             System.debug('No availabilities found for the given criteria.');
//         } else {
//             for (Availability__c availability : availabilities) {
//                 System.debug('Availability Details:');
//                 System.debug('Day: ' + availability.Day__c);
//                 System.debug('Resource Type: ' + availability.Clinic_Resource__r.Resource_Type__c);
//                 System.debug('Resource Name: ' + availability.Clinic_Resource__r.Name);
//                 System.debug('Start Shift: ' + availability.Start_Shift__c);
//                 System.debug('End Shift: ' + availability.End_Shift__c);
//             }
//         }
//         Set<Id> resourceIds = new Set<Id>();
     
//         // Populate the initial slots from availabilities
//         for (Availability__c availability : availabilities) {
//             resourceIds.add(availability.Clinic_Resource__r.Id);
           
//         }

//         // Query appointments for the given date and matching resources
//         List<Appointment__c> appointments = [
//             SELECT Id, 
//                 Appointed_Date__c, 
//                 Start_Time__c, 
//                 End_Time__c,
//                 Clinic_Resource__c, 
//                 Clinic_Resource__r.Name
//             FROM Appointment__c
//             WHERE Appointed_Date__c = :appointmentDate
//             AND Clinic_Resource__c IN :resourceIds   ORDER BY Start_Time__c ASC
//         ];

//         if (appointments.isEmpty()) {
//             System.debug('No appointments found for the given date and resources.');
//         } else {
//             System.debug(appointments);
            
       
//     }
// }
// public static void availability(Date appointmentDate, Resource_Type__c providerType) {
//     List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
//     String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];
    
//     // Query to find availabilities that match the given criteria
//     List<Availability__c> availabilities = [
//         SELECT Id, 
//                Day__c, 
//                Active__c, 
//                Clinic_Resource__r.Resource_Type__c, 
//                Clinic_Resource__r.Id, 
//                Clinic_Resource__r.Name, 
//                Start_Shift__c, 
//                End_Shift__c
//         FROM Availability__c
//         WHERE Day__c = :dayOfWeek
//           AND Active__c = true
//           AND Clinic_Resource__r.Resource_Type__c = :providerType.Id
//     ];
    
//     if (availabilities.isEmpty()) {
//         System.debug('No availabilities found for the given criteria.');
//         return;
//     }
    
//     Set<Id> resourceIds = new Set<Id>();
//     Map<Id, List<Map<String, Time>>> resourceSlotsMap = new Map<Id, List<Map<String, Time>>>();
    
//     // Populate resource IDs
//     for (Availability__c availability : availabilities) {
//         resourceIds.add(availability.Clinic_Resource__r.Id);
//         resourceSlotsMap.put(availability.Clinic_Resource__r.Id, new List<Map<String, Time>>());
//     }
    
//     // Query appointments for the given date and matching resources
//     List<Appointment__c> appointments = [
//         SELECT Id, 
//                Appointed_Date__c, 
//                Start_Time__c, 
//                End_Time__c,
//                Clinic_Resource__c, 
//                Clinic_Resource__r.Name
//         FROM Appointment__c
//         WHERE Appointed_Date__c = :appointmentDate
//           AND Clinic_Resource__c IN :resourceIds
//         ORDER BY Start_Time__c ASC
//     ];
    
//     if (appointments.isEmpty()) {
//         System.debug('No appointments found for the given date and resources.');
//     } else {
//         System.debug(appointments);
//     }
    
//     // Process each availability and calculate free slots
//     // Filter appointments manually for each resource
// for (Availability__c availability : availabilities) {
//     List<Map<String, Time>> availableSlots = new List<Map<String, Time>>();
//     List<Appointment__c> resourceAppointments = new List<Appointment__c>();
    
//     // Manually filter appointments for the current resource
//     for (Appointment__c appointment : appointments) {
//         if (appointment.Clinic_Resource__c == availability.Clinic_Resource__r.Id) {
//             resourceAppointments.add(appointment);
//         }
//     }

//     Time shiftStart = availability.Start_Shift__c;
//     Time shiftEnd = availability.End_Shift__c;

//     // Calculate available slots based on filtered appointments
//     for (Integer i = 0; i < resourceAppointments.size(); i++) {
//         Appointment__c currentAppointment = resourceAppointments[i];
        
//         // Handle the first slot
//         if (i == 0 && currentAppointment.Start_Time__c > shiftStart) {
//             availableSlots.add(new Map<String, Time>{
//                 'start' => shiftStart,
//                 'end' => currentAppointment.Start_Time__c
//             });
//         }
        
//         // Handle slots between appointments
//         if (i > 0) {
//             Appointment__c previousAppointment = resourceAppointments[i - 1];
//             if (currentAppointment.Start_Time__c > previousAppointment.End_Time__c) {
//                 availableSlots.add(new Map<String, Time>{
//                     'start' => previousAppointment.End_Time__c,
//                     'end' => currentAppointment.Start_Time__c
//                 });
//             }
//         }
        
//         // Handle the last slot
//         if (i == resourceAppointments.size() - 1 && currentAppointment.End_Time__c < shiftEnd) {
//             availableSlots.add(new Map<String, Time>{
//                 'start' => currentAppointment.End_Time__c,
//                 'end' => shiftEnd
//             });
//         }
//     }
    
//     // If there are no appointments, the entire shift is available
//     if (resourceAppointments.isEmpty()) {
//         availableSlots.add(new Map<String, Time>{
//             'start' => shiftStart,
//             'end' => shiftEnd
//         });
//     }
    
//     // Add slots to the map
//     resourceSlotsMap.put(availability.Clinic_Resource__r.Id, availableSlots);
// }
// for (Id resourceId : resourceSlotsMap.keySet()) {
//     System.debug('Resource ID: ' + resourceId);
//     List<Map<String, Time>> slots = resourceSlotsMap.get(resourceId);
//     if (slots.isEmpty()) {
//         System.debug('No available slots for this resource.');
//     } else {
//         System.debug('Available Slots:');
//         for (Map<String, Time> slot : slots) {
//             // Format start time
//             Time startTime = slot.get('start');
//             String startFormatted = formatTimeToAMPM(startTime);

//             // Format end time
//             Time endTime = slot.get('end');
//             String endFormatted = formatTimeToAMPM(endTime);

//             System.debug('Start: ' + startFormatted + ', End: ' + endFormatted);
//         }
//     }
    
    
//     // Log the available slots for each resource

    
// }


// }
public static String availability(Date appointmentDate, Resource_Type__c providerType) {
    List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
    String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];

    // Query to find availabilities that match the given criteria
    List<Availability__c> availabilities = [
        SELECT Id, 
               Day__c, 
               Active__c, 
               Clinic_Resource__r.Resource_Type__c, 
               Clinic_Resource__r.Id, 
               Clinic_Resource__r.Name, 
               Start_Shift__c, 
               End_Shift__c
        FROM Availability__c
        WHERE Day__c = :dayOfWeek
          AND Active__c = true
          AND Clinic_Resource__r.Resource_Type__c = :providerType.Id
    ];

    if (availabilities.isEmpty()) {
        return 'No availabilities found for the given criteria.';
    }

    Set<Id> resourceIds = new Set<Id>();
    Map<Id, List<Map<String, Time>>> resourceSlotsMap = new Map<Id, List<Map<String, Time>>>();

    // Populate resource IDs
    for (Availability__c availability : availabilities) {
        resourceIds.add(availability.Clinic_Resource__r.Id);
        resourceSlotsMap.put(availability.Clinic_Resource__r.Id, new List<Map<String, Time>>());
    }

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
        Time shiftEnd = availability.End_Shift__c;

        // Calculate available slots based on filtered appointments
        for (Integer i = 0; i < resourceAppointments.size(); i++) {
            Appointment__c currentAppointment = resourceAppointments[i];

            // Handle the first slot
            if (i == 0 && currentAppointment.Start_Time__c > shiftStart) {
                availableSlots.add(new Map<String, Time>{
                    'start' => shiftStart,
                    'end' => currentAppointment.Start_Time__c
                });
            }

            // Handle slots between appointments
            if (i > 0) {
                Appointment__c previousAppointment = resourceAppointments[i - 1];
                if (currentAppointment.Start_Time__c > previousAppointment.End_Time__c) {
                    availableSlots.add(new Map<String, Time>{
                        'start' => previousAppointment.End_Time__c,
                        'end' => currentAppointment.Start_Time__c
                    });
                }
            }

            // Handle the last slot
            if (i == resourceAppointments.size() - 1 && currentAppointment.End_Time__c < shiftEnd) {
                availableSlots.add(new Map<String, Time>{
                    'start' => currentAppointment.End_Time__c,
                    'end' => shiftEnd
                });
            }
        }

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

        // Append the resource availability string in the required format
        if (!String.isEmpty(result)) {
            result += ' , '; // Add a comma separator for entries
        }
        result += '(' + resourceSlotsStr + ') -> ' + resourceId;
    }

    System.debug('Final Result: ' + result);
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
    

    // public static Clinic_Resource__c assignRoundRobin(Appointment__c app) {
    //     List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
    //     Date appointmentDate = app.Appointed_Date__c;
    //     String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];
    
    //     // Fetch available clinic resources for the given appointment criteria
    //     List<Availability__c> availabilities = [
    //         SELECT Id, Clinic_Resource__r.Id, Clinic_Resource__r.Name, Start_Shift__c, End_Shift__c
    //         FROM Availability__c
    //         WHERE Day__c = :dayOfWeek
    //           AND Active__c = true
    //           AND Clinic_Resource__r.Resource_Type__c = :app.Resource_Type__c
    //           AND Clinic_Resource__r.Clinic_Location__c = :app.Clinic_Location__c
    //           AND Clinic_Resource__r.Appointment_Type__c = :app.Appointment_Type__c
    //     ];
    
    //     if (availabilities.isEmpty()) {
    //         return null; // No matching resource available
    //     }
    
    //     // Store available Clinic_Resource__c IDs
    //     List<Id> availableResourceIds = new List<Id>();
    //     for (Availability__c a : availabilities) {
    //         availableResourceIds.add(a.Clinic_Resource__r.Id);
    //     }
    
    //     // Fetch last assigned resource from Appointment__c
    //     Appointment__c lastAssigned;
    //     List<Appointment__c> lastAssignedList = [
    //         SELECT Clinic_Resource__c FROM Appointment__c
    //         WHERE Clinic_Resource__c IN :availableResourceIds
    //         ORDER BY CreatedDate DESC
    //         LIMIT 1
    //     ];
    //     if (!lastAssignedList.isEmpty()) {
    //         lastAssigned = lastAssignedList[0];
    //     }
    
    //     Id lastAssignedId = (lastAssigned != null) ? lastAssigned.Clinic_Resource__c : null;
    
    //     // Remove conflicting resources (overlapping appointments)
    //     List<Appointment__c> conflictingAppointments = [
    //         SELECT Clinic_Resource__c FROM Appointment__c
    //         WHERE Clinic_Resource__c IN :availableResourceIds
    //           AND (Start_Time__c <= :app.End_Time__c AND End_Time__c >= :app.Start_Time__c) // Overlap check
    //     ];
    
    //     Set<Id> conflictingResourceIds = new Set<Id>();
    //     for (Appointment__c conflict : conflictingAppointments) {
    //         conflictingResourceIds.add(conflict.Clinic_Resource__c);
    //     }
    
    //     // Remove conflicting resources
    //     availableResourceIds.removeAll(new List<Id>(conflictingResourceIds));
    
    //     if (availableResourceIds.isEmpty()) {
    //         return null; // No available resources after filtering
    //     }
    
    //     // Round-robin logic: Pick next resource after last assigned
    //     Integer nextIndex = 0;
    //     Integer listSize = availableResourceIds.size();
        
    //     if (lastAssignedId != null) {
    //         Integer lastIndex = availableResourceIds.indexOf(lastAssignedId);
    //         if (lastIndex != -1) { // Ensure last assigned ID exists in the list
    //             nextIndex = (lastIndex + 1) % listSize; // Move to next resource in the list
    //         }
    //     }
    
    //     Id assignedResourceId = availableResourceIds[nextIndex];
    
    //     // Return the assigned Clinic_Resource__c
    //     return [SELECT Id, Name FROM Clinic_Resource__c WHERE Id = :assignedResourceId LIMIT 1];
    // }
    public static Clinic_Resource__c assignRoundRobin(Appointment__c app) {
        List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
        Date appointmentDate = app.Appointed_Date__c;
        String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];
    
        // Fetch available clinic resources for the given appointment criteria
        List<Availability__c> availabilities = [
            SELECT Id, Clinic_Resource__r.Id, Clinic_Resource__r.Name, Start_Shift__c, End_Shift__c
            FROM Availability__c
            WHERE Day__c = :dayOfWeek
              AND Active__c = true
              AND Clinic_Resource__r.Resource_Type__c = :app.Resource_Type__c
              AND Clinic_Resource__r.Clinic_Location__c = :app.Clinic_Location__c
              AND Clinic_Resource__r.Appointment_Type__c = :app.Appointment_Type__c
        ];
    
        if (availabilities.isEmpty()) {
            return null; // No matching resource available
        }
    
        // Store available Clinic_Resource__c IDs
        List<Id> availableResourceIds = new List<Id>();
        for (Availability__c a : availabilities) {
            availableResourceIds.add(a.Clinic_Resource__r.Id);
        }
    
        // Fetch last assigned resource from Appointment__c
        Appointment__c lastAssigned;
        List<Appointment__c> lastAssignedList = [
            SELECT Clinic_Resource__c FROM Appointment__c
            WHERE Clinic_Resource__c IN :availableResourceIds
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!lastAssignedList.isEmpty()) {
            lastAssigned = lastAssignedList[0];
        }
    
        Id lastAssignedId = (lastAssigned != null) ? lastAssigned.Clinic_Resource__c : null;
    
        // Remove conflicting resources (overlapping appointments)
        List<Appointment__c> conflictingAppointments = [
            SELECT Clinic_Resource__c FROM Appointment__c
            WHERE Clinic_Resource__c IN :availableResourceIds
              AND (Start_Time__c <= :app.End_Time__c AND End_Time__c >= :app.Start_Time__c) // Overlap check
        ];
    
        Set<Id> conflictingResourceIds = new Set<Id>();
        for (Appointment__c conflict : conflictingAppointments) {
            conflictingResourceIds.add(conflict.Clinic_Resource__c);
        }
    
        // Remove conflicting resources using Set
        Set<Id> availableResourceSet = new Set<Id>(availableResourceIds);
        availableResourceSet.removeAll(conflictingResourceIds); // Use Set's removeAll method
        availableResourceIds = new List<Id>(availableResourceSet); // Convert back to List
    
        if (availableResourceIds.isEmpty()) {
            return null; // No available resources after filtering
        }
   



        // Round-robin logic: Pick next resource after last assigned
        Integer nextIndex = 0;
        Integer listSize = availableResourceIds.size();

        if (lastAssignedId != null) {
            Integer lastIndex = availableResourceIds.indexOf(lastAssignedId);
            if (lastIndex != -1) { // Ensure last assigned ID exists in the list
               // nextIndex = (lastIndex + 1) % listSize; // Move to next resource in the list
               nextIndex = math.mod((lastIndex + 1),listSize);
            }
        }

        Id assignedResourceId = availableResourceIds[nextIndex];
        
    
        // // Round-robin logic: Pick next resource after last assigned
        // Integer nextIndex = 0;
        // Integer listSize = availableResourceIds.size();
        
        
        // if (lastAssignedId != null) {
        //     Integer lastIndex = availableResourceIds.indexOf(lastAssignedId);
        //     if (lastIndex != -1) { // Ensure last assigned ID exists in the list
        //         nextIndex = ((lastIndex + 1) % listSize ) ; // Move to next resource in the list
        //     }
        // }
    
        // Id assignedResourceId = availableResourceIds[nextIndex];
    
        // Return the assigned Clinic_Resource__c
        return [SELECT Id, Name FROM Clinic_Resource__c WHERE Id = :assignedResourceId LIMIT 1];
    }
    public static Clinic_Resource__c assignRoundRobin1(Appointment__c app) {
        List<String> daysOfWeek = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
        Date appointmentDate = app.Appointed_Date__c;
        String dayOfWeek = daysOfWeek[appointmentDate.toStartOfWeek().daysBetween(appointmentDate)];
        
        // Debug the calculated day of the week
        System.debug('Appointment Day of the Week: ' + dayOfWeek);
    
        // Fetch available clinic resources for the given appointment criteria
        List<Availability__c> availabilities = [
            SELECT Id, Clinic_Resource__r.Id, Clinic_Resource__r.Name, Start_Shift__c, End_Shift__c
            FROM Availability__c
            WHERE Day__c = :dayOfWeek
              AND Active__c = true
              AND Clinic_Resource__r.Resource_Type__c = :app.Resource_Type__c
              AND Clinic_Resource__r.Clinic_Location__c = :app.Clinic_Location__c
              AND Clinic_Resource__r.Appointment_Type__c = :app.Appointment_Type__c
        ];
    
        // Debug the size of availabilities found
        System.debug('Availabilities Count: ' + availabilities.size());
    
        if (availabilities.isEmpty()) {
            System.debug('No matching resources found.');
            return null; // No matching resource available
        }
    
        // Store available Clinic_Resource__c IDs
        List<Id> availableResourceIds = new List<Id>();
        for (Availability__c a : availabilities) {
            availableResourceIds.add(a.Clinic_Resource__r.Id);
        }
    
        // Debug the available resource IDs
        System.debug('Available Resource IDs: ' + availableResourceIds);
    
        // Fetch last assigned resource from Appointment__c
        // Appointment__c lastAssigned;
        // List<Appointment__c> lastAssignedList = [
        //     SELECT Clinic_Resource__c FROM Appointment__c
        //     WHERE Clinic_Resource__c IN :availableResourceIds
        //     ORDER BY CreatedDate DESC
        //     LIMIT 1
        // ];
        
        // if (!lastAssignedList.isEmpty()) {
        //     lastAssigned = lastAssignedList[0];
        // }
        
        // Id lastAssignedId = (lastAssigned != null) ? lastAssigned.Clinic_Resource__c : null;
    
        // Debug the last assigned resource
       // System.debug('Last Assigned Resource ID: ' + lastAssignedId);
    
        // Remove conflicting resources (overlapping appointments)
        List<Appointment__c> conflictingAppointments = [
            SELECT Clinic_Resource__c,Start_Time__c,End_Time__c , Id   FROM Appointment__c
            WHERE Clinic_Resource__c IN :availableResourceIds
             // AND (Start_Time__c <= :app.End_Time__c AND End_Time__c >= :app.Start_Time__c) // Overlap check
             AND (
                (Start_Time__c < :app.End_Time__c AND End_Time__c > :app.Start_Time__c) OR  // Overlapping cases
                (Start_Time__c >= :app.Start_Time__c AND End_Time__c <= :app.End_Time__c) OR // New appointment is completely within existing
                (Start_Time__c <= :app.Start_Time__c AND End_Time__c >= :app.End_Time__c)    // New appointment completely overlaps existing
            )
            
        ];
    
        // Debug the conflicting appointments
        System.debug('Conflicting Appointments Count: ' + conflictingAppointments.size());
        System.debug('Conflicting Appointments: ' + conflictingAppointments);

        for (Appointment__c conflict : conflictingAppointments) {
            System.debug('Conflicting Appointment ID: ' + conflict.Id);
            System.debug('Conflicting Resource ID: ' + conflict.Clinic_Resource__c);
            System.debug('Start Time: ' + conflict.Start_Time__c);
            System.debug('End Time: ' + conflict.End_Time__c);
        }
            
        Set<Id> conflictingResourceIds = new Set<Id>();
        for (Appointment__c conflict : conflictingAppointments) {
            conflictingResourceIds.add(conflict.Clinic_Resource__c);
        }
    
        // Debug conflicting resource IDs
        System.debug('Conflicting Resource IDs: ' + conflictingResourceIds);
    
        // Remove conflicting resources using Set
        Set<Id> availableResourceSet = new Set<Id>(availableResourceIds);
        availableResourceSet.removeAll(conflictingResourceIds); // Use Set's removeAll method
        availableResourceIds = new List<Id>(availableResourceSet); // Convert back to List
    
        // Debug the remaining available resources
        System.debug('Remaining Available Resource IDs: ' + availableResourceIds);
    
        if (availableResourceIds.isEmpty()) {
            System.debug('No available resources after filtering.');
            return null; // No available resources after filtering
        }
    
        // Round-robin logic: Pick next resource after last assigned
        Integer nextIndex = 0;
        Integer listSize = availableResourceIds.size();
    
        System.debug('Available Resources Count for Round-Robin: ' + listSize);
    
       // if (lastAssignedId != null) {
            //Integer lastIndex = availableResourceIds.indexOf(lastAssignedId);
            Integer lastIndex = Integer.valueOf((Integer) (Math.random() * 100));
            System.debug('last index -->'+lastIndex);
            if (lastIndex != -1) { // Ensure last assigned ID exists in the list
                nextIndex = Math.mod(lastIndex , listSize); // Use Math.mod for round-robin logic
            }
       // }
    
        // Debug the next index and assigned resource
        System.debug('Next Index for Round-Robin: ' + nextIndex);
    
        Id assignedResourceId = availableResourceIds[nextIndex];
    
        // Debug the assigned resource ID
        System.debug('Assigned Resource ID: ' + assignedResourceId);
    
        // Return the assigned Clinic_Resource__c
        return [SELECT Id, Name FROM Clinic_Resource__c WHERE Id = :assignedResourceId LIMIT 1];
    }
    
    
}