@isTest
private class OrderCControllerTest {
  @isTest
  static void getAccountsWithOrdersPicklistValues_shouldReturnCorrectValues() {
    TestDataFactory.createAccountsWithOrders();

    Test.startTest();
    List<OrderCController.PicklistValue> result = OrderCController.getAccountsWithOrdersPicklistValues();
    Test.stopTest();

    System.assertEquals(TestDataFactory.ACCOUNTS_NUMBER, result.size());
    System.assertEquals(TestDataFactory.createAccountName(1), result[0].label);
    System.assertEquals(TestDataFactory.createAccountName(2), result[1].label);
  }

  @isTest
  static void createMonthPicklistValues_shouldReturnCorrectValues() {
    List<Order__c> testOrders = new List<Order__c>{
      new Order__c(Payment_Due_Date__c = Date.newInstance(2023, 1, 15)),
      new Order__c(Payment_Due_Date__c = Date.newInstance(2023, 2, 15)),
      new Order__c(Payment_Due_Date__c = Date.newInstance(2023, 1, 20))
    };

    List<OrderCController.PicklistValue> result = OrderCController.createMonthPicklistValues(
      testOrders
    );

    System.assertEquals(2, result.size());
    System.assertEquals('January', result[0].label);
    System.assertEquals('1', result[0].value);
    System.assertEquals('February', result[1].label);
    System.assertEquals('2', result[1].value);
  }

  @isTest
  static void getPaymentDueDateMonthsPicklistValues_shouldReturn5Months() {
    List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();
    Integer accountNr = 0; 

    Test.startTest();
      List<OrderCController.PicklistValue> results = 
        OrderCController.getPaymentDueDateMonthsForAccountPicklistValues( testAccounts[accountNr].Id );
    Test.stopTest();

    System.assertEquals(5, results.size(), 'Should return 5 unique month');
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldReturnCorrectValues_for2And9() {
    List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();

    Integer accountNr = 2; 
    Integer monthNr = 9;

    Test.startTest();
    List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
      testAccounts[accountNr].Id,
      monthNr
    );
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Should return 1 order for September'
    );

    System.assertEquals(
      monthNr, 
      results[0].Payment_Due_Date__c.month()
    );
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldReturnCorrectValues_for1And1() {
    List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();

    Integer accountNr = 1; 
    Integer monthNr = 1;

    Test.startTest();
      List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
        testAccounts[accountNr].Id,
        monthNr
      );
    Test.stopTest();

    System.assertEquals(
      2,
      results.size(),
      'Should return 2 orders for January'
    );

    System.assertEquals(
      monthNr, 
      results[0].Payment_Due_Date__c.month()
    );

    System.assertEquals(
      monthNr, 
      results[1].Payment_Due_Date__c.month()
    );
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldReturnEmptyList_forMonthWithoutDueDate() {
    List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();

    Test.startTest();
    List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
      testAccounts[2].Id,
      3
    );
    Test.stopTest();

    System.assertEquals(0, results.size(), 'Should return 0 orders for March');
  }
}
