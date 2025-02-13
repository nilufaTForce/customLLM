public with sharing class stateTimeZoneUtility {
    // Method to return a map of IANA time zones to GMT offsets
    public static Map<String, String> getIanaToGmtMap() {
        // Map where the Key is the IANA time zone, and the Value is the GMT time zone
        Map<String, String> ianaToGmtMap = new Map<String, String>();

        // United States
        ianaToGmtMap.put('America/New_York', 'GMT-05:00'); // Eastern Time
        ianaToGmtMap.put('America/Chicago', 'GMT-06:00'); // Central Time
        ianaToGmtMap.put('America/Denver', 'GMT-07:00'); // Mountain Time
        ianaToGmtMap.put('America/Los_Angeles', 'GMT-08:00'); // Pacific Time
        ianaToGmtMap.put('America/Anchorage', 'GMT-09:00'); // Alaska Standard Time
        ianaToGmtMap.put('Pacific/Honolulu', 'GMT-10:00'); // Hawaii-Aleutian Standard Time
        ianaToGmtMap.put('America/Phoenix', 'GMT-07:00'); // Arizona (no DST)

        // Canada
        ianaToGmtMap.put('America/Toronto', 'GMT-05:00'); // Ontario (Eastern Time)
        ianaToGmtMap.put('America/Vancouver', 'GMT-08:00'); // British Columbia (Pacific Time)
        ianaToGmtMap.put('America/Edmonton', 'GMT-07:00'); // Alberta (Mountain Time)

        // Europe
        ianaToGmtMap.put('Europe/London', 'GMT+00:00'); // United Kingdom (Greenwich Mean Time)
        ianaToGmtMap.put('Europe/Paris', 'GMT+01:00'); // France (Central European Time)
        ianaToGmtMap.put('Europe/Berlin', 'GMT+01:00'); // Germany
        ianaToGmtMap.put('Europe/Moscow', 'GMT+03:00'); // Russia (Moscow Standard Time)
        ianaToGmtMap.put('Europe/Zurich', 'GMT+01:00'); // Switzerland (Central European Time)

        // Asia
        ianaToGmtMap.put('Asia/Tokyo', 'GMT+09:00'); // Japan Standard Time (JST)
        ianaToGmtMap.put('Asia/Kolkata', 'GMT+05:30'); // India Standard Time (IST)
        ianaToGmtMap.put('Asia/Shanghai', 'GMT+08:00'); // China Standard Time (CST)
        ianaToGmtMap.put('Asia/Dubai', 'GMT+04:00'); // UAE (Gulf Standard Time)
        ianaToGmtMap.put('Asia/Singapore', 'GMT+08:00'); // Singapore Standard Time (SGT)
        ianaToGmtMap.put('Asia/Kuala_Lumpur', 'GMT+08:00'); // Malaysia
        ianaToGmtMap.put('Asia/Dhaka', 'GMT+06:00'); // Bangladesh Standard Time (BST)
        ianaToGmtMap.put('Asia/Seoul', 'GMT+09:00'); // South Korea
        ianaToGmtMap.put('Asia/Bangkok', 'GMT+07:00'); // Thailand (Indochina Time)
        ianaToGmtMap.put('Asia/Jakarta', 'GMT+07:00'); // Indonesia (Western Indonesia Time)

        // Australia
        ianaToGmtMap.put('Australia/Sydney', 'GMT+11:00'); // Australian Eastern Daylight Time (AEDT)
        ianaToGmtMap.put('Australia/Melbourne', 'GMT+11:00'); // Melbourne, Victoria
        ianaToGmtMap.put('Australia/Perth', 'GMT+08:00'); // Western Australia Standard Time (AWST)

        // Africa
        ianaToGmtMap.put('Africa/Johannesburg', 'GMT+02:00'); // South Africa Standard Time (SAST)
        ianaToGmtMap.put('Africa/Lagos', 'GMT+01:00'); // West Africa Time (WAT)
        ianaToGmtMap.put('Africa/Nairobi', 'GMT+03:00'); // East Africa Time (EAT)

        // South America
        ianaToGmtMap.put('America/Argentina/Buenos_Aires', 'GMT-03:00'); // Argentina Standard Time
        ianaToGmtMap.put('America/Sao_Paulo', 'GMT-03:00'); // Brazil (São Paulo Time)
        ianaToGmtMap.put('America/Bogota', 'GMT-05:00'); // Colombia (Colombia Time)
        ianaToGmtMap.put('America/Lima', 'GMT-05:00'); // Peru (Peru Time)
        ianaToGmtMap.put('America/Chile', 'GMT-04:00'); // Chile (Chile Time)

        // Middle East
        ianaToGmtMap.put('Asia/Tehran', 'GMT+03:30'); // Iran Standard Time (IRST)
        ianaToGmtMap.put('Asia/Jerusalem', 'GMT+02:00'); // Israel Standard Time (IST)
        ianaToGmtMap.put('Africa/Cairo', 'GMT+02:00'); // Egypt Standard Time (EET)

        // Caribbean
        ianaToGmtMap.put('America/Puerto_Rico', 'GMT-04:00'); // Puerto Rico (Atlantic Standard Time)
        ianaToGmtMap.put('America/Havana', 'GMT-05:00'); // Cuba (Cuban Standard Time)
        ianaToGmtMap.put('America/Santo_Domingo', 'GMT-04:00'); // Dominican Republic (Atlantic Standard Time)

        // Additional Global Locations
        ianaToGmtMap.put('Pacific/Auckland', 'GMT+13:00'); // New Zealand Standard Time (NZST)
        ianaToGmtMap.put('Pacific/Apia', 'GMT+13:00'); // Samoa Standard Time (SST)
        ianaToGmtMap.put('Pacific/Fiji', 'GMT+12:00'); // Fiji Standard Time (FJT)

        return ianaToGmtMap;
    }

    // Example method to get GMT using IANA time zone
    public static String getGmtFromIana() {
        String ianaTimeZone = 'Pacific/Fiji';
        Map<String, String> ianaToGmtMap = getIanaToGmtMap();
        if (ianaToGmtMap.containsKey(ianaTimeZone)) {
          
            system.debug( ianaToGmtMap.get(ianaTimeZone));
            return ianaToGmtMap.get(ianaTimeZone);
        } else {
            return null; // or handle as needed
        }
    }
}