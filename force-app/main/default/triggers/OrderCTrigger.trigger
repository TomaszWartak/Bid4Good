trigger OrderCTrigger on Order__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  switch on Trigger.operationType {
    when AFTER_INSERT {
      OrderCTriggerHandler.handleAfterInsert(Trigger.new);
    }
    when AFTER_UPDATE {
      // Nothing to do - count of orders is not affected by updates (no "reparenting")
    }
    when AFTER_DELETE {
      OrderCTriggerHandler.handleAfterDelete(Trigger.old);
    }
    when AFTER_UNDELETE {
      OrderCTriggerHandler.handleAfterUndelete(Trigger.new);
    }
  }
}
