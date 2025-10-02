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
        try { 
            if (!Account.Total_Orders_Number__c.getDescribe().isAccessible() ) {
                // TODO Log: e.getMessage()+getStack() 
                throw new InsufficientPermissionException( Label.Insufficient_Premissions );
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
        } catch (QueryException e) { 
            // TODO Log: e.getMessage()+getStack() 
            throw new AuraHandledException( Label.Query_Error ); 
        } catch (Exception e) {
            // TODO Log: e.getMessage()+getStack() 
            throw new AuraHandledException( Label.General_Error ); 
        }
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
        try {
            if (!Order__c.SObjectType.getDescribe().isAccessible()) {
            // TODO Log: e.getMessage()+getStack() 
                throw new InsufficientPermissionException( Label.Insufficient_Premissions );
            }
            
            if (!Order__c.Payment_Due_Date__c.getDescribe().isAccessible() ) {
            // TODO Log: e.getMessage()+getStack() 
                throw new InsufficientPermissionException( Label.Insufficient_Premissions );
            }
            
            List<Order__c> orders = [
                SELECT Payment_Due_Date__c
                FROM Order__c
                WHERE Account__c = :accountId AND Payment_Due_Date__c != NULL
                ORDER BY Payment_Due_Date__c ASC
                LIMIT 1000
            ]; 
            return createMonthPicklistValues(orders);
        } catch (QueryException e) { 
            // TODO Log: e.getMessage()+getStack() 
            throw new AuraHandledException( Label.Query_Error );  
        } catch (Exception e) {
             // TODO Log: e.getMessage()+getStack() 
           throw new AuraHandledException( Label.General_Error ); 
        }
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

    //=======================================================================
    @AuraEnabled
    public static List<Order__c> getOrdersForAccountAndDueDateMonth(
        Id accountId,
        Integer dueDateMonth
    ) {
        try {
            if (!Order__c.SObjectType.getDescribe().isAccessible()) {
                // TODO Log: e.getMessage()+getStack() 
                throw new InsufficientPermissionException( Label.Insufficient_Premissions );
            }
            
            if (!Order__c.Payment_Due_Date__c.getDescribe().isAccessible() ||
                !Order__c.fields.Total_Amount__c.getDescribe().isAccessible()) {
                // TODO Log: e.getMessage()+getStack() 
                throw new InsufficientPermissionException( Label.Insufficient_Premissions );
            }

            List<Order__c> orders = new List<Order__c>();
            if (accountId == null || dueDateMonth == null) {
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

            for (Order__c ord : orders) {
                if (ord.Payment_Due_Date__c.month() == dueDateMonth) {
                    ordersWithDueDateMonth.add(ord);
                }
            }
            return ordersWithDueDateMonth;
        } catch (QueryException e) { 
            // TODO Log: e.getMessage()+getStack() 
            throw new AuraHandledException( Label.Query_Error ); 
        } catch (Exception e) {
            // TODO Log: e.getMessage()+getStack() 
            throw new AuraHandledException( Label.General_Error ); 
        }
    }

}