trigger OrderCTrigger on Order__c (
    after insert, after update, after delete, after undelete
) {
    switch on Trigger.operationType {
        when AFTER_INSERT, AFTER_UNDELETE {
            OrderCTriggerHandler.handleAfterInsertUndelete(Trigger.new);
        }
        when AFTER_UPDATE {
            // Nothing to do - count of orders is not affected by updates (no "reparenting")
        } 
        when AFTER_DELETE {
            OrderCTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}
