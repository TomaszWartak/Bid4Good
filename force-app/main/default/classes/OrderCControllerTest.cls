@isTest
private class OrderCControllerTest {
  @TestSetup
  static void makeData() {
    TestDataFactory.createUsers();
  }

  @isTest
  static void getAccountsWithOrdersPicklistValues_shouldReturnCorrectValues() {
    TestDataFactory.createAccountsWithOrders();

    User userWithPermissions = TestDataFactory.getUserWithPermissions();

    System.runAs(userWithPermissions) {
      Test.startTest();
      List<OrderCController.PicklistValue> result = OrderCController.getAccountsWithOrdersPicklistValues();
      Test.stopTest();

      System.assertEquals(TestDataFactory.ACCOUNTS_NUMBER, result.size());
      System.assertEquals(
        TestDataFactory.createAccountName(1),
        result[0].label
      );
      System.assertEquals(
        TestDataFactory.createAccountName(2),
        result[1].label
      );
    }
  }

  @isTest
  static void getAccountsWithOrdersPicklistValues_shouldThrowAuraHandledException_whenUserHasntPermissions() {
    User userWithoutPermissions = TestDataFactory.getUserWithoutPermissions();

    System.runAs(userWithoutPermissions) {
      Boolean exceptionCaught = false;

      Test.startTest();
      try {
        OrderCController.getAccountsWithOrdersPicklistValues();
      } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage());
        exceptionCaught = true;
      } catch (Exception e) {
        System.assert(false, e.getTypeName());
      }
      Test.stopTest();

      System.assert(exceptionCaught, 'No AuraHandledException thrown');
    }
  }

  @isTest
  static void getAccountsWithOrdersPicklistValues_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
    TestDataFactory.createAccountsWithOrders();

    User userWithPermissions = TestDataFactory.getUserWithPermissions();

    System.runAs(userWithPermissions) {
      Boolean exceptionNotCaught = true;

      Test.startTest();
      try {
        OrderCController.getAccountsWithOrdersPicklistValues();
      } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage());
        exceptionNotCaught = false;
      } catch (Exception e) {
        System.assert(false, e.getTypeName());
      }
      Test.stopTest();

      System.assert(exceptionNotCaught, 'No AuraHandledException thrown');
    }
  }

  @isTest
  static void getPaymentDueDateMonthsForAccountPicklistValues_shouldThrowAuraHandledException_whenUserHasntPermissions() {
    User userWithoutPermissions = TestDataFactory.getUserWithoutPermissions();

    final Id DUMMY_ACCOUNT_ID = getDummyAccountId();

    System.runAs(userWithoutPermissions) {
      Boolean exceptionCaught = false;

      Test.startTest();
      try {
        OrderCController.getPaymentDueDateMonthsForAccountPicklistValues(
          DUMMY_ACCOUNT_ID
        );
      } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage());
        exceptionCaught = true;
      } catch (Exception e) {
        System.assert(false, e.getTypeName());
      }
      Test.stopTest();

      System.assert(exceptionCaught, 'No AuraHandledException thrown');
    }
  }

  @isTest
  static void getPaymentDueDateMonthsForAccountPicklistValues_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
    TestDataFactory.createAccountsWithOrders();

    User userWithPermissions = TestDataFactory.getUserWithPermissions();

    final Id DUMMY_ACCOUNT_ID = getDummyAccountId();

    System.runAs(userWithPermissions) {
      Boolean exceptionNotCaught = true;

      Test.startTest();
      try {
        OrderCController.getPaymentDueDateMonthsForAccountPicklistValues(
          DUMMY_ACCOUNT_ID
        );
      } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage());
        exceptionNotCaught = false;
      } catch (Exception e) {
        System.assert(false, e.getTypeName());
      }
      Test.stopTest();

      System.assert(exceptionNotCaught, 'No AuraHandledException thrown');
    }
  }

  private static Id getDummyAccountId() {
    return '001000000000000AAA';
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
    System.assertEquals('2023-01', result[0].label);
    System.assertEquals('2023-01', result[0].value);
    System.assertEquals('2023-02', result[1].label);
    System.assertEquals('2023-02', result[1].value);
  }

  @isTest
  static void getPaymentDueDateMonthsForAccountPicklistValues_shouldReturn5Months() {
    TestDataFactory.createAccountsWithOrders();

    List<Account> testAccounts = TestDataFactory.getAccountsWithOrders();
    final Integer ACCOUNT_NR = 2;

    Test.startTest();
    List<OrderCController.PicklistValue> results = OrderCController.getPaymentDueDateMonthsForAccountPicklistValues(
      testAccounts[ACCOUNT_NR].Id
    );
    Test.stopTest();

    System.assertEquals(5, results.size(), 'Should return 5 unique month');
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldReturnCorrectValues_for2And9() {
    TestDataFactory.createAccountsWithOrders();

    List<Account> testAccounts = TestDataFactory.getAccountsWithOrders();

    final Integer ACCOUNT_NR = 2;
    final String YEAR_MONTH = DateUtils.getYearMonthString(2025, 9);

    Test.startTest();
    List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
      testAccounts[ACCOUNT_NR].Id,
      YEAR_MONTH
    );
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Should return 1 order for September'
    );

    System.assertEquals(
      YEAR_MONTH,
      DateUtils.getYearMonthString(results[0].Payment_Due_Date__c)
    );
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldReturnCorrectValues_for1And1() {
    TestDataFactory.createAccountsWithOrders();

    List<Account> testAccounts = TestDataFactory.getAccountsWithOrders();

    final Integer ACCOUNT_NR = 1;
    final String YEAR_MONTH = DateUtils.getYearMonthString(2025, 1);

    Test.startTest();
    List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
      testAccounts[ACCOUNT_NR].Id,
      YEAR_MONTH
    );
    Test.stopTest();

    System.assertEquals(
      2,
      results.size(),
      'Should return 2 orders for January'
    );

    System.assertEquals(
      YEAR_MONTH,
      DateUtils.getYearMonthString(results[0].Payment_Due_Date__c)
    );

    System.assertEquals(
      YEAR_MONTH,
      DateUtils.getYearMonthString(results[1].Payment_Due_Date__c)
    );
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldReturnEmptyList_forMonthWithoutDueDate() {
    TestDataFactory.createAccountsWithOrders();

    List<Account> testAccounts = TestDataFactory.getAccountsWithOrders();

    final String YEAR_MONTH = DateUtils.getYearMonthString(2025, 3);

    Test.startTest();
    List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
      testAccounts[2].Id,
      YEAR_MONTH
    );
    Test.stopTest();

    System.assertEquals(0, results.size(), 'Should return 0 orders for March');
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldThrowAuraHandledException_whenUserHasntPermissions() {
    User testUserWithoutPermissions = TestDataFactory.getUserWithoutPermissions();

    final Id DUMMY_ACCOUNT_ID = getDummyAccountId();
    final String DUMMY_YEAR_MONTH = DateUtils.getYearMonthString(2025, 0);

    System.runAs(testUserWithoutPermissions) {
      Boolean exceptionCaught = false;

      Test.startTest();
      try {
        OrderCController.getOrdersForAccountAndDueDateMonth(
          DUMMY_ACCOUNT_ID,
          DUMMY_YEAR_MONTH
        );
      } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage());
        exceptionCaught = true;
      } catch (Exception e) {
        System.assert(false, e.getTypeName());
      }
      Test.stopTest();

      System.assert(exceptionCaught, 'No AuraHandledException thrown');
    }
  }

  @isTest
  static void getOrdersForAccountAndDueDateMonth_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
    TestDataFactory.createAccountsWithOrders();

    User userWithPermissions = TestDataFactory.getUserWithPermissions();

    final Id DUMMY_ACCOUNT_ID = getDummyAccountId();
    final String DUMMY_YEAR_MONTH = DateUtils.getYearMonthString(2025, 0);

    System.runAs(userWithPermissions) {
      Boolean exceptionNotCaught = true;

      Test.startTest();
      try {
        OrderCController.getOrdersForAccountAndDueDateMonth(
          DUMMY_ACCOUNT_ID,
          DUMMY_YEAR_MONTH
        );
      } catch (AuraHandledException e) {
        System.assertEquals('Script-thrown exception', e.getMessage());
        exceptionNotCaught = false;
      } catch (Exception e) {
        System.assert(false, e.getTypeName());
      }
      Test.stopTest();

      System.assert(exceptionNotCaught, 'AuraHandledException thrown');
    }
  }
}
