public with sharing class AvailabilitiesTriggerHandler {


    interface HandleTrigger{
        void handle(Availability__c [] oldApps, Availability__c[] newApps);
    }

    //Part B: A Dispatch Table
    static Type[] vTable = new Type[]{ BeforeInsert.class, AfterInsert.class, BeforeUpdate.class, AfterUpdate.class, BeforeDelete.class, AfterDelete.class };
    public static Boolean systemUpdate = false;
    public static void execute(Availability__c[] oldApps, Availability__c[] newApps){
        if (!systemUpdate){
            ((HandleTrigger)(vTable[(Trigger.isBefore ? 0 : 1) + (Trigger.isInsert ? 0 : Trigger.isUpdate ? 2 : Trigger.isDelete ? 4 : 6)].newInstance())).handle(oldApps, newApps);
        }
    }

    class BeforeInsert implements HandleTrigger{
        public void handle(Availability__c[] oldApps, Availability__c[] newApps){
   
            List<Availability__c> duplicateAvailability = [
                SELECT Id, Start_Shift__c, End_Shift__c 
                FROM Availability__c 
                WHERE Clinic_Resource__c = :newApps[0].Clinic_Resource__c 
                  AND Day__c = :newApps[0].Day__c
            ];
            
            for (Availability__c avail : duplicateAvailability) {
                if ((newApps[0].Start_Shift__c <= avail.End_Shift__c) && 
                    (newApps[0].End_Shift__c >= avail.Start_Shift__c)) {
                    // Overlap found
                    System.debug('Time intervals overlap with Availability ID: ' + avail.Id);
                    newApps[0].addError('Dupplicate availability detected.');
                    // Handle the overlap case (e.g., break the loop, throw an error, etc.)
                }
            }
    }
}
    class AfterInsert implements HandleTrigger{
        public void handle(Availability__c[] oldApps, Availability__c[] newApps){}
    }
    class AfterUpdate implements HandleTrigger{
        public void handle(Availability__c[] oldApps, Availability__c[] newApps){}
    }
    class BeforeUpdate implements HandleTrigger{
        public void handle(Availability__c[] oldApps, Availability__c[] newApps){}
    }
    class BeforeDelete implements HandleTrigger{
        public void handle(Availability__c[] oldApps, Availability__c[] newApps){}
    }
    class AfterDelete implements HandleTrigger{
        public void handle(Availability__c[] oldApps, Availability__c[] newApps){}
    }



    // public AvailabilitiesTriggerHandler() {

    // }
}