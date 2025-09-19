public with sharing class OrderCController {
  public static final String ACCOUNT_NAME = 'Account Name';

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
  public static List<PicklistValue> getAccountWithOrdersPicklistValues() {
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

  // Lista miesięcy (label i value) gdzie wypada płatność do picklisty
  @AuraEnabled(cacheable=true)
  public static List<PicklistValue> getPaymentDueDateMonthsPicklistValues() {
    List<Order__c> orders = [
      SELECT Payment_Due_Date__c
      FROM Order__c
      WHERE Payment_Due_Date__c != NULL
    ];

    Set<Integer> months = new Set<Integer>();
    for (Order__c ord : orders) {
      if (ord.Payment_Due_Date__c != null) {
        months.add(ord.Payment_Due_Date__c.month());
      }
    }
    // utworzenie listy PicklistValue z nazwami miesięcy
    List<PicklistValue> pickListValues = new List<PicklistValue>();
    for (Integer month : months) {
      String monthLabel = getMonthName(month);
      String monthValue = String.valueOf(month);
      pickListValues.add(new PicklistValue(monthLabel, monthValue));
    }
    return pickListValues;
  }

  private static String getMonthName(Integer month) {
    List<String> monthNames = new List<String>{
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    };
    if (month >= 1 && month <= 12) {
      return monthNames[month - 1];
    }
    return '';
  }
}
