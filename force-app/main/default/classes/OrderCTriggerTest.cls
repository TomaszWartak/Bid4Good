@isTest
private class OrderCTriggerTest {
  @isTest
  static void afterInsert() {
    Test.startTest();
    TestDataFactory.createAccountsWithOrders();
    List<Account> newAccounts = TestDataFactory.getAccountsWithOrders();
    Test.stopTest();

    System.assertEquals(
      TestDataFactory.ACCOUNTS_NUMBER,
      newAccounts.size(),
      'Should create ' + TestDataFactory.ACCOUNTS_NUMBER + ' accounts'
    );

    for (Integer i = 0; i < newAccounts.size(); i++) {
      Account acc = newAccounts[i];
      Integer expectedOrdersCount = TestDataFactory.ordersPerAccount[i];
      System.assertEquals(
        expectedOrdersCount,
        acc.Total_Orders_Number__c,
        'Account ' +
          acc.Name +
          ' should have ' +
          expectedOrdersCount +
          ' orders'
      );
    }
  }

  @isTest
  static void afterDelete() {
    Test.startTest();
    TestDataFactory.createAccountsWithOrders();
    List<Account> accounts = TestDataFactory.getAccountsWithOrders();
    List<Order__c> ordersToDelete = [
      SELECT Id
      FROM Order__c
      WHERE Account__c IN :accounts
    ];
    delete ordersToDelete;
    Test.stopTest();

    accounts = [
      SELECT Name, Total_Orders_Number__c
      FROM Account
      WHERE Id IN :accounts
    ];

    for (Integer i = 0; i < accounts.size(); i++) {
      Account acc = accounts[i];
      System.assertEquals(
        0,
        acc.Total_Orders_Number__c,
        'Account ' + acc.Name + ' should have 0 orders'
      );
    }
  }

  @isTest
  static void afterUndelete() {
    Test.startTest();
    TestDataFactory.createAccountsWithOrders();
    List<Account> accounts = TestDataFactory.getAccountsWithOrders();
    List<Order__c> ordersToDelete = [
      SELECT Id
      FROM Order__c
      WHERE Account__c IN :accounts
    ];
    delete ordersToDelete;
    undelete ordersToDelete;
    Test.stopTest();

    accounts = [
      SELECT Name, Total_Orders_Number__c
      FROM Account
      WHERE Id IN :accounts
    ];
    for (Integer i = 0; i < accounts.size(); i++) {
      Account acc = accounts[i];
      Integer expectedOrdersCount = TestDataFactory.ordersPerAccount[i];
      System.assertEquals(
        expectedOrdersCount,
        acc.Total_Orders_Number__c,
        'Account ' +
          acc.Name +
          ' should have ' +
          expectedOrdersCount +
          ' orders'
      );
    }
  }
}
