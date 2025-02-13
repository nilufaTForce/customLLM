public class ClinicResourceTriggerHandler{


    interface HandleTrigger{
        void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs);
    }

    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };

    
    public static Boolean systemUpdate = false;
    public static void execute(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldCRs, newCRs);
        }
    }

    class BeforeInsert implements HandleTrigger{
        public void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){

            
        }

    }


    class AfterInsert implements HandleTrigger{
        public void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){
            if (oldCRs[0].Email__c != newCRs[0].Email__c) {
                OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'will@solve4u.io' LIMIT 1];
                Clinic_Resource__c cr = newCRs[0];
                ProviderDoctorHandler.sendEmailProviderDoctor(cr.Email__c, cr.Name, owea.Id);
            }
        }

    }

    class AfterUpdate implements HandleTrigger{
        public void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){
        }

    }

    class BeforeUpdate implements HandleTrigger{
        public void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){
        }

    }

    class BeforeDelete implements HandleTrigger{
        public void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){
        }

    }

    class AfterDelete implements HandleTrigger{
        public void handle(Clinic_Resource__c[] oldCRs, Clinic_Resource__c[] newCRs){
        }

    }

}