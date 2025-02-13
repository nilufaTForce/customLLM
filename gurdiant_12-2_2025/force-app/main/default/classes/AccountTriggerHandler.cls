public without sharing class AccountTriggerHandler{
    //Part A: An Interface
    interface HandleTrigger{
        void handle(Account[] oldAccs, Account[] newAccs);
    }

    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };
    public static Boolean systemUpdate = false;
    public static void execute(Account[] oldAccs, Account[] newAccs){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldAccs, newAccs);
        }
    }

    class BeforeInsert implements HandleTrigger{
        public void handle(Account[] oldAccs, Account[] newAccs){
            //
            System.debug('BeforeInsert');
            Id providerID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider_Doctor').getRecordTypeId();
            if (newAccs[0].RecordTypeId == providerID){
                ProviderDoctorHandler.duplicateEmail(newAccs[0]);
            }
        }

    }

    class AfterInsert implements HandleTrigger{
        public void handle(Account[] oldAccs, Account[] newAccs){
            System.debug('AfterInsert');

            Id providerID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider_Doctor').getRecordTypeId();
            if (newAccs[0].RecordTypeId == providerID){
                // OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'araf.tforce@gmail.com' LIMIT 1];
                OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
                ProviderDoctorHandler.sendEmailProviderDoctor(newAccs[0].Email__c, newAccs[0].Name, owea.Id);
            }
        }

    }

    class BeforeUpdate implements HandleTrigger{
        public void handle(Account[] oldAccs, Account[] newAccs){
            //
            System.debug('BeforeUpdate');
        }

    }

    class AfterUpdate implements HandleTrigger{
        public void handle(Account[] oldAccs, Account[] newAccs){
            System.debug('AfterUpdate');
            Id providerID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Provider_Doctor').getRecordTypeId();
            if (newAccs[0].RecordTypeId == providerID){
                OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
                ProviderDoctorHandler.sendEmailProviderDoctor(newAccs[0].Email__c, newAccs[0].Name, owea.Id);
            }
        }

    }

    class BeforeDelete implements HandleTrigger{
        public void handle(Account[] oldAccs, Account[] newAccs){
            //
            System.debug('BeforeDelete');
        }

    }

    class AfterDelete implements HandleTrigger{
        public void handle(Account[] oldAccs, Account[] newAccs){
            //
            System.debug('AfterDelete');
        }

    }

}