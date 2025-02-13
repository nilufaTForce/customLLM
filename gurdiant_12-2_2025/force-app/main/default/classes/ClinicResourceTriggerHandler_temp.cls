public with sharing class ClinicResourceTriggerHandler_temp {
    public static Boolean isUpdateInProgress = false;

    public static void execute(List<Clinic_Resource__c> newList) {
        // Set<Id> recordIdsToUpdate = new Set<Id>();
        // for (Integer i = 0; i < newList.size(); i++) {
        //         recordIdsToUpdate.add(newList[i].Id);
        // }
        // for (Id recordId : recordIdsToUpdate) {
        //     updateOutlookUserIdAsync(recordId);
        // }
    }

    @future(callout=true)
    public static void updateOutlookUserIdAsync(Id recordId) {
        // Query the Email__c field from the Clinic_Resource__c record
        Clinic_Resource__c resource = [SELECT Email__c FROM Clinic_Resource__c WHERE Id = :recordId LIMIT 1];

        System.debug('resource.Email__c: ' + resource.Email__c);

        if (String.isBlank(resource.Email__c)) {
            System.debug('No Email__c found for record: ' + recordId);
            return;
        }
        String userEmail = resource.Email__c;

        // Get Outlook API settings
        Map<String, String> outlookApiSettingsMap = OutlookAPIHandler.getOutlookApiSettingsInfo();
        String baseUrl = outlookApiSettingsMap.get('Endpoint');
        String ver = outlookApiSettingsMap.get('Version');

        String endpoint = baseUrl + '/' + ver + '/' + 'users/' + userEmail;
        System.debug('Endpoint => ' + endpoint);
        String accessToken = 'sdfgh';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        // Send the request and handle the response
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            if (res.getStatusCode() == 200) {
                // Check if there's an error key
                if (responseBody.containsKey('error')) {
                    Map<String, Object> error = (Map<String, Object>) responseBody.get('error');
                    String errorCode = (String) error.get('code');
                    String errorMessage = (String) error.get('message');
                    resource.Outlook_User_ID__c = 'ID NOT FOUND';
                    ClinicResourceTriggerHandler.isUpdateInProgress = TRUE;
                    update resource;
                    ClinicResourceTriggerHandler.isUpdateInProgress = FALSE;
                    System.debug('Error: ' + errorCode + ' - ' + errorMessage);
                } else {
                    // Process the response as usual if no error key exists
                    String retrievedId = (String) responseBody.get('id');
                    resource.Outlook_User_ID__c = retrievedId;
                    ClinicResourceTriggerHandler.isUpdateInProgress = TRUE;
                    update resource;
                    ClinicResourceTriggerHandler.isUpdateInProgress = FALSE;
                    System.debug('Retrieved user ID: ' + retrievedId);
                }
            } else {
                System.debug('Failed to retrieve user details. Status: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Error in making HTTP request: ' + e.getMessage());
        }
    }
}