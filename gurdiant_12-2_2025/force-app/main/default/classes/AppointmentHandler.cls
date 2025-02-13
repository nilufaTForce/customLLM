public without sharing class AppointmentHandler{
    public static Boolean duplicateAppointment(Appointment__c app){
        List<Appointment__c> conflictingAppointments = [SELECT Id
                                                        FROM Appointment__c
                                                        WHERE Event_ID__c = :app.Event_ID__c];
        
        System.debug('conflictingAppointments-->' + conflictingAppointments);
        if (!conflictingAppointments.isEmpty()){
            return true;
        }
        return false;
    }
    
    public static void assignClinicLocation(Appointment__c app){
        //system.debug('i m in assignClinicLocation');
        DistanceAssignQueueable clinicAssignQueueable = new DistanceAssignQueueable(app.Id, app.Location_Text__c);
        System.enqueueJob(clinicAssignQueueable);
    }
    
    public static void appEmailHandler(Appointment__c app){
        system.debug('in app email handler');
        EventHandler.sentEventToDoctor(app, app.Location_Text__c);
        System.debug('App Email Handler');
        EventHandler.emailToPatient(app);
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
        if (minute.contains('hours') || minute.contains('hour')) {
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
    
    public static void statusValidator(Appointment__c app){
        // if (!app.From_Outlook__c && app.Status__c != 'Requested'){
        //     app.addError('Status should be \'Requested\'');
        // }
    }
    
    public static void assignRoundRobin(Appointment__c app){
        List<Clinic_Resource__c> defualtDoctor = [SELECT Id
                                                  FROM Clinic_Resource__c
                                                  LIMIT 1];
        
        if (defualtDoctor.isEmpty()){
            return;
        }
        
        List<Clinic_Resource__c> allDoctors = [SELECT Id, Auto_Number__c
                                               FROM Clinic_Resource__c
                                               WHERE Clinic_Location__c = :app.Clinic_Location__c];
        Integer totalDoctors = allDoctors.size();
        // List<Integer> allDurationMunites = getAllDurationMinutes();
        Integer roundRobin = roundRobinGenerator(totalDoctors);
        
        if (totalDoctors == 0){
            app.addError('No Doctor is available for the provided clinic location. Please choose a different clinic location and try again.');
        }
        Map<Integer, Clinic_Resource__c> docsMap = new Map<Integer, Clinic_Resource__c>();
        
        Integer counter = 0;
        for (Clinic_Resource__c doc : allDoctors){
            
            docsMap.put(Integer.valueOf(counter), doc);
            counter++;
        }
        
        Id assignedDoc = null;
        // system.debug(docsMap.get(roundRobin).Id);
        for (Integer i = 0; i < totalDoctors; i++){
            System.debug('i-->' + docsMap);
            if (isDoctorAvailable(app.Date_and_Time__c, app.Duration__c, docsMap.get(roundRobin).Id, app.Clinic_Location__c)){
                assignedDoc = docsMap.get(roundRobin).Id;
                break;
            }
            roundRobin = roundRobinGenerator(totalDoctors);
        }
        
        if (assignedDoc == null){
            assignWithoutRoundRobin(app, allDoctors);
        }
        
        app.Clinic_Resource__c = assignedDoc;
    }
    
    public static void assignWithoutRoundRobin(Appointment__c app, List<Clinic_Resource__c> allDoctors){
        for (Clinic_Resource__c doc : allDoctors){
            if (isDoctorAvailable(app.Date_and_Time__c, app.Duration__c, doc.Id, app.Clinic_Location__c)){
                app.Clinic_Resource__c = doc.Id;
                return;
            }
        }
        // app.addError('No doctor is available at this time. Please select different appointment time!');
    }
    
    public static Integer roundRobinGenerator(Integer totalDoctors){
        
        if (totalDoctors == 0){
            return 0;
        }
        
        Integer randomNumber = Integer.valueOf((Integer) (Math.random() * 100));
        // system.debug('i me ' + randomNumber);
        randomNumber = Math.Mod(randomNumber, totalDoctors);
        // system.debug('i m ' + randomNumber);
        return randomNumber;
    }
    
    public static Boolean isDoctorAvailable(DateTime triggeredAppTime, String duration, Id docId, Id clinicLocationId){
        
        List<Appointment__c> appointments = [SELECT Date_and_Time__c, Duration__c
                                             FROM Appointment__c
                                             WHERE Clinic_Resource__c = :docId AND (Status__c != 'completed' OR Status__c != 'declined')
                                             ORDER BY Date_and_Time__c ASC];
        
        if (appointments.isEmpty()){
            return true;
        }
        
        Integer prevIndex = -1;
        Integer nextIndex = -1;
        for (Integer i = 0; i < appointments.size(); i++){
            if (appointments[i].Date_and_Time__c < triggeredAppTime){
                prevIndex = i;
            } else if (appointments[i].Date_and_Time__c == triggeredAppTime){
                return false;
            } else if (appointments[i].Date_and_Time__c > triggeredAppTime){
                nextIndex = i;
                break;
            }
        }
        
        DateTime prevAppointmentDT;
        Boolean isPrevAvailable = false;
        Boolean isNextAvailable = false;
        if (prevIndex != -1){
            prevAppointmentDT = appointments[prevIndex].Date_and_Time__c.addMinutes(formatToIntegerMinute(appointments[prevIndex].Duration__c));
            
            
            // system.debug('m prev' + prevAppointmentDT + ' ' + triggeredAppTime);
            // system.debug(prevAppointmentDT)
            if (prevAppointmentDT <= triggeredAppTime){
                isPrevAvailable = true;
            }
        }
        if (nextIndex != -1){
            triggeredAppTime = triggeredAppTime.addMinutes(formatToIntegerMinute(duration));
            system.debug('m nxt' + triggeredAppTime + ' ' + appointments[nextIndex].Date_and_Time__c);
            if (triggeredAppTime <= appointments[nextIndex].Date_and_Time__c){
                isNextAvailable = true;
            }
        }
        
        // System.debug('prevAppointmentDT-->' + prevAppointmentDT + '    triggeredAppTime-->' + triggeredAppTime + '    appointments[prevIndex].Date_and_Time__c--->' + appointments[prevIndex].Date_and_Time__c);
        
        if (prevIndex != -1 && nextIndex != -1){
            if (isPrevAvailable && isNextAvailable){
                return true;
            }
        }
        if (prevIndex != -1 && nextIndex == -1){
            if (isPrevAvailable){
                return true;
            }
        }
        if (prevIndex == -1 && nextIndex != -1){
            
            
            if (isNextAvailable){
                return true;
            }
        }
        
        return false;
    }
    
    
    public static void formatDateTime(Appointment__c app){
        /*DateTime dt = app.Date_and_Time__c;
        
        String timeFormat2 = dt.format('hh:mm a');
        String timeFormat = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        String dayOfWeek = dt.format('EEEE');  // Thursday
        Integer dayOfMonth = dt.day();        // 21
        String month = dt.format('MMM');      // Oct
        Integer year = dt.year();             // 2024
        
        String daySuffix;
        if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31){
            daySuffix = 'st';
        } else if (dayOfMonth == 2 || dayOfMonth == 22){
            daySuffix = 'nd';
        } else if (dayOfMonth == 3 || dayOfMonth == 23){
            daySuffix = 'rd';
        } else{
            daySuffix = 'th';
        }
        
        String formattedDate = timeFormat2 + '@' + dayOfWeek + ', ' + dayOfMonth + daySuffix + '-' + month + '-' + year;
        app.Format_Date_For_Email__c = timeFormat;
        app.Formatted_Date__c = formattedDate;
         */
    }
    
    public static void notifyAppToPat(Appointment__c app){
        //
        EventHandler.emailToPatient(app);
    }
    
  
    }