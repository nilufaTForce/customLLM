@isTest
public class GuardiantUtilityTest {

    @isTest
    static void testGetTimeZonesMap() {
        // Arrange: call the method to get the map
        Map<String, Decimal> timezonesMap = GuardiantUtility.getTimeZonesMap();
        
      
    }

    @isTest
    static void testFormatTime() {
       
        Time testTime = Time.newInstance(8, 5, 0, 0);
        
        
        String formattedTime = GuardiantUtility.formatTime(testTime);
        
      
        System.assertEquals(formattedTime, '8:05 AM', 'The formatted time should be 8:05 AM');
        
       
        testTime = Time.newInstance(14, 30, 0, 0);
        
     
        formattedTime = GuardiantUtility.formatTime(testTime);
        
      
    }

    @isTest
    static void testFormatDate() {
       
        Date testDate = Date.newInstance(2024, 12, 28);
        
       
        String formattedDate = GuardiantUtility.formatDate(testDate);
        
       
        System.assertEquals(formattedDate, '28th-Dec-2024', 'The formatted date should be 28th-Dec-2024');
    }

    @isTest
    static void testGetDayWithSuffix() {
       
        Integer day1 = 1;
        Integer day2 = 2;
        Integer day3 = 3;
        Integer day4 = 11;
        Integer day5 = 12;
        Integer day6 = 13;
        Integer day7 = 21;
        
        
    }

    @isTest
    static void testGetMonthShortName() {
      
        Integer month1 = 1;
        Integer month2 = 5;
        Integer month3 = 7;
        Integer month4 = 12;
        
       
    }

}