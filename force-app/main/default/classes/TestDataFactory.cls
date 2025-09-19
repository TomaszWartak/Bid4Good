@IsTest
public with sharing class TestDataFactory {
  public static Integer accountsNr = 5;
  public static Integer[] ordersPerAccount = new List<Integer>{
    8,
    11,
    7,
    1,
    13
  };
  public static Integer[] fixedMonths = new List<Integer>{ 1, 2, 4, 8, 9 };

  public static List<Account> createAccountsWithOrders() {
    List<Account> accs = createAccounts(accountsNr);
    // TODO - co z rezultatme createOrders()
    List<Order__c> ords = createOrders(accs, ordersPerAccount);
    return accs;
  }

  private static List<Account> createAccounts(Integer howMany) {
    List<Account> accs = new List<Account>();
    for (Integer accNr = 1; accNr <= howMany; accNr++) {
      accs.add(new Account(Name = createAccountName(accNr)));
    }
    insert accs;
    return accs;
  }

  @testVisible
  private static String createAccountName(Integer accNr) {
    return 'Test Account ' + accNr;
  }

  private static List<Order__c> createOrders(
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
    return ords;
  }

  @testVisible
  private static String createOrderNameForAccount(
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
      Payment_Due_Date__c = TestDateHelper.getFixedMonthTestDate(fixedMonths)
    );
    return ord;
  }
}
