@isTest
private class OrderCControllerTest {
  @isTest
  static void getAccountsWithOrdersPicklistValues_shouldReturnCorrectValues() {
    TestDataFactory.createAccountsWithOrders();

    Test.startTest();
    List<OrderCController.PicklistValue> result = OrderCController.getAccountsWithOrdersPicklistValues();
    Test.stopTest();

    System.assertEquals(TestDataFactory.accountsNr, result.size());
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
  static void getPaymentDueDateMonthsPicklistValues_shouldReturnCorrectValues() {
    TestDataFactory.createAccountsWithOrders();

    Test.startTest();
    List<OrderCController.PicklistValue> results = OrderCController.getPaymentDueDateMonthsPicklistValues();
    Test.stopTest();

    System.assertEquals(
      TestDataFactory.fixedMonths.size(),
      results.size(),
      'Should return ' + TestDataFactory.fixedMonths.size() + ' unique months'
    );

    System.assertEquals(
      DateUtils.getMonthName(TestDataFactory.fixedMonths[0]),
      results[0].label
    );
    System.assertEquals(
      TestDataFactory.fixedMonths[0].toString(),
      results[0].value
    );

    System.assertEquals(
      DateUtils.getMonthName(TestDataFactory.fixedMonths[1]),
      results[1].label
    );
    System.assertEquals(
      TestDataFactory.fixedMonths[1].toString(),
      results[1].value
    );

    System.assertEquals(
      DateUtils.getMonthName(TestDataFactory.fixedMonths[4]),
      results[4].label
    );
    System.assertEquals(
      TestDataFactory.fixedMonths[4].toString(),
      results[4].value
    );
  }
}
