/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountTriggerHandlerTest {

 

     
        
            // Utility method to create a RecordType if it does not exist

            
                // Utility method to get a RecordType ID by DeveloperName
                private static Id getRecordTypeId(String objectName, String developerName) {
                    RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :developerName AND SObjectType = :objectName LIMIT 1];
                    if (recordType == null) {
                        System.assert(false, 'RecordType with DeveloperName "' + developerName + '" does not exist.');
                    }
                    return recordType.Id;
                }
        
            @isTest
      
            static void testBeforeInsert() {
                Test.startTest();
                // Get the Provider_Doctor RecordType ID
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Create Account to trigger BeforeInsert logic
                Account acc = new Account(Name = 'Test Doctor', RecordTypeId = providerDoctorRTId,Email__c = 'prom@gmail.com');
                insert acc;
        
                // Assertions or verifications can be added here if needed
                System.assertNotEquals(null, acc.Id, 'Account should be inserted successfully.');
                Test.stopTest();
            }
        
            @isTest
            static void testAfterInsert() {
                Test.startTest();
                // Ensure the Provider_Doctor RecordType exists
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Create Account to trigger AfterInsert logic
                Account acc = new Account(Name = 'Test Doctor After Insert', RecordTypeId = providerDoctorRTId,Email__c = 'proma@gmail.com');
                insert acc;
        
                // Assertions or verifications can be added here if needed
                System.assertNotEquals(null, acc.Id, 'Account should be inserted successfully.');
                Test.stopTest();
            }
        
            @isTest
            static void testBeforeUpdate() {
                Test.startTest();
                // Ensure the Provider_Doctor RecordType exists
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Insert an Account to trigger BeforeUpdate logic
                Account acc = new Account(Name = 'Test Before Update', RecordTypeId = providerDoctorRTId,Email__c = 'prom@gmail.com');
                insert acc;
        
                // Update the Account
                acc.Name = 'Updated Name';
                update acc;
        
                // Assertions or verifications can be added here if needed
                Test.stopTest();
            }
        
            @isTest
            static void testAfterUpdate() {
                Test.startTest();
                // Ensure the Provider_Doctor RecordType exists
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Insert an Account to trigger AfterUpdate logic
                Account acc = new Account(Name = 'Test After Update', RecordTypeId = providerDoctorRTId,Email__c = 'prom@gmail.com');
                insert acc;
        
                // Update the Account
                acc.Name = 'Updated Name After Trigger';
                update acc;
        
                // Assertions or verifications can be added here if needed
                Test.stopTest();
            }
        
            @isTest
            static void testBeforeDelete() {
                Test.startTest();
                // Ensure the Provider_Doctor RecordType exists
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Insert an Account to trigger BeforeDelete logic
                Account acc = new Account(Name = 'Test Before Delete', RecordTypeId = providerDoctorRTId,Email__c = 'prom@gmail.com');
                insert acc;
        
                // Delete the Account
                delete acc;
        
                // Assertions or verifications can be added here if needed
                Test.stopTest();
            }
        
            @isTest
            static void testAfterDelete() {
                Test.startTest();
                // Ensure the Provider_Doctor RecordType exists
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Insert an Account to trigger AfterDelete logic
                Account acc = new Account(Name = 'Test After Delete', RecordTypeId = providerDoctorRTId,Email__c = 'pro@gmail.com');
                insert acc;
        
                // Delete the Account
                delete acc;
        
                // Assertions or verifications can be added here if needed
                Test.stopTest();
            }
        
            @isTest
            static void testSystemUpdate() {
                Test.startTest();
                AccountTriggerHandler.systemUpdate = true;
        
                // Ensure the Provider_Doctor RecordType exists
                Id providerDoctorRTId = getRecordTypeId('Account', 'Provider_Doctor');
        
                // Create Account while systemUpdate is true
                Account acc = new Account(Name = 'Test System Update', RecordTypeId = providerDoctorRTId,Email__c = 'prom@gmail.com');
                insert acc;
        
                // Ensure trigger logic does not run
                System.assertNotEquals(null, acc.Id, 'Account should be inserted even with systemUpdate true.');
                AccountTriggerHandler.systemUpdate = false;
                Test.stopTest();
            }



    
}