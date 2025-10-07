@isTest
private class OrderCControllerTest {
    @isTest
    static void getAccountsWithOrdersPicklistValues_shouldReturnCorrectValues() {
        TestDataFactory.createAccountsWithOrders();

        Test.startTest();
            List<OrderCController.PicklistValue> result = 
                OrderCController.getAccountsWithOrdersPicklistValues();
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
            // Alias = 'testuser', 
            ProfileId = standardUserProfile.Id, 
            Email = 'testuser' + System.currentTimeMillis() + '@example.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Test', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'testu'
        );
    }
    
    @isTest 
    static void getAccountsWithOrdersPicklistValues_shouldNotThrowAuraHandledException_whenUserHasPermissions() {
        User userWithPermissions = prepareUserWithPermissions();
        
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

    private static User prepareUserWithPermissions() {
       
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            ProfileId = standardUserProfile.Id,
            Email = 'testuser' + System.currentTimeMillis() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'testu'
        );

        insert u; 

        PermissionSetGroup psg = [
            SELECT Id 
            FROM PermissionSetGroup 
            WHERE DeveloperName = 'Order_Operators' 
            LIMIT 1
        ];

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetGroupId = psg.Id 
        );

        insert psa;
        
        return u;
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
        User userWithPermissions = prepareUserWithPermissions();
        
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
        final Integer ACCOUNT_NR = 2; 

        Test.startTest();
            List<OrderCController.PicklistValue> results = 
                OrderCController.getPaymentDueDateMonthsForAccountPicklistValues( testAccounts[ACCOUNT_NR].Id );
        Test.stopTest();

        System.assertEquals(5, results.size(), 'Should return 5 unique month');
    }

    @isTest
    static void getOrdersForAccountAndDueDateMonth_shouldReturnCorrectValues_for2And9() {
        List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();

        final Integer ACCOUNT_NR = 2; 
        final String MONTH_NR = '9';

        Test.startTest();
            List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
                testAccounts[ACCOUNT_NR].Id,
                MONTH_NR
            );
        Test.stopTest();

        System.assertEquals(
            1,
            results.size(),
            'Should return 1 order for September'
        );

        System.assertEquals(
            Integer.valueOf(MONTH_NR), 
            results[0].Payment_Due_Date__c.month()
        );
    }

    @isTest
    static void getOrdersForAccountAndDueDateMonth_shouldReturnCorrectValues_for1And1() {
        List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();

        final Integer ACCOUNT_NR = 1; 
        final String MONTH_NR = '1';

        Test.startTest();
        List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
            testAccounts[ACCOUNT_NR].Id,
            MONTH_NR
        );
        Test.stopTest();

        System.assertEquals(
            2,
            results.size(),
            'Should return 2 orders for January'
        );

        System.assertEquals(
            Integer.valueOf(MONTH_NR), 
            results[0].Payment_Due_Date__c.month()
        );

        System.assertEquals(
            Integer.valueOf(MONTH_NR), 
            results[1].Payment_Due_Date__c.month()
        );
    }

    @isTest
    static void getOrdersForAccountAndDueDateMonth_shouldReturnEmptyList_forMonthWithoutDueDate() {
        List<Account> testAccounts = TestDataFactory.createAccountsWithOrders();

        final String MONTH_NR = '3';

        Test.startTest();
        List<Order__c> results = OrderCController.getOrdersForAccountAndDueDateMonth(
            testAccounts[2].Id,
            MONTH_NR
        );
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return 0 orders for March');
    }

    @isTest
    static void getOrdersForAccountAndDueDateMonth_shouldThrowAuraHandledException_whenUserHasntPermissions() {
        User testUserWithoutPermissions = prepareUserWithoutPermissions();
        insert testUserWithoutPermissions;
        
        final Id DUMMY_ACCOUNT_ID = getDummyAccountId();
        final String DUMMY_MONTH_NR = '0';

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
        User userWithPermissions = prepareUserWithPermissions();
        
        final Id DUMMY_ACCOUNT_ID = getDummyAccountId();
        final String DUMMY_MONTH_NR = '0';

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