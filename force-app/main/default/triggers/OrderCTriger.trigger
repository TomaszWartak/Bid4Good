trigger OrderTrigger on Order__c (
    after insert, after update, after delete, after undelete
) {
    switch on System.TriggerOperation {
        when AFTER_INSERT, AFTER_UPDATE, AFTER_UNDELETE {
            OrderTriggerHandler.handleAfterInsertUpdateUndelete(Trigger.new);
        }
        when AFTER_DELETE {
            OrderTriggerHandler.handleAfterDelete(Trigger.old);
        }
        when else {
            // TODO
        }
    }
}
