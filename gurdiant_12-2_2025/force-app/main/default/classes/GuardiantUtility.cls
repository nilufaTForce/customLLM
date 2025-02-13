public without sharing class GuardiantUtility{
    
    
    public static Map<String, Decimal> getTimeZonesMap() {
        // Map where the Key is the IANA time zone, and the Value is the GMT time zone
        Map<String, Decimal> timezonesMap = new Map<String, Decimal>();
        
        // United States
        timezonesMap.put('Dateline Standard Time', -12); //(UTC-12:00) Aleutian Islands
        timezonesMap.put('Samoa Standard Time', -12); //(UTC+13:00) Samoa
        timezonesMap.put('UTC-11', -11); //(UTC-11:00) Coordinated Universal Time-11
        timezonesMap.put('Aleutian Standard Time', -10); //(UTC-10:00) Aleutian Islands
        timezonesMap.put('Hawaiian Standard Time', -10); //(UTC-10:00) Hawaii
        timezonesMap.put('Marquesas Standard Time', -9.5); //(UTC-09:30) Marquesas Islands
        timezonesMap.put('Alaskan Standard Time', -9); //(UTC-09:00) Alaska
        timezonesMap.put('UTC-09', -9); //(UTC-09:00) Coordinated Universal Time-09
        timezonesMap.put('Yukon Standard Time', -7); //(UTC-07:00) Yukon
        timezonesMap.put('Pacific Standard Time (Mexico)', -8); //(UTC-08:00) Baja California
        timezonesMap.put('UTC-08', -8); //(UTC-08:00) Coordinated Universal Time-08
        timezonesMap.put('Pacific Standard Time', -8); //(UTC-08:00) Pacific Time (US & Canada)
        timezonesMap.put('US Mountain Standard Time', -7); //(UTC-07:00) Arizona
        timezonesMap.put('Mountain Standard Time (Mexico)', -7); //(UTC-07:00) La Paz, Mazatlan
        timezonesMap.put('Mountain Standard Time', -7); //(UTC-07:00) Mountain Time (US & Canada)
        timezonesMap.put('Eastern Standard Time (Mexico)', -5); //(UTC-05:00) Chetumal
        timezonesMap.put('Central America Standard Time', -5); //(UTC-06:00) Central America
        timezonesMap.put('Central Standard Time', -6); //(UTC-06:00) Central Time (US & Canada)
        timezonesMap.put('Easter Island Standard Time', -6); //(UTC-06:00) Easter Island
        timezonesMap.put('Central Standard Time (Mexico)', -6); //(UTC-06:00) Guadalajara, Mexico City, Monterrey
        timezonesMap.put('Canada Central Standard Time', -6); //(UTC-06:00) Saskatchewan
        timezonesMap.put('SA Pacific Standard Time', -5); //(UTC-05:00) Bogota, Lima, Quito, Rio Branco
        timezonesMap.put('Eastern Standard Time', -5); //(UTC-05:00) Eastern Time (US & Canada)
        timezonesMap.put('Haiti Standard Time', -5); //(UTC-05:00) Haiti
        timezonesMap.put('Cuba Standard Time', -5); //(UTC-05:00) Havana
        timezonesMap.put('US Eastern Standard Time', -5); //(UTC-05:00) Indiana (East)
        timezonesMap.put('Turks And Caicos Standard Time', -5); //(UTC-05:00) Turks and Caicos
        timezonesMap.put('Venezuela Standard Time', -4); //(UTC-04:00) Caracas
        timezonesMap.put('Magallanes Standard Time', -3); //(UTC-03:00) Punta Arenas
        timezonesMap.put('Paraguay Standard Time', -4); //(UTC-04:00) Asuncion
        timezonesMap.put('Atlantic Standard Time', -4); //(UTC-04:00) Atlantic Time (Canada)
        timezonesMap.put('Central Brazilian Standard Time', -4); //(UTC-04:00) Cuiaba
        timezonesMap.put('SA Western Standard Time', -4); //(UTC-04:00) Georgetown, La Paz, Manaus, San Juan
        timezonesMap.put('Pacific SA Standard Time', -4); //(UTC-04:00) Santiago
        timezonesMap.put('Newfoundland Standard Time', -3.5); //(UTC-03:30) Newfoundland
        timezonesMap.put('Tocantins Standard Time', -3); //(UTC-03:00) Araguaina
        timezonesMap.put('E. South America Standard Time', -3); //(UTC-03:00) Brasilia
        timezonesMap.put('SA Eastern Standard Time', -3); //(UTC-03:00) Cayenne, Fortaleza
        timezonesMap.put('Argentina Standard Time', -3); //(UTC-03:00) City of Buenos Aires
        timezonesMap.put('Greenland Standard Time', -2); //(UTC-02:00) Greenland
        timezonesMap.put('Montevideo Standard Time', -3); //(UTC-03:00) Montevideo
        timezonesMap.put('Saint Pierre Standard Time', -3); //(UTC-03:00) Saint Pierre and Miquelon
        timezonesMap.put('Bahia Standard Time', -3); //(UTC-03:00) Salvador
        timezonesMap.put('UTC-02', -2); //(UTC-02:00) Coordinated Universal Time-02
        timezonesMap.put('Mid-Atlantic Standard Time', -2); //(UTC-02:00) Mid-Atlantic - Old
        timezonesMap.put('Azores Standard Time', -1); //(UTC-01:00) Azores
        timezonesMap.put('Cape Verde Standard Time', -1); //(UTC-01:00) Cabo Verde Is.
        timezonesMap.put('UTC', 0); //(UTC) Coordinated Universal Time
        timezonesMap.put('GMT Standard Time', 0); //(UTC+00:00) Dublin, Edinburgh, Lisbon, London
        timezonesMap.put('Greenwich Standard Time', 0); //(UTC+00:00) Monrovia, Reykjavik
        timezonesMap.put('Morocco Standard Time', 1); //(UTC+01:00) Casablanca
        timezonesMap.put('W. Europe Standard Time', 1); //(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
        timezonesMap.put('Central Europe Standard Time', 1); //(UTC+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague
        timezonesMap.put('Romance Standard Time', 1); //(UTC+01:00) Brussels, Copenhagen, Madrid, Paris
        timezonesMap.put('Central European Standard Time', 1); //(UTC+01:00) Sarajevo, Skopje, Warsaw, Zagreb
        timezonesMap.put('W. Central Africa Standard Time', 1); //(UTC+01:00) West Central Africa
        timezonesMap.put('Libya Standard Time', 2); //(UTC+02:00) Tripoli
        timezonesMap.put('Namibia Standard Time', 2); //(UTC+02:00) Windhoek
        timezonesMap.put('GTB Standard Time', 2); //(UTC+02:00) Athens, Bucharest
        timezonesMap.put('Middle East Standard Time', 2); //(UTC+02:00) Beirut
        timezonesMap.put('Egypt Standard Time', 2); //(UTC+02:00) Cairo
        timezonesMap.put('E. Europe Standard Time', 2); //(UTC+02:00) Chisinau
        timezonesMap.put('Syria Standard Time', 2); //(UTC+03:00) Damascus
        timezonesMap.put('West Bank Standard Time', 2); //(UTC+02:00) Gaza, Hebron
        timezonesMap.put('South Africa Standard Time', 2); //(UTC+02:00) Harare, Pretoria
        timezonesMap.put('FLE Standard Time', 2); //(UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius
        timezonesMap.put('Israel Standard Time', 2); //(UTC+02:00) Jerusalem
        timezonesMap.put('South Sudan Standard Time', 2); //(UTC+02:00) Juba
        timezonesMap.put('Kaliningrad Standard Time', 2); //(UTC+02:00) Kaliningrad
        timezonesMap.put('Sudan Standard Time', 2); //(UTC+02:00) Khartoum
        timezonesMap.put('Jordan Standard Time', 3); //(UTC+03:00) Amman
        timezonesMap.put('Turkey Standard Time', 3); //(UTC+03:00) Istanbul
        timezonesMap.put('Belarus Standard Time', 3); //(UTC+03:00) Minsk
        timezonesMap.put('Arabic Standard Time', 3); //(UTC+03:00) Baghdad
        timezonesMap.put('Arab Standard Time', 3); //(UTC+03:00) Kuwait, Riyadh
        timezonesMap.put('Russian Standard Time', 3); //(UTC+03:00) Moscow, St. Petersburg
        timezonesMap.put('E. Africa Standard Time', 3); //(UTC+03:00) Nairobi
        timezonesMap.put('Volgograd Standard Time', 3); //(UTC+03:00) Volgograd
        timezonesMap.put('Astrakhan Standard Time', 4); //(UTC+04:00) Astrakhan, Ulyanovsk
        timezonesMap.put('Russia Time Zone 3', 4); //(UTC+04:00) Izhevsk, Samara
        timezonesMap.put('Saratov Standard Time', 4); //(UTC+04:00) Saratov
        timezonesMap.put('Iran Standard Time', 3.5); //(UTC+03:30) Tehran
        timezonesMap.put('Arabian Standard Time', 4); //(UTC+04:00) Abu Dhabi, Muscat
        timezonesMap.put('Azerbaijan Standard Time', 4); //(UTC+04:00) Baku
        timezonesMap.put('Mauritius Standard Time', 4); //(UTC+04:00) Port Louis
        timezonesMap.put('Georgian Standard Time', 4); //(UTC+04:00) Tbilisi
        timezonesMap.put('Caucasus Standard Time', 4); //(UTC+04:00) Yerevan
        timezonesMap.put('Afghanistan Standard Time', 4.5); //(UTC+04:30) Kabul
        timezonesMap.put('Qyzylorda Standard Time', 5); //(UTC+05:00) Astana
        timezonesMap.put('Ekaterinburg Standard Time', 5); //(UTC+05:00) Ekaterinburg
        timezonesMap.put('Pakistan Standard Time', 5); //(UTC+05:00) Islamabad, Karachi
        timezonesMap.put('India Standard Time', 5.5); //(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi
        timezonesMap.put('Sri Lanka Standard Time', 5.5); //(UTC+05:30) Sri Jayawardenepura
        timezonesMap.put('Nepal Standard Time', 5.75); //(UTC+05:45) Kathmandu
        timezonesMap.put('Central Asia Standard Time', 6); //(UTC+06:00) Bishkek
        timezonesMap.put('Bangladesh Standard Time', 6); //(UTC+06:00) Dhaka
        timezonesMap.put('Omsk Standard Time', 6); //(UTC+06:00) Omsk
        timezonesMap.put('Altai Standard Time', 6); //(UTC+07:00) Barnaul, Gorno-Altaysk
        timezonesMap.put('N. Central Asia Standard Time', 7); //(UTC+07:00) Novosibirsk
        timezonesMap.put('Tomsk Standard Time', 7); //(UTC+07:00) Tomsk
        timezonesMap.put('Myanmar Standard Time', 6.5); //(UTC+06:30) Yangon (Rangoon)
        timezonesMap.put('SE Asia Standard Time', 6.5); //(UTC+07:00) Bangkok, Hanoi, Jakarta
        timezonesMap.put('North Asia Standard Time', 7); //(UTC+07:00) Krasnoyarsk
        timezonesMap.put('China Standard Time', 8); //(UTC+08:00) Beijing, Chongqing, Hong Kong, Urumqi
        timezonesMap.put('North Asia East Standard Time', 8); //(UTC+08:00) Irkutsk
        timezonesMap.put('Singapore Standard Time', 8); //(UTC+08:00) Kuala Lumpur, Singapore
        timezonesMap.put('W. Australia Standard Tim', 8); //(UTC+08:00) Perth
        timezonesMap.put('Taipei Standard Time', 8); //(UTC+08:00) Taipe
        timezonesMap.put('Ulaanbaatar Standard Time', 8); //(UTC+08:00) Ulaanbaatar
        timezonesMap.put('Transbaikal Standard Time', 9); //(UTC+09:00) Chita
        timezonesMap.put('North Korea Standard Time', 9); //(UTC+09:00) Pyongyang
        timezonesMap.put('Aus Central W. Standard Time', 8.75); //(UTC+08:45) Eucla
        timezonesMap.put('Tokyo Standard Time', 9); //(UTC+09:00) Osaka, Sapporo, Tokyo
        timezonesMap.put('Korea Standard Time', 9); //(UTC+09:00) Seoul
        timezonesMap.put('Yakutsk Standard Time', 9); //(UTC+09:00) Yakutsk
        timezonesMap.put('Cen. Australia Standard Time', 9.5); //(UTC+09:30) Adelaide
        timezonesMap.put('AUS Central Standard Time', 9.5); //(UTC+09:30) Darwin
        timezonesMap.put('E. Australia Standard Time', 10); //(UTC+10:00) Brisbane
        timezonesMap.put('AUS Eastern Standard Time', 10); //(UTC+10:00) Canberra, Melbourne, Sydney
        timezonesMap.put('West Pacific Standard Time', 10); //(UTC+10:00) Guam, Port Moresby
        timezonesMap.put('Tasmania Standard Time', 10); //(UTC+10:00) Hobart
        timezonesMap.put('Vladivostok Standard Time', 10); //(UTC+10:00) Vladivostok
        timezonesMap.put('Bougainville Standard Time', 11); //(UTC+11:00) Bougainville Island
        timezonesMap.put('Magadan Standard Time', 11); //(UTC+11:00) Magadan
        timezonesMap.put('Sakhalin Standard Time', 11); //(UTC+11:00) Sakhalin
        timezonesMap.put('Lord Howe Standard Time', 11); //(UTC+10:30) Lord Howe Island
        timezonesMap.put('Russia Time Zone 10', 11); //(UTC+11:00) Chokurdakh
        timezonesMap.put('Norfolk Standard Time', 11); //(UTC+11:00) Norfolk Island
        timezonesMap.put('Central Pacific Standard Time', 11); //(UTC+11:00) Solomon Is., New Caledonia
        timezonesMap.put('Russia Time Zone 11', 12); //(UTC+12:00) Anadyr, Petropavlovsk-Kamchatsky
        timezonesMap.put('New Zealand Standard Time', 12); //(UTC+12:00) Auckland, Wellington
        timezonesMap.put('UTC+12', 12); //(UTC+12:00) Coordinated Universal Time+12
        timezonesMap.put('Fiji Standard Time', 12); //(UTC+12:00) Fiji
        timezonesMap.put('Kamchatka Standard Time', 12); //(UTC+12:00) Petropavlovsk-Kamchatsky - Old
        timezonesMap.put('Chatham Islands Standard Time', 12.75); //(UTC+12:45) Chatham Islands
        timezonesMap.put('UTC+13', 11); //(UTC+13:00) Coordinated Universal Time+13
        timezonesMap.put('Tonga Standard Time', 13); //(UTC+13:00) Nuku'alofa
        timezonesMap.put('Line Islands Standard Time', 14); //(UTC+14:00) Kiritimati Island
        
        
        return timezonesMap;
    }
    
    
    public static String formatTime(Time inputTime) {
        Integer hour = inputTime.hour();
        Integer minute = inputTime.minute();
        
        
        
        String period = hour < 12 ? 'AM' : 'PM';
        if (hour == 0) {
            hour = 12;
        } else if (hour > 12) {
            hour -= 12;
        }
        
        //String formattedTime = hour + ':' + String.format('{0,number,00}', new Object[]{minute}) + ' ' + period;
        
        String minuteStr = (minute < 10) ? '0' + String.valueOf(minute) : String.valueOf(minute);
        
        String formattedTime = hour + ':' + minuteStr + ' ' + period;
        
        return formattedTime;
    }
    
    public static String formatDate(Date inputDate) {
        Date datePart = inputDate;
        
        Integer day = datePart.day();
        Integer month = datePart.month();
        Integer year = datePart.year();
        
        String dayWithSuffix = getDayWithSuffix(day);
        
        String monthName = getMonthShortName(month);
        
        String formattedDate = dayWithSuffix + '-' + monthName + '-' + year;
        
        return formattedDate;
    }
    
    public static String getDayWithSuffix(Integer day) {
        
        String daySrt = String.valueOf(day);
        
        if (day >= 11 && day <= 13) {
            return day + 'th';
        }
        
        day = math.mod(day, 10);
        
        switch on day {
            when 1 {
                daySrt = daySrt + 'st';
            }
            when 2 {
                daySrt = daySrt + 'nd';
            }
            when 3 {
                daySrt = daySrt + 'rd';
            }
            when else {
                daySrt = daySrt + 'th';
            }
        }
        
        return daySrt;
    }
    
    public static String getMonthShortName(Integer month) {
        List<String> months = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
        return months[month - 1];
    }
    public static void sendEmail() {
        try {
            // Create an instance of the email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Set the recipient, subject, and Org-Wide Email Address
            mail.setToAddresses(new String[] {'saiful@solve4u.io'});
            // mail.setToAddresses(new String[] {'nilufaakter234@gmail.com'});
            mail.setSubject('Your Subject Here');
            // OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
            // OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'ahnaf@solve4u.io' LIMIT 1];
            OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
            
 
            mail.setOrgWideEmailAddressId(owea.Id);
            // mail.setOrgWideEmailAddressId('0D2Wr0000000NavKAE'); 
         
            mail.setHtmlBody('<html><body><h1>Hello!</h1><p>This is a <b>test</b> email sent from Salesforce.</p></body></html>');
            
            // Set the body to null (this would override the HTML body if you set this)
            mail.setPlainTextBody(null);
            mail.setReplyTo('will@solve4u.io');
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            // Debug log to check if the email was sent
            System.debug('Email sent successfully to: ' + String.join(mail.getToAddresses(), ', '));
        } catch (Exception e) {
            // Log the exception in case sending fails
            System.debug('Error sending email: ' + e.getMessage());
        }
    }
    
    
    
    
}