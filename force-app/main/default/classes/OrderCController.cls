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

  @AuraEnabled(cacheable=true)
  public static List<PicklistValue> getPaymentDueDateMonthsPicklistValues() {
    List<Order__c> orders = [
      SELECT Payment_Due_Date__c
      FROM Order__c
      WHERE Payment_Due_Date__c != NULL
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
}
