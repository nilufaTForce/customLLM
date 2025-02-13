public without sharing class AppointmentTriggerHandler{
    //Part A: An Interface
    interface HandleTrigger{
        void handle(Appointment__c[] oldApps, Appointment__c[] newApps);
    }

    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };
    public static Boolean systemUpdate = false;
    public static void execute(Appointment__c[] oldApps, Appointment__c[] newApps){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldApps, newApps);
        }
    }

    class BeforeInsert implements HandleTrigger{
        public void handle(Appointment__c[] oldApps, Appointment__c[] newApps){
            //
            // System.debug('BeforeInsert');
            for (Integer i = 0; i < newApps.size(); i++){
                Id providerID = Schema.SObjectType.Appointment__c.getRecordTypeInfosByDeveloperName().get('Unavailable').getRecordTypeId();
                if(newApps[i].RecordTypeId == providerID) {
                    continue;
                }

                if (newApps[i].From_Outlook__c){
                    if (AppointmentHandler.duplicateAppointment(newApps[i])){
                        newApps[i].addError('Dupplicate appointment detected.');
                    }
                }

                if (newApps[i].Clinic_Resource__c == null){
                    AppointmentHandler.assignRoundRobin(newApps[i]);
                }

                AppointmentHandler.formatDateTime(newApps[i]);
                AppointmentHandler.statusValidator(newApps[i]);
                //   String providerEmail = [SELECT Email__c FROM Clinic_Resource__c WHERE Id =: newApps[i].Clinic_Resource__c];
                  List<Clinic_Resource__c> clinicResource = [SELECT Id,Email__c FROM Clinic_Resource__c WHERE Id =: newApps[i].Clinic_Resource__c LIMIT 1];
                  String providerEmail = clinicResource[0].Email__c;
                //   if(newApps[i].From_Vapi__c) {
                //     continue;
                //   }
                  List<Account> patient = [SELECT Id,Email__c FROM  Account WHERE Id =: newApps[i].Patient_Account__c LIMIT 1];
                    

                     if (patient.isEmpty()) {
                        continue;
                     }
                     String patientEmail = patient[0].Email__c;
                if(patientEmail == providerEmail){
                    newApps[i].addError( 'The email address on the patient\'s record is the same as the email address of the provider. ');


                }

                // if (!CustomCalendarController.isDoctorAvailable(newApps[i].Date_and_Time_Temp__c, newApps[i].Duration__c, newApps[i].Clinic_Resource__c, newApps[i].Clinic_Location__c)){
                    // newApps[i].addError('No doctor is available at this time. Please select different appointment time!');
                // }

            }
        }

    }

    class AfterInsert implements HandleTrigger{
        public void handle(Appointment__c[] oldApps, Appointment__c[] newApps){
            List<String> appointmentIds = new List<String>();

            system.debug(newApps.size()+'yyy');
            for (Integer i = 0; i < newApps.size(); i++){
                if (!newApps[i].From_Outlook__c){
                    AppointmentHandler.appEmailHandler(newApps[i]);
                    appointmentIds.add(newApps[i].Id);
                }
            }
            
            if (!appointmentIds.isEmpty()) {
                // Create the platform event instancea
                AppointmentEvent__e event = new AppointmentEvent__e(
                    AppointmentIds__c = String.join(appointmentIds, ',')  // Join IDs with a comma
                );
    
                Database.SaveResult saveResult = EventBus.publish(event);
    
                if (saveResult.isSuccess()) {
                    System.debug('Platform Event Published Successfully');
                } else {
                    System.debug('Error in Publishing Platform Event');
                }
            }
        }

    }

    class BeforeUpdate implements HandleTrigger{
        public void handle(Appointment__c[] oldApps, Appointment__c[] newApps){
            //
            // System.debug('BeforeUpdate');
            /*for (Integer i = 0; i < newApps.size(); i++){
                List<Appointment__c> listOfappointments =  [SELECT Name,Id,Start_Time__c, Doctor_Text__c,Provider_Company__c,
                                                            End_Time__c,Appointed_Date__c,Clinic_Location__c, Clinic_Location__r.Provider_Company__c,
                                                            Clinic_Location__r.Provider_Company__r.Resource_Category__c, 
                                                            Clinic_Resource__c FROM Appointment__c  WHERE 
                                                            Clinic_Resource__c = :newApps[i].Clinic_Resource__c 
                                                            AND Appointed_Date__c = :newApps[i].Appointed_Date__c];
                
                if (listOfappointments.size() > 0){
                    for (Appointment__c appointment : listOfappointments){
                        if (appointment.Start_Time__c > newApps[i].Start_Time__c && appointment.Start_Time__c < newApps[i].End_Time__c && appointment.Id != newApps[i].Id ){
                            // newApps[i].addError('You already have an appointment at this time. Please choose another time.');
                        }
                    }
                }
            }*/
        }

    }

    class AfterUpdate implements HandleTrigger{
        public void handle(Appointment__c[] oldApps, Appointment__c[] newApps){
            // System.debug('AfterUpdate');
            List<String> appointmentIds = new List<String>();
            //List<Appointment__c> appointmentsToUpdate = new List<Appointment__c>(); 
            for (Integer i = 0; i < newApps.size(); i++){
                if(newApps[i].Start_Time__c != oldApps[i].Start_Time__c) {
                    // CustomCalendarController.notifyUpdateTimeToPatient(newApps[i], oldApps[i]);
                }

        // Assign a provider using Round-Robin if Clinic_Resource__c is null
          /*  if (newApps[i].Clinic_Resource__c == null) {
                Clinic_Resource__c assignedProvider = Three_Nilufa.assignRoundRobin1(newApps[i]);
                if (assignedProvider != null) {
                    Appointment__c appointmentToUpdate = [SELECT Id, Clinic_Resource__c FROM Appointment__c WHERE Id = :newApps[i].Id LIMIT 1];
                    appointmentToUpdate.Clinic_Resource__c = assignedProvider.Id;
                    //newApps[i].Clinic_Resource__c = assignedProvider.Id;
                    //appointmentsToUpdate.add(newApps[i]); // Add to update list
                }
            } */




                if (newApps[i].Status__c == 'Cancelled' || newApps[i].Status__c == 'Accepted') {
                    String providerId = newApps[i].Clinic_Resource__c;
                    List<Clinic_Resource__c> provider = [SELECT Id, Name, Email__c FROM Clinic_Resource__c WHERE Id = :providerId LIMIT 1];
                    System.debug('Status Cancelled: '+newApps[i].Status__c);
                    if(newApps[i].Status__c == 'Cancelled') {
                        EventService.notifyCancelToPatient(newApps[i], 1);
                    } else {
                        EventService.notifyCancelToPatient(newApps[i], 0);
                    }
                    
                }
                else if (oldApps[i].Status__c == 'Requested' && oldApps[i].Status__c != newApps[i].Status__c){
                    // AppointmentHandler.notifyAppToPat(newApps[i]);
                }
                appointmentIds.add(newApps[i].Id);
            }
            if (!appointmentIds.isEmpty()) {
                // Create the platform event instance
                AppointmentEvent__e event = new AppointmentEvent__e(
                    AppointmentIds__c = String.join(appointmentIds, ',')  // Join IDs with a comma
                );
    
                Database.SaveResult saveResult = EventBus.publish(event);
    
                if (saveResult.isSuccess()) {
                    System.debug('Platform Event Published Successfully');
                } else {
                    System.debug('Error in Publishing Platform Event');
                }
            }




        }


    }

    class BeforeDelete implements HandleTrigger{
        public void handle(Appointment__c[] oldApps, Appointment__c[] newApps){
            //
            // System.debug('BeforeDelete');
        }

    }

    class AfterDelete implements HandleTrigger{
        public void handle(Appointment__c[] oldApps, Appointment__c[] newApps){
            //
            // System.debug('AfterDelete');
        }

    }

}