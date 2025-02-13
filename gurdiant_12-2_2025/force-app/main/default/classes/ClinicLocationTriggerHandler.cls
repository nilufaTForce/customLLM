public with sharing class ClinicLocationTriggerHandler{
    interface HandleTrigger{
        void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL);
    }

    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };
    public static Boolean systemUpdate = false;
    public static void execute(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldCL, newCL);
        }
    }

    class BeforeInsert implements HandleTrigger{
        public void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
            //
            System.debug('BeforeInsert');
        }

    }

    class AfterInsert implements HandleTrigger{
        public void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
            //proma

            System.debug('AfterInsert');
        }

    }

    class BeforeUpdate implements HandleTrigger{
        public void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
            //
            System.debug('BeforeUpdate');
        }

    }

    class AfterUpdate implements HandleTrigger{
        public void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
            System.debug('AfterUpdate');
        }

    }

    class BeforeDelete implements HandleTrigger{
        public void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
            //
            System.debug('BeforeDelete');
        }

    }

    class AfterDelete implements HandleTrigger{
        public void handle(Clinic_Location__c[] oldCL, Clinic_Location__c[] newCL){
            //
            System.debug('AfterDelete');
        }

    }

}