@isTest
private class OrderCTriggerTest {
  @isTest
  static void afterInsert() {
    Test.startTest();
    List<Account> newAccounts = TestDataFactory.createAccountsWithOrders();
    Test.stopTest();
    System.assertEquals(
      TestDataFactory.accountsNr,
      newAccounts.size(),
      'Should create ' + TestDataFactory.accountsNr + ' accounts'
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
}
