@RestResource(urlMapping = '/outlookapiservice/*')
global without sharing class OutlookAPIService{
    private static Map<String, String> eventChangeKeyMap = new Map<String, String>();
    private String tempEventId = '';
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(req));
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(jsonData.get('params')));
        String validationToken = (String) params.get('validationToken');


        // System.debug('Debug-POST---->' + JSON.serialize(req));
        // res.statusCode = 200;
        // Subscription
        if (validationToken != null){
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(validationToken);
            res.addHeader('Content-Type', 'text/plain');
            return;
        } else{
            res.statusCode = 200;
            // Created, Updated, Deleted
            // Parse the JSON string into a generic map
            
            Map<String, Object> parsedJson = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            System.debug('Incoming request - Body: ' + req.requestBody.toString());
            System.debug('Incoming request - Headers: ' + req.headers);

            // System.debug('parsedJson-->' +parsedJson);
            List<Object> values = (List<Object>)parsedJson.get('value');
            String resourceUrl = '';
            String changeType = '';
            String eventId = '';
            String changeKey = '';
            String clientState = '';

            if (values != null && !values.isEmpty()){
                Map<String, Object> firstValue = (Map<String, Object>)values[0];
                // System.debug('firstValue => ' + firstValue);
                // System.debug('firstValue => ' + JSON.serialize(firstValue));

                if (firstValue != null){
                    resourceUrl = (String) firstValue.get('resource');
                    changeType = (String) firstValue.get('changeType');
                    clientState = (String) firstValue.get('clientState');
                    if (clientState != 'SecretClientState' && clientState != 'secretClientValue' && changeType == 'created') {
                        return;
                    }
                    Map<String, Object> resourceData = (Map<String, Object>)firstValue.get('resourceData');

                    if (resourceData != null){
                        eventId = (String) resourceData.get('id');
                        changeKey = (String)resourceData.get('@odata.etag'); // Assuming ChangeKey is stored here
                    }
                }
            }
            System.debug('Event Change Key Map: ' + eventChangeKeyMap);

            Map<String, Object> eventDetails;
            // Process notification
            if (String.isNotBlank(eventId) && String.isNotBlank(changeKey)) {
                // Check if the Event ID already exists in the map
                if (eventChangeKeyMap.containsKey(eventId)) {
                    // Compare ChangeKey
                    if (eventChangeKeyMap.get(eventId) == changeKey) {
                        // If ChangeKey hasn't changed, skip processing
                        System.debug('No changes detected for Event ID: ' + eventId);
                        res.statusCode = 200;
                        res.responseBody = Blob.valueOf('No changes detected');
                        return;
                    }
                }

                // Update the map with the new ChangeKey
                eventChangeKeyMap.put(eventId, changeKey);

                // Handle different change types
                if (changeType == 'created' || changeType == 'updated'){
                
                    eventDetails = OutlookAPIHandler.getEventDetils(resourceUrl);
                    String status = OutlookAPIHandler.upsertAppointment(eventDetails, changeType);
                    if (status == 'Success'){
                        // res.statusCode = 200;
                        res.responseBody = Blob.valueOf('Appointment upserted successfully');
                    } else{
                        // res.statusCode = 200;
                        res.responseBody = Blob.valueOf('Error Happend');
                    }
                    // res.statusCode = 200;
                    return;
                } else if(changeType == 'deleted'){
                    // if Event deleted delete the Appointment__c Object
                    String status = OutlookAPIHandler.deleteAppointment(eventId);
                    // if (status == 'Success'){
                    //     res.statusCode = 200;
                    //     res.responseBody = Blob.valueOf('Appointment upserted successfully');
                    // } else{
                    //     res.statusCode = 200;
                    // }
                }
            }
            // if (changeType == 'created' || changeType == 'updated'){
            /*if (changeType == 'created'){
                
                eventDetails = OutlookAPIHandler.getEventDetils(resourceUrl);
                String status = OutlookAPIHandler.upsertAppointment(eventDetails, changeType);
                if (status == 'Success'){
                    // res.statusCode = 200;
                    res.responseBody = Blob.valueOf('Appointment upserted successfully');
                } else{
                    // res.statusCode = 200;
                    res.responseBody = Blob.valueOf('Error Happend');
                }
                // res.statusCode = 200;
                return;
            } else if(changeType == 'deleted'){
                // if Event deleted delete the Appointment__c Object
                String status = OutlookAPIHandler.deleteAppointment(eventId);
                // if (status == 'Success'){
                //     res.statusCode = 200;
                //     res.responseBody = Blob.valueOf('Appointment upserted successfully');
                // } else{
                //     res.statusCode = 200;
                // }
            }*/

        }

    }
    

    @HttpGet
    global static void getHandlers(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(req));
        res.addHeader('Content-Type', 'text/plain');
        res.responseBody = Blob.valueOf(JSON.serialize('JSON DUMMY DATA'));
        System.debug('Debug-GET---->' + JSON.serialize(req));
        res.statusCode = 200;
    }

    // class ResourceWrapper{
    //     String changeType;
    //     String clientState;
    //     String resource;
    //     String resourceData;
    //     String changeType;
    //     String changeType;
    //     String changeType;
    // }

}