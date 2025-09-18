public with sharing class TestDateUtils {
    public static Date getRandomDateWithinMonths( Integer monthsAhead ) {
        if (monthsAhead <= 0) {
            return Date.today();
        }
        Date today = Date.today();
        Date endDate = today.addMonths(monthsAhead);

        Integer daysBetween = endDate.daysBetween(today); 

        Integer daysOffset = Math.mod(Crypto.getRandomInteger(), daysBetween + 1);

        return today.addDays(daysOffset);
    }
}