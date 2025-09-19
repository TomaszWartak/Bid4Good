@isTest
private class OrderCControllerTest {
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
  static void getAccountsWithOrdersPicklistValues_shouldReturnCorrectValues() {
    TestDataFactory.createAccountsWithOrders();

    Test.startTest();
    List<OrderCController.PicklistValue> result = OrderCController.getAccountsWithOrdersPicklistValues();
    Test.stopTest();

    System.assertEquals(TestDataFactory.accountsNr, result.size());
    System.assertEquals('Test Account 1', result[0].label);
    System.assertEquals('Test Account 1 Id', result[0].value);
    System.assertEquals('Test Account 2', result[1].label);
    System.assertEquals('Test Account 2 Id', result[1].value);
  }
}
