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
    try {
      if (isAccountTotalOrdersNumberNotAccesible()) {
        // TODO
        System.debug(
          'getAccountsWithOrdersPicklistValues' +
            '\n' +
            'Insufficient Permissions on Account.Total_Orders_Number__c'
        );
        // TODO Log: e.getMessage()+getStack()
        throw new InsufficientPermissionException(
          // TODO throw new AuraHandledException(
          Label.Insufficient_Premissions
        );
      }

      List<PicklistValue> pickListValues = new List<PicklistValue>();
      for (Account acc : [
        SELECT Name, Total_Orders_Number__c
        FROM Account
        WHERE Total_Orders_Number__c > 0
        ORDER BY Name
        LIMIT 1000
      ]) {
        pickListValues.add(new PicklistValue(acc.Name, String.valueOf(acc.Id)));
      }
      return pickListValues;
    } catch (InsufficientPermissionException e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.Insufficient_Premissions);
    } catch (QueryException e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.Query_Error);
    } catch (Exception e) {
      // TODO Log: e.getMessage()+getStack()
      // TODO
      System.debug(
        'Error: ' + e.getMessage() + +'\n' + e.getStackTraceString()
      );
      throw new AuraHandledException(Label.General_Error);
    }
  }

  private static boolean isAccountTotalOrdersNumberAccesible() {
    return Account.Total_Orders_Number__c.getDescribe().isAccessible();
  }

  private static boolean isAccountTotalOrdersNumberNotAccesible() {
    return !isAccountTotalOrdersNumberAccesible();
  }

  @AuraEnabled(cacheable=true)
  public static List<PicklistValue> getPaymentDueDateMonthsForAccountPicklistValues(
    Id accountId
  ) {
    try {
      if (isOrderCNotAccesible() || isOrderCPaymentDueDateNotAccesible()) {
        // TODO
        System.debug(
          'getPaymentDueDateMonthsForAccountPicklistValues' +
            '\n' +
            'Insufficient Permissions on Order__c'
        );
        // TODO Log: e.getMessage()+getStack()
        throw new InsufficientPermissionException(
          // TODO throw new AuraHandledException(
          Label.Insufficient_Premissions
        );
      }
      // TODO
      System.debug('Account ID: ' + accountId);

      List<Order__c> orders = [
        SELECT Payment_Due_Date__c
        FROM Order__c
        WHERE Account__c = :accountId AND Payment_Due_Date__c != NULL
        ORDER BY Payment_Due_Date__c ASC
        LIMIT 1000
      ];
      return createMonthPicklistValues(orders);
    } catch (InsufficientPermissionException e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.Insufficient_Premissions);
    } catch (QueryException e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.Query_Error);
    } catch (Exception e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.General_Error);
    }
  }

  private static boolean isOrderCAccesible() {
    return Order__c.SObjectType.getDescribe().isAccessible();
  }

  private static boolean isOrderCNotAccesible() {
    return !isOrderCAccesible();
  }

  private static boolean isOrderCPaymentDueDateAccesible() {
    return Order__c.Payment_Due_Date__c.getDescribe().isAccessible();
  }

  private static boolean isOrderCPaymentDueDateNotAccesible() {
    return !isOrderCPaymentDueDateAccesible();
  }

  private static boolean isOrderCTotalAmountAccesible() {
    return Order__c.Total_Amount__c.getDescribe().isAccessible();
  }

  private static boolean isOrderCTotalAmountNotAccesible() {
    return !isOrderCTotalAmountAccesible();
  }

  @testVisible
  private static List<PicklistValue> createMonthPicklistValues(
    List<Order__c> orders
  ) {
    Set<String> months = new Set<String>();
    for (Order__c ord : orders) {
      if (ord.Payment_Due_Date__c != null) {
        months.add(DateUtils.getYearMonthString(ord.Payment_Due_Date__c));
      }
    }

    List<PicklistValue> pickListValues = new List<PicklistValue>();
    for (String month : months) {
      String monthLabel = month;
      String monthValue = month;
      pickListValues.add(new PicklistValue(monthLabel, monthValue));
    }
    return pickListValues;
  }

  // TODO remove if unused
  @testVisible
  private static List<PicklistValue> createMonthPicklistValues2(
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

  @AuraEnabled(cacheable=true)
  public static List<Order__c> getOrdersForAccountAndDueDateMonth(
    Id accountId,
    String dueDateYearMonth
  ) {
    try {
      if (
        isOrderCNotAccesible() ||
        isOrderCPaymentDueDateNotAccesible() ||
        isOrderCTotalAmountNotAccesible()
      ) {
        // TODO
        System.debug(
          'getOrdersForAccountAndDueDateMonth' +
            '\n' +
            'Insufficient Permissions on Order__c'
        );
        // TODO Log: e.getMessage()+getStack()
        throw new InsufficientPermissionException(
          // TODO throw new AuraHandledException(
          Label.Insufficient_Premissions
        );
      }

      List<Order__c> orders = new List<Order__c>();
      if (accountId == null || String.isBlank(dueDateYearMonth)) {
        return orders;
      }

      List<Order__c> ordersWithDueDateMonth = new List<Order__c>();

      orders = [
        SELECT Id, Name, Payment_Due_Date__c, Total_Amount__c
        FROM Order__c
        WHERE Account__c = :accountId AND Payment_Due_Date__c != NULL
        ORDER BY Payment_Due_Date__c ASC
        LIMIT 1000
      ];

      // TODO
      System.debug(dueDateYearMonth);
      Integer year = DateUtils.getYearIntFromYearMonthString(dueDateYearMonth);
      Integer month = DateUtils.getMonthIntFromYearMonthString(
        dueDateYearMonth
      );

      for (Order__c ord : orders) {
        if (
          (ord.Payment_Due_Date__c.year() == year) &&
          (ord.Payment_Due_Date__c.month() == month)
        ) {
          ordersWithDueDateMonth.add(ord);
        }
      }
      return ordersWithDueDateMonth;
    } catch (InsufficientPermissionException e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.Insufficient_Premissions);
    } catch (QueryException e) {
      // TODO Log: e.getMessage()+getStack()
      throw new AuraHandledException(Label.Query_Error);
    } catch (Exception e) {
      // TODO Log: e.getMessage()+getStack()
      // TODO
      System.debug('Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
      throw new AuraHandledException(Label.General_Error);
    }
  }
}
