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
    static void getAccountsWithOrdersPicklistValues_shouldThrowAuraHandledException_whenUserHasntPermissions() {
        User testUser = prepareUserWithoutPermissions();
        insert testUser;
        
        System.runAs(testUser) {
            Boolean exceptionCaught = false;
            
            Test.startTest();
                try {
                    OrderCController.getAccountsWithOrdersPicklistValues();
                } catch (AuraHandledException e) {
                    System.assertEquals( 'Script-thrown exception', e.getMessage() );
                    exceptionCaught = true;
                } catch (Exception e) {
                    System.assert( false, e.getTypeName() );
                }
            Test.stopTest();
            
            System.assert( exceptionCaught, 'No AuraHandledException thrown');
        }
    }


    private static User prepareUserWithoutPermissions() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return new User(
            Alias = 'testuser', 
            ProfileId = standardUserProfile.Id, 
            Email = 'testuser@example.com' + System.currentTimeMillis(), 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Test', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com' 
        );
    }

    @isTest 
    static void getAccountsWithOrdersPicklistValues_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
        User userWithPermissions = getUserWithPermissions();
        
        System.runAs(userWithPermissions) {
            Boolean exceptionNotCaught = true;
            
            Test.startTest();
                try {
                    OrderCController.getAccountsWithOrdersPicklistValues();
                } catch (AuraHandledException e) {
                    System.assertEquals( 'Script-thrown exception', e.getMessage() );
                    exceptionNotCaught = false;
                } catch (Exception e) {
                    System.assert( false, e.getTypeName() );
                }
            Test.stopTest();
            
            System.assert( exceptionNotCaught, 'No AuraHandledException thrown');
        }
    }

    private static User getUserWithPermissions() {
        return [SELECT Id FROM User WHERE Alias = 'jplac' LIMIT 1];
    }

    @isTest
    static void getPaymentDueDateMonthsForAccountPicklistValues_shouldThrowAuraHandledException_whenUserHasntPermissions() {
        User testUser = prepareUserWithoutPermissions();
        insert testUser;
        
        final Id DUMMY_ACCOUNT_ID = getDummyAccountId();

        System.runAs(testUser) {
            Boolean exceptionCaught = false;
            
            Test.startTest();
                try {
                    OrderCController.getPaymentDueDateMonthsForAccountPicklistValues(
                        DUMMY_ACCOUNT_ID
                    );
                } catch (AuraHandledException e) {
                    System.assertEquals( 'Script-thrown exception', e.getMessage() );
                    exceptionCaught = true;
                } catch (Exception e) {
                    System.assert( false, e.getTypeName() );
                }
            Test.stopTest();
            
            System.assert( exceptionCaught, 'No AuraHandledException thrown');
        }
    }

    @isTest 
    static void getPaymentDueDateMonthsForAccountPicklistValues_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
        User userWithPermissions = getUserWithPermissions();
        
        final Id DUMMY_ACCOUNT_ID = getDummyAccountId();

        System.runAs(userWithPermissions) {
            Boolean exceptionNotCaught = true;
            
            Test.startTest();
                try {
                    OrderCController.getPaymentDueDateMonthsForAccountPicklistValues(
                        DUMMY_ACCOUNT_ID
                    );
                } catch (AuraHandledException e) {
                    System.assertEquals( 'Script-thrown exception', e.getMessage() );
                    exceptionNotCaught = false;
                } catch (Exception e) {
                    System.assert( false, e.getTypeName() );
                }
            Test.stopTest();
            
            System.assert( exceptionNotCaught, 'No AuraHandledException thrown');
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
        System.assertEquals('January', result[0].label);
        System.assertEquals('1', result[0].value);
        System.assertEquals('February', result[1].label);
        System.assertEquals('2', result[1].value);
    }

    @isTest
    static void getPaymentDueDateMonthsForAccountPicklistValues_shouldReturn5Months() {
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

    @isTest
    static void getOrdersForAccountAndDueDateMonth_shouldThrowAuraHandledException_whenUserHasntPermissions() {
        User testUserWithoutPermissions = prepareUserWithoutPermissions();
        insert testUserWithoutPermissions;
        
        final Id DUMMY_ACCOUNT_ID = '001000000000000AAA'; 
        final Integer DUMMY_MONTH_NR = 0;

        System.runAs(testUserWithoutPermissions) {
            Boolean exceptionCaught = false;
            
            Test.startTest();
                try {
                    OrderCController.getOrdersForAccountAndDueDateMonth(
                        DUMMY_ACCOUNT_ID,
                        DUMMY_MONTH_NR
                    );
                } catch (AuraHandledException e) {
                    System.assertEquals( 'Script-thrown exception', e.getMessage() );
                    exceptionCaught = true;
                } catch (Exception e) {
                    System.assert( false, e.getTypeName() );
                }
            Test.stopTest();
            
            System.assert( exceptionCaught, 'No AuraHandledException thrown');
        }
    }

    
    @isTest
    static void getOrdersForAccountAndDueDateMonth_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
        User userWithPermissions = getUserWithPermissions();
        
        final Id DUMMY_ACCOUNT_ID = getDummyAccountId();
        final Integer DUMMY_MONTH_NR = 0;

        System.runAs(userWithPermissions) {
            Boolean exceptionNotCaught = true;
            
            Test.startTest();
                try {
                    OrderCController.getOrdersForAccountAndDueDateMonth(
                        DUMMY_ACCOUNT_ID,
                        DUMMY_MONTH_NR
                    );                
                } catch (AuraHandledException e) {
                    System.assertEquals( 'Script-thrown exception', e.getMessage() );
                    exceptionNotCaught = false;
                } catch (Exception e) {
                    System.assert( false, e.getTypeName() );
                }
            Test.stopTest();
            
            System.assert( exceptionNotCaught, 'No AuraHandledException thrown');
        }
    }
}