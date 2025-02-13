public with sharing class MemberPortalController {
    // public MemberPortalController() {

    // }

    @AuraEnabled
    public static List<Clinic_Resource__c> getAllProviders(String rand){
        return [SELECT Id, Name, Clinic_Location__r.Provider_Company__r.Resource_Category__c, Appointment_Type__c, Clinic_Location__r.Provider_Company__c, Clinic_Location__c, Resource_Type__c, Clinic_Location__r.Address_Text__c
                FROM Clinic_Resource__c  WHERE Clinic_Location__r.Status__c != 'Close'
                ORDER BY Name ASC];
    }
    @AuraEnabled
    public static List<Appointment_Type__c> getAllAppTypes(String rand){
        return [SELECT Id, Name, Duration__c, Description__c, Resource_Category__c
                FROM Appointment_Type__c
                ORDER BY Name ASC];
    }
    @AuraEnabled
    public static List<Resource_Category__c> getAllCareCategories(String rand){
        return [SELECT Id, Name
                FROM Resource_Category__c
                ORDER BY Name ASC];
    }

    @AuraEnabled(cacheable=true)
    public static Map<Date, List<TimeSlot>> getAvailableTimeSlots(Integer nextNDays, String providerID) {
        Map<Date, List<TimeSlot>> availableSlotsByDate = new Map<Date, List<TimeSlot>>();

        // Fetch Availabilities for all doctors
        Map<Id, Map<String, List<Availability__c>>> doctorAvailabilities = getDoctorAvailabilities(providerID);
     system.debug('av '+doctorAvailabilities );
        // Fetch Appointments for the next N days
        Map<Date, Map<Id, List<Appointment__c>>> appointmentsByDate = getAppointmentsForNextNDays(nextNDays,providerID);
        //List<String> dayNames = new List<String>{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
        // Iterate through the next N days
        system.debug('ap '+appointmentsByDate );
        for (Integer i = 0; i < nextNDays; i++) {

            Date currentDate = Date.today().addDays(i);

            // Convert the Date to a DateTime instance
            DateTime currentDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0, 0);
        
            // Use the format method on DateTime to get the day of the week
            String dayOfWeek = currentDateTime.format('EEEE'); //

            List<TimeSlot> timeSlotsForDate = new List<TimeSlot>();

            // Iterate through 15-minute intervals for all doctors
            for (Time currentTime = Time.newInstance(0, 0, 0, 0); currentTime < Time.newInstance(23, 45, 0, 0); currentTime = currentTime.addMinutes(15)) {
                Integer maxDuration = 0;

                // Check availability of each doctor
                for (Id doctorId : doctorAvailabilities.keySet()) {
                    // Check if the doctor has availability for the given day
                    if (doctorAvailabilities.containsKey(doctorId) && doctorAvailabilities.get(doctorId).containsKey(dayOfWeek)) {
                        List<Availability__c> availabilities = doctorAvailabilities.get(doctorId).get(dayOfWeek);

                        // Check if the current time is within any availability block
                        for (Availability__c availability : availabilities) {
                            if (currentTime >= availability.Start_Shift__c && currentTime < availability.End_Shift__c) {
                                // Calculate the doctor's max duration based on appointments
                                Integer doctorMaxDuration = getDoctorMaxDuration(doctorId, currentDate, currentTime, availability.End_Shift__c, appointmentsByDate);
                                maxDuration = Math.max(maxDuration, doctorMaxDuration);
                            }
                        }
                    }
                }

                // Add the time slot to the list
                timeSlotsForDate.add(new TimeSlot(currentTime, maxDuration));
            }

            availableSlotsByDate.put(currentDate, timeSlotsForDate);
        }
   system.debug('final '+availableSlotsByDate);
        return availableSlotsByDate;
    }

    private static Map<Id, Map<String, List<Availability__c>>> getDoctorAvailabilities( String providerId) {
        Map<Id, Map<String, List<Availability__c>>> availabilitiesMap = new Map<Id, Map<String, List<Availability__c>>>();
         String  clincId = 'a1OWr000000MKMfMAO';
        //  String clinicId = [SELECT Id FROM Clinic_Location__c WHERE Name = 'We Care Auburn' LIMIT 1].Id;

         List<Availability__c> availabilities = new List<Availability__c> ();
    if(providerId == ''){
  availabilities = [
            SELECT Clinic_Resource__c, Day__c, Start_Shift__c, End_Shift__c
            FROM Availability__c
            Where Clinic_Resource__r.Clinic_Location__c = :clincId
        ];
        system.debug(' helo ' +availabilities);

    }else{
        system.debug(providerId);
      availabilities = [
            SELECT Clinic_Resource__c, Day__c, Start_Shift__c, End_Shift__c
            FROM Availability__c
            WHERE Clinic_Resource__r.Id = :providerId
        ];
        system.debug(' hel ' +availabilities);
 
    }
       // List<Clinic_Resource__c>  doctrs = [SELECT Id FROM Clinic_Resource__c WHERE Clinic_Location__c = :clincId ];
  
        for (Availability__c availability : availabilities) {
            if (!availabilitiesMap.containsKey(availability.Clinic_Resource__c)) {
                availabilitiesMap.put(availability.Clinic_Resource__c, new Map<String, List<Availability__c>>());
            }

            Map<String, List<Availability__c>> dayAvailabilities = availabilitiesMap.get(availability.Clinic_Resource__c);
            if (!dayAvailabilities.containsKey(availability.Day__c)) {
                dayAvailabilities.put(availability.Day__c, new List<Availability__c>());
            }

            dayAvailabilities.get(availability.Day__c).add(availability);
        }

        return availabilitiesMap;
    }

    private static Map<Date, Map<Id, List<Appointment__c >>> getAppointmentsForNextNDays(Integer nextNDays,  String providerId) {
        Map<Date, Map<Id, List<Appointment__c >>> appointmentsByDate = new Map<Date, Map<Id, List<Appointment__c >>>();

        Date startDate = Date.today();
        Date endDate = startDate.addDays(nextNDays);
        String  clincId = 'a1OWr000000MKMfMAO';
        List<Appointment__c > appointments  = new  List<Appointment__c > ();
        if(providerId == ''){
             appointments = [
                SELECT Appointed_Date__c, Clinic_Resource__c, Start_Time__c, End_Time__c
                FROM Appointment__c 
                WHERE Appointed_Date__c >= :startDate AND Appointed_Date__c <= :endDate AND Clinic_Resource__r.Clinic_Location__c = :clincId
                ORDER BY Start_Time__c ASC // Sort by Start_Time__c in ascending order
            ];
        }else{
       appointments = [
                SELECT Appointed_Date__c, Clinic_Resource__c, Start_Time__c, End_Time__c
                FROM Appointment__c 
                WHERE Appointed_Date__c >= :startDate AND Appointed_Date__c <= :endDate AND Clinic_Resource__r.Id = :providerId
                ORDER BY Start_Time__c ASC // Sort by Start_Time__c in ascending order
            ];

        }
   

        for (Appointment__c appointment : appointments) {
            Date datee = appointment.Appointed_Date__c;
            if (!appointmentsByDate.containsKey(datee)) {
                appointmentsByDate.put(datee, new Map<Id, List<Appointment__c>>());
            }

            Map<Id, List<Appointment__c>> doctorAppointments = appointmentsByDate.get(datee);
            if (!doctorAppointments.containsKey(appointment.Clinic_Resource__c)) {
                doctorAppointments.put(appointment.Clinic_Resource__c, new List<Appointment__c>());
            }

            doctorAppointments.get(appointment.Clinic_Resource__c).add(appointment);
        }

        return appointmentsByDate;
    }

    private static Integer getDoctorMaxDuration(
        Id doctorId,
        Date datee,
        Time currentTime,
        Time endTime,
        Map<Date, Map<Id, List<Appointment__c>>> appointmentsByDate
    ) {
        Integer maxDuration = 0;
    
        // Check if there are appointments for this doctor on this date
        if (appointmentsByDate.containsKey(datee) && appointmentsByDate.get(datee).containsKey(doctorId)) {
            List<Appointment__c> appointments = appointmentsByDate.get(datee).get(doctorId);
    
       
            // Find the next available time after the current time
            Time nextOccupiedTime = endTime; // Default to endTime
            Boolean isCurrentTimeBooked = false;
    
            for (Appointment__c appointment : appointments) {
                // Check if currentTime falls within a booked slot
                if (appointment.Start_Time__c <= currentTime && appointment.End_Time__c > currentTime) {
                    isCurrentTimeBooked = true;
                    break;
                }
    
                // Since appointments are sorted by Start_Time__c, the first available appointment is the next available slot
                if (appointment.Start_Time__c > currentTime) {
                    nextOccupiedTime = appointment.Start_Time__c;
                    break; // Exit the loop as soon as we find the next available time
                }
            }
    
            if (isCurrentTimeBooked) {
                // If current time is already booked, max duration is 0
                maxDuration = 0;
            } else {
                // Calculate available time until the next occupied time or the end of availability
                Integer currentTotalMinutes = (currentTime.hour() * 60) + currentTime.minute();
                Integer nextOccupiedTotalMinutes = (nextOccupiedTime.hour() * 60) + nextOccupiedTime.minute();
    
                maxDuration = nextOccupiedTotalMinutes - currentTotalMinutes;
            }
        } else {
            // If no appointments, calculate the full time until endTime
            Integer currentTotalMinutes = (currentTime.hour() * 60) + currentTime.minute();
            Integer endTotalMinutes = (endTime.hour() * 60) + endTime.minute();
    
            maxDuration = endTotalMinutes - currentTotalMinutes;
        }
    
        // Return the calculated max duration
        return maxDuration;
    }


    public class TimeSlot {
        @AuraEnabled
        public Time timee { get; set; } // Mark timee as AuraEnabled
        @AuraEnabled
        public Integer maxDuration { get; set; } 

        public TimeSlot(Time timee, Integer maxDuration) {
            this.timee = timee;
            this.maxDuration = maxDuration;
        }
    }



    // @AuraEnabled
    //  public static  Map < String,  Map < String,String >> getAvailableAppointmentSlots () {
    //     // String clinicId = cliniId; 
    //     String clinicId = 'a1OWr000000MKMfMAO'; //wehealth for collins clinic location id 
    //     List<Clinic_Resource__c> clinicResources =[SELECT Id, Name, Clinic_Location__r.Provider_Company__r.Resource_Category__c, Appointment_Type__c, Clinic_Location__r.Provider_Company__c, Clinic_Location__c, Resource_Type__c, Clinic_Location__r.Address_Text__c
    //     FROM Clinic_Resource__c  WHERE Clinic_Location__r.Status__c != 'Close'
    //     ORDER BY Name ASC];
    //     List <Appointment__c> listOfappointments = [SELECT Name, Id, Appointed_Date__c, Start_Time__c,End_Time__c ,Duration__c, Clinic_Location__c, Clinic_Resource__c FROM Appointment__c WHERE Clinic_Location__c = :clinicId ORDER BY Date_and_Time__c ASC];
    //     List<Clinic_Resource__c> listOfDoctors = clinicResources;
    //     Date todayDate = Date.todayDate();
    //     system.debug(todayDate.format());
    //     Date endDate = todayDate.addDays(30);
    //     Integer nmbrOfDoc = clinicResources.size();
    //     map < String, map < String, List < String >>> slots = new map < String, map < String,List < String >>> (); // my imagined structure {doc->date->{times}}
    //    system.debug('i m doctor numberr'+nmbrOfDoc+'    '+clinicId);
    //     for (Clinic_Resource__c doctor: listOfDoctors) {
    //         map < String,  List < String >> dateTimeMap = new map < String,  List < String >> ();
    //         for (Date currentDate = todayDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
    //             List < String > bookedSlots = new List < String > ();
    //             for (Appointment__c app: listOfAppointments) {
    //                 if (app.Clinic_Resource__c == doctor.Id && app.Appointed_Date__c == currentDate) {
    //                     Integer hours = app.Start_Time__c.hour();    // Get the hour
    //                     Integer minutes = app.Start_Time__c.minute(); // Get the minute
                        
    //                     // Format as a string with leading zeros if necessary
    //                     String appointmentStart = String.format('{0}:{1}',  new List<Object>{hours, (minutes < 10 ? ('0' + minutes.format()) : minutes.format())});
                        
    //                     System.debug(appointmentStart); // Output: 05:30





    //                     Integer hoursEnd = app.End_Time__c.hour();    // Get the hour
    //                     Integer minutesEnd = app.End_Time__c.minute(); // Get the minute
                        
    //                     // Format as a string with leading zeros if necessary
    //                     String appointmentEnd = String.format('{0}:{1}', 
    //                                             new List<Object>{hoursEnd, (minutesEnd < 10 ? ('0' + minutesEnd.format()) : minutesEnd.format())});
                        
    //                     System.debug(appointmentEnd); // Output: 05:30
                        








                        
                        
                      
    //                  //   String appointmentEnd = app.End_Time__c.split(":").slice(0, 2).join(":");
    //                     //String appointmentEnd = appointmentEndDT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ').split('T')[1].split(':')[0] + ':' + appointmentEndDT.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ').split('T')[1].split(':')[1];
    
    //                     bookedSlots.add(appointmentStart + '-' + appointmentEnd);
    
    //                 }
    //             }
    //             //  system.debug('i m current date'+currentDate.format());
    
    //             dateTimeMap.put(currentDate.format(), bookedSlots);
    //         }
    //         slots.put(doctor.Id, dateTimeMap);
    
    //     }
    //     // Simplified Step 2: Calculate available slots with max duration for each hour (8 AM - 8 PM)
    //     Map < String,  Map < String,String >> availableSlots = new Map < String, Map < String,  String >> (); // Structure {date -> {hour -> maxDuration}}
    
    //     for (Date currentDate = todayDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
    //         Map < String,  String > hourlyAvailability = new Map < String,String > ();
    
    //         for (Integer hour = 0; hour <= 24; hour++) { // 8 AM to 8 PM
    //             for (Integer minute = 0; minute < 60; minute += 15) { // I
    //                 String slotStart = (hour < 10 ? '0' + hour : String.valueOf(hour)) + ':' + (minute < 10 ? '0' + minute : String.valueOf(minute));
    //             Integer maxFreeMinutes = 0;
    
    //             for (Clinic_Resource__c doctor: listOfDoctors) {
    //                 List < String > bookedSlots = slots.containsKey(doctor.Id) && slots.get(doctor.Id).containsKey(currentDate.format()) ? slots.get(doctor.Id).get(currentDate.format()) : new List < String > ();
    //                 Integer freeMinutes = 60; // Assume 1 hour initially
    //                 Boolean flag = false;
    //                 for (Integer i = 0; i < bookedSlots.size(); i++) {



    //                     String bookedStart = bookedSlots[i].split('-')[0];
    //                     String bookedEnd = bookedSlots[i].split('-')[1];

                          
                           




    //                     if(i ==  bookedSlots.size()-1){
                                   
    //                         if (bookedEnd.split(':')[0]<= slotStart.split(':')[0] ) {
    //                             if(bookedEnd.split(':')[0]== slotStart.split(':')[0] ){
    //                                 if(bookedEnd.split(':')[1]=='00' ){
    //                                     freeMinutes = 60;
    //                                 }else{
    //                                     freeMinutes = 0;
    //                                 }
    //                             }else{
    //                                 freeMinutes = 60;
    //                             }
    //                              // Entire hour is free after the last appointment
    //                         }else if (bookedStart.split(':')[0] == slotStart.split(':')[0]) {

    //                             if(bookedStart.split(':')[1] =='00'){
    //                                 freeMinutes = 0;  // No free minutes if the slotStart matches bookedStart
    //                             }else if(bookedStart.split(':')[1] =='15'){
    //                                 freeMinutes = 15;
    //                             }else if(bookedStart.split(':')[1] =='30'){
    //                                 freeMinutes = 30;
    //                             }else{
    //                                 freeMinutes = 45;
    //                             }
                               
    //                         } else {
    //                             freeMinutes = 60;
    //                         }
    //                     }else{
                              
                   

    
    //                     String bookedStartNext = bookedSlots[i + 1].split('-')[0];
            
    //                     if ((bookedEnd <= slotStart  && bookedStartNext > slotStart ) || (bookedStart.split(':')[0]  == slotStart.split(':')[0]) ) {
    //                         system.debug('kmn' + ' ' + currentDate.format() + ' ' + slotStart);
    //                         String nextHour = bookedStartNext;
    //                         if ((slotStart.split(':')[0] != nextHour.split(':')[0]) && bookedStart.split(':')[0] != slotStart.split(':')[0]) {
    //                             freeMinutes = 60;
    //                             system.debug('hii');
    //                             break;
    //                         } else if (bookedStart.split(':')[0]  == slotStart.split(':')[0]) {
    //                             if(bookedStart.split(':')[1] =='00'){
    //                                 freeMinutes = 0;
    //                             }else if(bookedStart.split(':')[1] =='15'){
    //                                 freeMinutes = 15;
    //                             }else if(bookedStart.split(':')[1] =='30'){
    //                                 freeMinutes = 30;
    //                             }else{
    //                                 freeMinutes = 45;
    //                             }
                               
    //                         } else {
    //                             system.debug('hello');
    //                             String nextHourMin = bookedStartNext.split(':')[1];
    //                             if (nextHourMin == '15') {
    //                                 freeMinutes = 15;
    //                             } else if (nextHourMin == '30') {
    //                                 freeMinutes = 30;
    //                             } else if (nextHourMin == '45') {
    //                                 freeMinutes = 45;
    //                             } else {
    //                                 freeMinutes = 0;
    //                             }
    //                         }
    //                         flag =true;
    //                         break;
    //                     }
    //                     }

    //                 }
             
    //                 maxFreeMinutes = Math.max(maxFreeMinutes, freeMinutes);
    //                 if (maxFreeMinutes == 60) {
    //                     break;
    //                 }
    //             }
    
    //             if (maxFreeMinutes > 0) {
    //                 hourlyAvailability.put(slotStart, maxFreeMinutes + ' minutes');
    //             }
    
    //         }
    //     }
    //         availableSlots.put(currentDate.format(), hourlyAvailability);
    //     }
    
    //     System.debug('Available slots with max duration for each hour: ' + availableSlots.get('11/8/2024'));
    //     System.debug('Available slots with max duration for each hour: ' + availableSlots.get('11/9/2024'));
    //     System.debug('Available slots with max duration for each hour: ' + availableSlots.get('11/10/2024'));
    
    //     return availableSlots;
    
    // }



//     @AuraEnabled
// public static Map<String, Map<String, String>> getAvailableAppointmentSlots() {
//     String clinicId = 'a1OWr000000MKMfMAO'; // Example clinic ID
    
  
//     // Query clinic resources
//     List<Clinic_Resource__c> clinicResources = [
//         SELECT Id, Name, Clinic_Location__r.Provider_Company__r.Resource_Category__c,
//                Appointment_Type__c, Clinic_Location__r.Provider_Company__c,
//                Clinic_Location__c, Resource_Type__c, Clinic_Location__r.Address_Text__c
//         FROM Clinic_Resource__c
//         WHERE Clinic_Location__r.Status__c != 'Close'
//         ORDER BY Name ASC
//     ];
    
//     // Query appointments
//     List<Appointment__c> listOfAppointments = [
//         SELECT Name, Id, Appointed_Date__c, Start_Time__c, End_Time__c, Duration__c, 
//                Clinic_Location__c, Clinic_Resource__c
//         FROM Appointment__c
//         WHERE Clinic_Location__c = :clinicId
//         ORDER BY Appointed_Date__c ASC
//     ];


//     system.debug('okok'+listOfAppointments);
//     // System.debug('biroktikor');
//     // System.debug('biroktikorEnd');
//     DateTime todayDatee = Date.today();
//     Date todayDate = Date.today();
//     DateTime endDatee = todayDatee.addDays(30);
//     Date endDate = endDatee.date();


//     // Step 1: Create a map of booked slots
//     Map<String, Map<String, List<String>>> slots = new Map<String, Map<String, List<String>>>();
//     for (Clinic_Resource__c doctor : clinicResources) {
//        // system.debug('doc '+doctor);
//         Map<String, List<String>> dateTimeMap = new Map<String, List<String>>();
//         for (Date currentDate = todayDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
//             List<String> bookedSlots = new List<String>();
//             for (Appointment__c app : listOfAppointments) {
//                 if (app.Clinic_Resource__c == doctor.Id && app.Appointed_Date__c == currentDate) {
//                     // Format start and end times
//                     String appointmentStart = String.format('{0}:{1}', 
//                         new List<Object>{app.Start_Time__c.hour(), 
//                         app.Start_Time__c.minute() < 10 ? ('0' + app.Start_Time__c.minute().format()) : app.Start_Time__c.minute().format()});
                    

//                          system.debug('ll'+appointmentStart);
//                     String appointmentEnd = String.format('{0}:{1}', 
//                         new List<Object>{app.End_Time__c.hour(), 
//                         app.End_Time__c.minute() < 10 ?  ('0' + app.End_Time__c.minute().format()) : app.End_Time__c.minute().format()});
//                         system.debug('ll'+appointmentEnd);
//                     bookedSlots.add(appointmentStart + '-' + appointmentEnd);
//                 }
//             }
//             dateTimeMap.put(currentDate.format(), bookedSlots);
//            // system.debug('ccc'+currentDate);

//         }
//         slots.put(doctor.Id, dateTimeMap);
//     }
    

//     // Step 2: Calculate available slots every 15 minutes

//     system.debug(' i m  current proma '+todayDate);


//     // system.debug(todayDate+'biroktikor'+endDate);
//     Map<String, Map<String, String>> availableSlots = new Map<String, Map<String, String>>();
//     for (Date currentDate = Date.today(); currentDate <= endDate; currentDate = currentDate.addDays(1)) {
//         system.debug(' jjjjj '+currentDate);// 
//         Map<String, String> quarterHourlyAvailability = new Map<String, String>();
//         for (Integer hour = 0; hour < 24; hour++) { 
//             system.debug(' jjjjj '+hour);// 8 AM to 8 PM
//             for (Integer minute = 0; minute < 60; minute += 15) { // Increment by 15 minutes
//                 String slotStart = (hour < 10 ? '0' + hour : String.valueOf(hour)) + ':' + (minute < 10 ? '0' + minute : String.valueOf(minute));
//                 Integer maxFreeMinutes = 15;
 
//                 // 8 AM to 8 PM
//                 system.debug(' hii'+clinicResources.size()+ '   ii '+slotStart + 'iui '+minute+ ' ooo '+hour+ ' okok '+currentDate);
//                 for (Clinic_Resource__c doctor : clinicResources) {
//                     system.debug(' hii'+clinicResources.size()+ '   ii '+doctor);
//                     // if(currentDate.format() == '1/27/2025'){
//                     //     system.debug(currentDate.format());
//                     //     system.debug(slots.get(doctor.Id));
                       
//                     // }
         
//                     List<String> bookedSlots = slots.containsKey(doctor.Id) && slots.get(doctor.Id).containsKey(currentDate.format())
//                         ? slots.get(doctor.Id).get(currentDate.format())
//                         : new List<String>();
//                         // if(currentDate.format() == '1/27/2025'){
//                         // system.debug(bookedSlots);
//                         // }
      
//                     Integer freeMinutes = 15; // Assume 15 minutes initially
//                     for (String bookedSlot : bookedSlots) {
//                         String[] slotTimes = bookedSlot.split('-');
//                         String bookedStartTime = slotTimes[0];
//                         String bookedEndTime = slotTimes[1];
                        
//                         Datetime slotStartTime = Datetime.newInstance(currentDate, Time.newInstance(
//                             Integer.valueOf(bookedStartTime.split(':')[0]), 
//                             Integer.valueOf(bookedStartTime.split(':')[1]), 0,0));
//                         Datetime slotEndTime = Datetime.newInstance(currentDate, Time.newInstance(
//                             Integer.valueOf(bookedEndTime.split(':')[0]), 
//                             Integer.valueOf(bookedEndTime.split(':')[1]), 0,0));
//                         Datetime quarterStartTime = Datetime.newInstance(currentDate, Time.newInstance(hour, minute, 0,0));
//                         Datetime quarterEndTime = Datetime.newInstance(currentDate, Time.newInstance(hour, minute + 14, 59,59));

//                         // Check overlap between booked slot and current 15-minute slot
//                         if (slotStartTime < quarterEndTime && slotEndTime > quarterStartTime) {
//                             Datetime overlapStart = slotStartTime > quarterStartTime ? slotStartTime : quarterStartTime;
//                             Datetime overlapEnd = slotEndTime < quarterEndTime ? slotEndTime : quarterEndTime;
//                             Integer overlapMinutes = ((overlapEnd.getTime() - overlapStart.getTime()) / (1000 * 60)).intValue();
//                             freeMinutes -= overlapMinutes;
//                         }
//                     }
                    
//                     maxFreeMinutes = Math.max(maxFreeMinutes, freeMinutes);
//                 }
//                 if(slotStart == '00:00' || slotStart == '00:15'  ||  slotStart == '00:30' || slotStart == '00:45' ){
//                     slotStart = '12:'+slotStart.split(':')[1];
//                 }
//                 quarterHourlyAvailability.put(slotStart, maxFreeMinutes + ' mins');
//             }
//             system.debug(' i m  current hour  '+hour);
//         }
//         availableSlots.put(currentDate.format(), quarterHourlyAvailability);
//         system.debug(' i m  current date '+currentDate);
//         system.debug(' i m  current dateS '+todayDate);
//         system.debug(' i m  current dateE '+endDate);
//     }

//     return availableSlots;
// }

    // public static Map<String, Map<String, String>> getAvailableAppointmentSlots() {
    //     String clinicId = 'a1OWr000000MKMfMAO'; // Example clinic ID
    //     // Query clinic resources
    //     List<Clinic_Resource__c> clinicResources = [
    //         SELECT Id, Name, Clinic_Location__r.Provider_Company__r.Resource_Category__c,
    //                Appointment_Type__c, Clinic_Location__r.Provider_Company__c,
    //                Clinic_Location__c, Resource_Type__c, Clinic_Location__r.Address_Text__c
    //         FROM Clinic_Resource__c
    //         WHERE Clinic_Location__r.Status__c != 'Close'
    //         ORDER BY Name ASC
    //     ];
        
    //     // Query appointments
    //     List<Appointment__c> listOfAppointments = [
    //         SELECT Name, Id, Appointed_Date__c, Start_Time__c, End_Time__c, Duration__c, 
    //                Clinic_Location__c, Clinic_Resource__c
    //         FROM Appointment__c
    //         WHERE Clinic_Location__c = :clinicId
    //         ORDER BY Appointed_Date__c ASC
    //     ];

    //     Date todayDate = Date.todayDate();
    //     Date endDate = todayDate.addDays(30);

    //     // Step 1: Create a map of booked slots
    //     Map<String, Map<String, List<String>>> slots = new Map<String, Map<String, List<String>>>();
    //     for (Clinic_Resource__c doctor : clinicResources) {
    //         Map<String, List<String>> dateTimeMap = new Map<String, List<String>>();
    //         for (Date currentDate = todayDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
    //             List<String> bookedSlots = new List<String>();
    //             for (Appointment__c app : listOfAppointments) {
    //                 if (app.Clinic_Resource__c == doctor.Id && app.Appointed_Date__c == currentDate) {
    //                     // Format start and end times
    //                     String appointmentStart = String.format('{0}:{1}', 
    //                         new List<Object>{app.Start_Time__c.hour(), 
    //                         app.Start_Time__c.minute() < 10 ? ('0' + app.Start_Time__c.minute().format()) : app.Start_Time__c.minute().format()});
                        
    //                     String appointmentEnd = String.format('{0}:{1}', 
    //                         new List<Object>{app.End_Time__c.hour(), 
    //                         app.End_Time__c.minute() < 10 ?  ('0' + app.End_Time__c.minute().format()) : app.End_Time__c.minute().format()});
                        
    //                     bookedSlots.add(appointmentStart + '-' + appointmentEnd);
    //                 }
    //             }
    //             dateTimeMap.put(currentDate.format(), bookedSlots);
    //         }
    //         slots.put(doctor.Id, dateTimeMap);
    //     }

    //     // Step 2: Calculate available slots with maximum free minutes
    //     Map<String, Map<String, String>> availableSlots = new Map<String, Map<String, String>>();
    //     for (Date currentDate = todayDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
    //         Map<String, String> hourlyAvailability = new Map<String, String>();
    //         for (Integer hour = 8; hour <= 20; hour++) { // 8 AM to 8 PM
    //             String slotStart = (hour < 10 ? '0' + hour : String.valueOf(hour)) + ':00';
    //             Integer maxFreeMinutes = 0;

    //             for (Clinic_Resource__c doctor : clinicResources) {
    //                 List<String> bookedSlots = slots.containsKey(doctor.Id) && slots.get(doctor.Id).containsKey(currentDate.format())
    //                     ? slots.get(doctor.Id).get(currentDate.format())
    //                     : new List<String>();
                    
    //                 Integer freeMinutes = 60; // Assume 1 hour initially
    //                 for (String bookedSlot : bookedSlots) {
    //                     String[] slotTimes = bookedSlot.split('-');
    //                     String bookedStartTime = slotTimes[0];
    //                     String bookedEndTime = slotTimes[1];
                        
    //                     Datetime slotStartTime = Datetime.newInstance(currentDate, Time.newInstance(
    //                         Integer.valueOf(bookedStartTime.split(':')[0]), 
    //                         Integer.valueOf(bookedStartTime.split(':')[1]), 0,0));
    //                     Datetime slotEndTime = Datetime.newInstance(currentDate, Time.newInstance(
    //                         Integer.valueOf(bookedEndTime.split(':')[0]), 
    //                         Integer.valueOf(bookedEndTime.split(':')[1]), 0,0));
    //                     Datetime hourStartTime = Datetime.newInstance(currentDate, Time.newInstance(hour, 0, 0,0));
    //                     Datetime hourEndTime = Datetime.newInstance(currentDate, Time.newInstance(hour, 59, 59,59));

    //                     // Check overlap between booked slot and current hour
    //                     if (slotStartTime < hourEndTime && slotEndTime > hourStartTime) {
    //                         Datetime overlapStart = slotStartTime > hourStartTime ? slotStartTime : hourStartTime;
    //                         Datetime overlapEnd = slotEndTime < hourEndTime ? slotEndTime : hourEndTime;
    //                         Integer overlapMinutes = ((overlapEnd.getTime() - overlapStart.getTime()) / (1000 * 60)).intValue();
    //                         freeMinutes -= overlapMinutes;
    //                     }
    //                 }
    //                 maxFreeMinutes = Math.max(maxFreeMinutes, freeMinutes);
    //             }
    //             hourlyAvailability.put(slotStart, maxFreeMinutes + ' mins');
    //         }
    //         availableSlots.put(currentDate.format(), hourlyAvailability);
    //     }

    //     return availableSlots;
    // }


    @AuraEnabled
    public static Map<String, Map<String, String>> getAvailableAppointmentSlots() {
        String clinicId = 'a1OWr000000MKMfMAO'; // Example clinic ID
        
    
        // Query clinic resources
        List<Clinic_Resource__c> clinicResources = [
            SELECT Id, Name, Clinic_Location__r.Provider_Company__r.Resource_Category__c,
                   Appointment_Type__c, Clinic_Location__r.Provider_Company__c,
                   Clinic_Location__c, Resource_Type__c, Clinic_Location__r.Address_Text__c
            FROM Clinic_Resource__c
            WHERE Clinic_Location__r.Status__c != 'Close'
            ORDER BY Name ASC
        ];
    
        // Query appointments
        List<Appointment__c> listOfAppointments = [
            SELECT Name, Id, Appointed_Date__c, Start_Time__c, End_Time__c, Duration__c, 
                   Clinic_Location__c, Clinic_Resource__c
            FROM Appointment__c
            WHERE Clinic_Location__c = :clinicId
            ORDER BY Appointed_Date__c ASC
        ];
    
        Date todayDate = Date.today();
        Integer totalDays = 30; // Days to iterate
    
        // Step 1: Create a map of booked slots
        Map<String, Map<String, List<String>>> slots = new Map<String, Map<String, List<String>>>();
    
        // Group appointments by Clinic_Resource__c and Appointed_Date__c for bulk processing
        Map<String, Map<Date, List<Appointment__c>>> appointmentsByResourceAndDate = new Map<String, Map<Date, List<Appointment__c>>>();
        for (Appointment__c app : listOfAppointments) {
            if (!appointmentsByResourceAndDate.containsKey(app.Clinic_Resource__c)) {
                appointmentsByResourceAndDate.put(app.Clinic_Resource__c, new Map<Date, List<Appointment__c>>());
            }
            Map<Date, List<Appointment__c>> dateMap = appointmentsByResourceAndDate.get(app.Clinic_Resource__c);
            if (!dateMap.containsKey(app.Appointed_Date__c)) {
                dateMap.put(app.Appointed_Date__c, new List<Appointment__c>());
            }
            dateMap.get(app.Appointed_Date__c).add(app);
        }
    
        for (Clinic_Resource__c doctor : clinicResources) {
            Map<String, List<String>> dateTimeMap = new Map<String, List<String>>();
            for (Integer dayOffset = 0; dayOffset < totalDays; dayOffset++) {
                Date currentDate = todayDate.addDays(dayOffset);
                List<String> bookedSlots = new List<String>();
                if (appointmentsByResourceAndDate.containsKey(doctor.Id) && appointmentsByResourceAndDate.get(doctor.Id).containsKey(currentDate)) {
                    for (Appointment__c app : appointmentsByResourceAndDate.get(doctor.Id).get(currentDate)) {
                        String appointmentStart = String.format('{0}:{1}', 
                            new List<Object>{app.Start_Time__c.hour(), 
                            app.Start_Time__c.minute() < 10 ? ('0' + app.Start_Time__c.minute().format()) : app.Start_Time__c.minute().format()});
                        String appointmentEnd = String.format('{0}:{1}', 
                            new List<Object>{app.End_Time__c.hour(), 
                            app.End_Time__c.minute() < 10 ?  ('0' + app.End_Time__c.minute().format()) : app.End_Time__c.minute().format()});
                        bookedSlots.add(appointmentStart + '-' + appointmentEnd);
                    }
                }
                dateTimeMap.put(currentDate.format(), bookedSlots);
            }
            slots.put(doctor.Id, dateTimeMap);
        }
    
        // Step 2: Calculate available slots every 15 minutes
        Map<String, Map<String, String>> availableSlots = new Map<String, Map<String, String>>();
    
        for (Integer dayOffset = 0; dayOffset < totalDays; dayOffset++) {
            Date currentDate = todayDate.addDays(dayOffset);
            System.debug('currentDate: '+currentDate);

            Map<String, String> quarterHourlyAvailability = new Map<String, String>();
            for (Integer hour = 0; hour < 24; hour++) {
                for (Integer minute = 0; minute < 60; minute += 15) {
                    String slotStart = (hour < 10 ? '0' + hour : String.valueOf(hour)) + ':' + (minute < 10 ? '0' + minute : String.valueOf(minute));
                    Integer maxFreeMinutes = 15;
    
                    for (Clinic_Resource__c doctor : clinicResources) {
                        // List<String> bookedSlots = slots.containsKey(doctor.Id) && slots.get(doctor.Id).containsKey(currentDate.format())
                        //     ? slots.get(doctor.Id).get(currentDate.format())
                        //     : new List<String>();
    
                        // Integer freeMinutes = 15; // Assume 15 minutes initially
                        // for (String bookedSlot : bookedSlots) {
                        //     String[] slotTimes = bookedSlot.split('-');
                        //     String bookedStartTime = slotTimes[0];
                        //     String bookedEndTime = slotTimes[1];
    
                        //     Datetime slotStartTime = Datetime.newInstance(currentDate, Time.newInstance(
                        //         Integer.valueOf(bookedStartTime.split(':')[0]), 
                        //         Integer.valueOf(bookedStartTime.split(':')[1]), 0, 0));
                        //     Datetime slotEndTime = Datetime.newInstance(currentDate, Time.newInstance(
                        //         Integer.valueOf(bookedEndTime.split(':')[0]), 
                        //         Integer.valueOf(bookedEndTime.split(':')[1]), 0, 0));
                        //     Datetime quarterStartTime = Datetime.newInstance(currentDate, Time.newInstance(hour, minute, 0, 0));
                        //     Datetime quarterEndTime = Datetime.newInstance(currentDate, Time.newInstance(hour, minute + 14, 59, 0));
    
                        //     // Check overlap between booked slot and current 15-minute slot
                        //     if (slotStartTime < quarterEndTime && slotEndTime > quarterStartTime) {
                        //         Datetime overlapStart = slotStartTime > quarterStartTime ? slotStartTime : quarterStartTime;
                        //         Datetime overlapEnd = slotEndTime < quarterEndTime ? slotEndTime : quarterEndTime;
                        //         Integer overlapMinutes = ((overlapEnd.getTime() - overlapStart.getTime()) / (1000 * 60)).intValue();
                        //         freeMinutes -= overlapMinutes;
                        //     }
                        // }
    
                        // maxFreeMinutes = Math.max(maxFreeMinutes, freeMinutes);
                    }
    
                    if (slotStart == '00:00' || slotStart == '00:15' || slotStart == '00:30' || slotStart == '00:45') {
                        slotStart = '12:' + slotStart.split(':')[1];
                    }
                    quarterHourlyAvailability.put(slotStart, maxFreeMinutes + ' mins');
                }
            }
            availableSlots.put(currentDate.format(), quarterHourlyAvailability);
        }
    
        return availableSlots;
    }
    
    
    public static Integer formatToIntegerMinute(String minute){
        
        // if (!minute.split(' ').isEmpty()){
        //     return Integer.valueOf(minute.split(' ')[0]);
        // }
        // //system.debug('who' + Integer.valueOf(minute.substring(0, 2)));
        // return Integer.valueOf(minute.substring(0, 2));
        if (String.isEmpty(minute)) {
            throw new IllegalArgumentException('Minute string is empty.');
        }
    
        // Handle common cases where the input is a duration like "60 minutes"
        if (minute.contains('minutes') || minute.contains('hour')) {
            String[] parts = minute.split(' ');
            try {
                return Integer.valueOf(parts[0]);
            } catch (Exception e) {
                throw new IllegalArgumentException('Invalid duration format: ' + minute);
            }
        }
    
        // Handle cases where the duration is already in a numeric format (e.g., "60")
        try {
            return Integer.valueOf(minute);
        } catch (Exception e) {
            throw new IllegalArgumentException('Invalid duration format: ' + minute);
        }
    }
}