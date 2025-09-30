public with sharing class OrderCTriggerHandler {
  public static void handleAfterInsert(List<Order__c> newOrders) {
    ActualizeAccounts(newOrders, System.TriggerOperation.AFTER_INSERT);
  }

  public static void handleAfterUndelete(List<Order__c> newOrders) {
    ActualizeAccounts(newOrders, System.TriggerOperation.AFTER_UNDELETE);
  }

  public static void handleAfterDelete(List<Order__c> oldOrders) {
    ActualizeAccounts(oldOrders, System.TriggerOperation.AFTER_DELETE);
  }

  private static void ActualizeAccounts(
    List<Order__c> orders,
    System.TriggerOperation operationType
  ) {

    // ONLY THROW EXCEPTION
    // HOW TO MAKE VALIDATION IN TRIGGER (EXCEPTIONS OR TRIGGER's METHODS)

    // zrób mapę <idAccount, ilość zamówień dla idAccount> z newOrders
    Map<Id, Integer> newOrderCountsForAccounts = getNewOrderCountsForAccounts(
      orders
    );
    // zbierz id kont z newOrderCountsForAccounts
    Set<Id> accountIds = newOrderCountsForAccounts.keySet();
    // pobierz konta z bazy
    List<Account> accountsToUpdate = [
      SELECT Id, Total_Orders_Number__c
      FROM Account
      WHERE Id IN :accountIds
      FOR UPDATE
    ];
    // zaktualizuj liczniki zamówień na kontach
    accountsToUpdate = getActualizedAccounts(
      accountsToUpdate,
      newOrderCountsForAccounts,
      operationType
    );
    // zapisz konta
    if (!accountsToUpdate.isEmpty()) {
      update accountsToUpdate;
    }
  }

  private static Map<Id, Integer> getNewOrderCountsForAccounts(
    List<Order__c> orders
  ) {
    Map<Id, Integer> orderCountsForAccounts = new Map<Id, Integer>();
    for (Order__c ord : orders) {
      if (!orderCountsForAccounts.containsKey(ord.Account__c)) {
        orderCountsForAccounts.put(ord.Account__c, 1);
      } else {
        orderCountsForAccounts.put(
          ord.Account__c,
          orderCountsForAccounts.get(ord.Account__c) + 1
        );
      }
    }
    return orderCountsForAccounts;
  }

  private static List<Account> getActualizedAccounts(
    List<Account> accountsToUpdate,
    Map<Id, Integer> newOrderCountsForAccounts,
    System.TriggerOperation operationType
  ) {
    Integer existingOrderCount = 0;
    Integer newOrdersForThisAccount = 0;
    for (Account acc : accountsToUpdate) {
      existingOrderCount = acc.Total_Orders_Number__c != null
        ? acc.Total_Orders_Number__c.intValue()
        : 0;
      newOrdersForThisAccount = newOrderCountsForAccounts.get(acc.Id);
      if (isInsertOrUndeleteOperation(operationType)) {
        acc.Total_Orders_Number__c =
          existingOrderCount + newOrdersForThisAccount;
      } else if (
        isDeleteOperation(operationType) &&
        (existingOrderCount >= newOrdersForThisAccount)
      ) {
        acc.Total_Orders_Number__c =
          existingOrderCount - newOrdersForThisAccount;
      }
    }
    return accountsToUpdate;
  }

  private static Boolean isInsertOrUndeleteOperation(
    System.TriggerOperation operationType
  ) {
    return (operationType == System.TriggerOperation.AFTER_INSERT ||
    operationType == System.TriggerOperation.AFTER_UNDELETE);
  }

  private static Boolean isDeleteOperation(
    System.TriggerOperation operationType
  ) {
    return (operationType == System.TriggerOperation.AFTER_DELETE);
  }
}
