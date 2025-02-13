public with sharing class One_Proma {



    public static void getAppointment(   
    String name, 
    date   dob,
    Time startTime, 
    Date appointedDate, 
    Date appointedDateOld,  
    Time startTimeOld,
    String actionType
    ){

        Account patient = getPatientByNameAndDOB(name, dob);
        if (patient == null) {
            throw new AuraHandledException('No patient found with the given name and date of birth.');
        }

           Id patientId = patient.Id;

        

        List<Appointment__c> appointments = [
            SELECT Id, Appointed_Date__c, Start_Time__c, End_Time__c, Patient_Account__c, Status__c 
            FROM Appointment__c  
            WHERE Patient_Account__c = :patientId
            AND Start_Time__c = :startTimeOld 
            AND Appointed_Date__c = :appointedDateOld
            LIMIT 1
        ];
               // Check if an appointment exists
               if (appointments.isEmpty()) {
                throw new AuraHandledException('No matching appointment found.');
            }


        if (appointments.isEmpty()) {
            throw new AuraHandledException('No matching appointment found to reschedule.');
        }
         Appointment__c appointment = appointments[0];


   if(actionType == 'Cancel'){
    Appointment__c newApp = cancelAppointment(appointment);
    update newApp;
        
   }else if(actionType == 'Reschedule'){
    Appointment__c newApp = rescheduleAppointment(appointment,startTime,appointedDate);
    update newApp;
    }
  



}



    public static Account getPatientByNameAndDOB(String name, Date dob) {
        List<Account> patients = [
            SELECT Id, Name, Date_Of_Birth__c 
            FROM  Account
            WHERE Name = :name AND Date_of_Birth__c = :dob
            LIMIT 1
        ];

        return patients.isEmpty() ? null : patients[0]; // Avoid list out-of-bounds error
    }

    public static Appointment__c rescheduleAppointment(
        Appointment__c appointment,
        Time startTime,
        Date appointedDate
    ) {
       
            // Check if the appointment is already completed or canceled
            if (appointment.Status__c == 'Cancelled') {
                throw new AuraHandledException('Cannot reschedule a completed or canceled appointment.');
            }


            Integer startMinutes = (appointment.Start_Time__c.hour() * 60) +appointment.Start_Time__c.minute();
            Integer endMinutes = (appointment.End_Time__c.hour() * 60) + appointment.End_Time__c.minute();


            Integer timeDifferenceMinutes = endMinutes - startMinutes;
            Time newEndTime = startTime.addMinutes(timeDifferenceMinutes);

   
            // Update the appointment details
            appointment.Start_Time__c = startTime;
            appointment.End_Time__c = newEndTime;    
            appointment.Appointed_Date__c = appointedDate;
            // appointment.Status__c = 'Rescheduled';

            return appointment;
      
    }


    public static Appointment__c cancelAppointment(
        Appointment__c appointment
    ) {


            // Check if the appointment is already completed or canceled
            if ( appointment.Status__c == 'Cancelled') {
                throw new AuraHandledException('Cannot cancel an already canceled appointment.');
            }

            // Update the appointment status to 'Cancelled'
            appointment.Status__c = 'Cancelled';

            // Save the changes
            return appointment;
    
    }

}