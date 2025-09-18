public with sharing class OrderCController {
    public static final String ACCOUNT_NAME = 'Account Name';
    
    public class PicklistValue{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public PicklistValue(String l, String v) { label = l; value = v; }
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistValue> getAccountWithOrdersPicklistValues() {
        List<PicklistValue> pickListValues = new List<PicklistValue>();
        for (Account acc : 
                [SELECT Name 
                FROM Account 
                WHERE Total_Orders_Number__c > 0
                ORDER BY Name]) {
            pickListValues.add( new PicklistValue( ACCOUNT_NAME, acc.Name ) );
        }
        return pickListValues;
    }
}