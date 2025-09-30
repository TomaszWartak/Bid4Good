public with sharing class OrderCController {
  public class PicklistValue {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    public PicklistValue(String l, String v) {
      label = l;
      value = v;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<PicklistValue> getAccountsWithOrdersPicklistValues_Cacheable() {
    return getAccountsWithOrdersPicklistValues();
  }

  @AuraEnabled
  public static List<PicklistValue> getAccountsWithOrdersPicklistValues() {
    List<PicklistValue> pickListValues = new List<PicklistValue>();
    for (Account acc : [
      SELECT Name
      FROM Account
      WHERE Total_Orders_Number__c > 0
      ORDER BY Name
    ]) {
      pickListValues.add(new PicklistValue(acc.Name, String.valueOf(acc.Id)));
    }
    return pickListValues;
  }

  // ============================================================================
  @AuraEnabled
  public static List<PicklistValue> getAccountsWithOrdersPicklistValues_Schema() {
      
    // **************************************************************
      if (!Schema.SObjectType.Account.fields.get('Total_Orders_Number__c').isAccessible()) {
          // Zabezpieczenie: Jeśli brak dostępu, zwróć pustą listę lub zgłoś błąd.
          // Zwracamy pustą listę, aby aplikacja nie wysypała się w LWC.
          return new List<PicklistValue>();
      }
    // **************************************************************
      
      List<PicklistValue> pickListValues = new List<PicklistValue>();
      for (Account acc : [
          SELECT Name, Total_Orders_Number__c // Odpytujemy również o to pole, choć Name jest kluczowe
          FROM Account
          WHERE Total_Orders_Number__c > 0
          ORDER BY Name
      ]) {
          // Kontynuacja logiki...
          pickListValues.add(new PicklistValue(acc.Name, String.valueOf(acc.Id)));
      }
      return pickListValues;
  }


  @AuraEnabled(cacheable=true)
  public static List<PicklistValue> getPaymentDueDateMonthsForAccountPicklistValues_Cacheable(
    Id accountId
  ) {
    return getPaymentDueDateMonthsForAccountPicklistValues(accountId);
  }

  @AuraEnabled
  public static List<PicklistValue> getPaymentDueDateMonthsForAccountPicklistValues(
    Id accountId
  ) {
    List<Order__c> orders = [
      SELECT Payment_Due_Date__c
      FROM Order__c
      WHERE Account__c = :accountId AND Payment_Due_Date__c != NULL
      ORDER BY Payment_Due_Date__c ASC
    ];

    return createMonthPicklistValues(orders);
  }

  @testVisible
  private static List<PicklistValue> createMonthPicklistValues(
    List<Order__c> orders
  ) {
    Set<Integer> months = new Set<Integer>();
    for (Order__c ord : orders) {
      if (ord.Payment_Due_Date__c != null) {
        months.add(ord.Payment_Due_Date__c.month());
      }
    }

    List<PicklistValue> pickListValues = new List<PicklistValue>();
    for (Integer month : months) {
      String monthLabel = DateUtils.getMonthName(month);
      String monthValue = String.valueOf(month);
      pickListValues.add(new PicklistValue(monthLabel, monthValue));
    }
    return pickListValues;
  }

  @AuraEnabled
  public static List<Order__c> getOrdersForAccountAndDueDateMonth(
    Id accountId,
    Integer dueDateMonth
  ) {
    List<Order__c> orders = new List<Order__c>();
    if (accountId == null || dueDateMonth == null) {
      return orders;
    }

    orders = [
      SELECT Id, Name, Payment_Due_Date__c, Total_Amount__c
      FROM Order__c
      WHERE Account__c = :accountId AND Payment_Due_Date__c != NULL
      ORDER BY Payment_Due_Date__c ASC
    ];

    List<Order__c> ordersWithDueDateMonth = new List<Order__c>();

    for (Order__c ord : orders) {
      if (ord.Payment_Due_Date__c.month() == dueDateMonth) {
        ordersWithDueDateMonth.add(ord);
      }
    }

    return ordersWithDueDateMonth;
  }

  //=======================================================================
  @AuraEnabled
public static List<Order__c> getOrdersForAccountAndDueDateMonth(
    Id accountId,
    Integer dueDateMonth
) {
  // All methods cover try catch Exception()


    // **************************************************************
    // UŻYCIE SCHEMA METODY: Weryfikacja OLS dla obiektu Order__c
    if (!Schema.SObjectType.Order__c.getDescribe().isAccessible()) {
        return new List<Order__c>(); // Zabezpieczenie OLS
        // throw new Custom
    }
    
    // UŻYCIE SCHEMA METODY: Weryfikacja FLS dla kluczowych pól
    if (!Schema.SObjectType.Order__c.fields.get('Payment_Due_Date__c').isAccessible() ||
        !Schema.SObjectType.Order__c.fields.get('Total_Amount__c').isAccessible()) {
        return new List<Order__c>(); // Zabezpieczenie FLS
        // throw new Custom
    }
    // **************************************************************

    List<Order__c> orders = new List<Order__c>();
    if (accountId == null || dueDateMonth == null) {
        return orders;
    }

    orders = [
        SELECT Id, Name, Payment_Due_Date__c, Total_Amount__c
        FROM Order__c
        WHERE Account__c = :accountId AND Payment_Due_Date__c != NULL
        ORDER BY Payment_Due_Date__c ASC
    ];

    // Kontynuacja logiki filtrowania...
    List<Order__c> ordersWithDueDateMonth = new List<Order__c>();
    for (Order__c ord : orders) {
      if (ord.Payment_Due_Date__c.month() == dueDateMonth) {
        ordersWithDueDateMonth.add(ord);
      }
    }

    return ordersWithDueDateMonth;
}

}

