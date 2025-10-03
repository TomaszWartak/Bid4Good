public with sharing class TestDateHelper {
    private static Integer nextTestMonthIndex = 0;

    public static Date getNextFixedMonthTestDate(Integer[] fixedMonths) {
        if (nextTestMonthIndex >= fixedMonths.size()) {
        nextTestMonthIndex = 0;
        }
        Integer testMonth = fixedMonths[nextTestMonthIndex];
        nextTestMonthIndex++;
        return Date.newInstance(2025, testMonth, 15);
    }

    public static Integer getTestMonth(
        Integer ordersPerAccount, 
        Integer[] fixedMonths, 
        Integer accountNr, 
        Integer orderNr
        ) {
        
        Integer globalOrderNr = (accountNr * ordersPerAccount) + orderNr;

        Integer index = Math.mod(globalOrderNr, fixedMonths.size());
        
        return fixedMonths[index];
    }
}
