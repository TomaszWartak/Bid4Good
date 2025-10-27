@IsTest
public with sharing class TestDataFactory {
  public final static Integer ACCOUNTS_NUMBER = 5;
  public final static Integer ORDERS_PER_ACCOUNT = 8;
  public static Integer[] ordersPerAccount = prepareEvenlyOrdersPerAccount();

  public static final String TEST_USER_WITHOUT_PERMISSIONS_ALIAS = 'testuden';
  public static final String TEST_USER_WITH_PERMISSIONS_ALIAS = 'testuacc';

  public final static Integer[] FIXED_MONTHS = new List<Integer>{
    1,
    2,
    4,
    8,
    9
  };

  private final static List<Account> accs = new List<Account>();

  private static List<Integer> prepareEvenlyOrdersPerAccount() {
    List<Integer> targetList = new List<Integer>();
    for (Integer i = 0; i < ACCOUNTS_NUMBER; i++) {
      targetList.add(ORDERS_PER_ACCOUNT);
    }
    return targetList;
  }

  public static void createAccountsWithOrders() {
    createAccounts(ACCOUNTS_NUMBER);
    createOrders(accs, ordersPerAccount);
  }

  private static void createAccounts(Integer howMany) {
    for (Integer accNr = 1; accNr <= howMany; accNr++) {
      accs.add(new Account(Name = createAccountName(accNr)));
    }
    insert accs;
  }

  @testVisible
  private static String createAccountName(Integer accNr) {
    return 'Test Account ' + accNr;
  }

  private static void createOrders(
    List<Account> accs,
    Integer[] ordersPerAccount
  ) {
    List<Order__c> ords = new List<Order__c>();
    for (Integer accNr = 0; accNr < accs.size(); accNr++) {
      Account acc = accs[accNr];
      Integer howManyOrders = ordersPerAccount[accNr];
      for (Integer ordNr = 1; ordNr <= howManyOrders; ordNr++) {
        String orderName = createOrderNameForAccount(ordNr, acc.Name);
        Double totalAmount = Math.round(Math.random() * 10000) / 100.0;
        ords.add(prepareOrder(acc, orderName, totalAmount));
      }
    }
    insert ords;
  }

  public static String createOrderNameForAccount(
    Integer ordNr,
    String accName
  ) {
    return 'Test Order ' + ordNr + ' for Account ' + accName;
  }

  private static Order__c prepareOrder(
    Account acc,
    String orderName,
    Double totalAmount
  ) {
    Order__c ord = new Order__c(
      Account__c = acc.Id,
      Name = orderName,
      Total_Amount__c = totalAmount,
      Payment_Due_Date__c = TestDateHelper.getNextFixedMonthTestDate(
        FIXED_MONTHS
      )
    );
    return ord;
  }

  public static List<Account> getAccountsWithOrders() {
    return [
      SELECT Name, Total_Orders_Number__c
      FROM Account
      WHERE Id IN :accs
      ORDER BY Name
    ];
  }

  public static Integer getTestMonth(Integer accountNr, Integer orderNr) {
    return TestDateHelper.getTestMonth(
      ORDERS_PER_ACCOUNT,
      FIXED_MONTHS,
      accountNr,
      orderNr
    );
  }

  public static void createUsers() {
    createUserWithoutPermissions();
    createUserWithPermissions();
  }

  private static void createUserWithoutPermissions() {
    Profile standardUserProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];
    User u = new User(
      ProfileId = standardUserProfile.Id,
      Email = 'testuser' + System.currentTimeMillis() + '@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser' + System.currentTimeMillis() + '@example.com',
      Alias = TEST_USER_WITHOUT_PERMISSIONS_ALIAS
    );
    insert u;
  }

  private static void createUserWithPermissions() {
    Profile standardUserProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];
    User u = new User(
      ProfileId = standardUserProfile.Id,
      Email = 'testuser' + System.currentTimeMillis() + '@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Test',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'testuser' + System.currentTimeMillis() + '@example.com',
      Alias = TEST_USER_WITH_PERMISSIONS_ALIAS
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
  }

  public static User getUserWithoutPermissions() {
    return getUserByAlias(TEST_USER_WITHOUT_PERMISSIONS_ALIAS);
  }

  public static User getUserWithPermissions() {
    return getUserByAlias(TEST_USER_WITH_PERMISSIONS_ALIAS);
  }

  private static User getUserByAlias(String alias) {
    return [SELECT Id, Alias FROM User WHERE Alias = :alias LIMIT 1];
  }
}
