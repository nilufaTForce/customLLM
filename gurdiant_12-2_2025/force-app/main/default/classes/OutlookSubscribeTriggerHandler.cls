public with sharing class OutlookSubscribeTriggerHandler {
    interface HandleTrigger{
        void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS);
    }

    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };
    public static Boolean systemUpdate = false;
    public static void execute(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldOS, newOS);
        }
    }

    class BeforeInsert implements HandleTrigger{
        public void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
            //
            System.debug('BeforeInsert');
        }

    }

    class AfterInsert implements HandleTrigger{
        public void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
            //proma

            System.debug('AfterInsert');
        }

    }

    class BeforeUpdate implements HandleTrigger{
        public void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
            //
            System.debug('BeforeUpdate');
        }


    }

    class AfterUpdate implements HandleTrigger{
        public void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
            System.debug('AfterUpdate');
        }

    }

    class BeforeDelete implements HandleTrigger{
        public void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
            //
            System.debug('BeforeDelete');
          
        }

    }

    class AfterDelete implements HandleTrigger{
        public void handle(Outlook_Subscribe__c[] oldOS, Outlook_Subscribe__c[] newOS){
            //
            System.debug('AfterDelete');
            /*for (Outlook_Subscribe__c os : oldOS) {
                // Enqueue the Queueable job for asynchronous processing
                // System.enqueueJob(new DeleteOutlookSubscribeJob(os.Id));
                System.debug('AfterDelete');
                System.enqueueJob(new DeleteOutlookSubscribeJob(os));
            }
          */
        }

    } 
}