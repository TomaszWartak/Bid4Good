public with sharing class DateUtils {
  public static final String YEAR_MONTH_SEPARATOR = '-';

  public static String getMonthName(Integer month) {
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

  public static String getYearMonthString(Date dateToConvert) {
    Integer year = dateToConvert.year();
    Integer month = dateToConvert.month();
    return getYearMonthString(year, month);
  }

  public static String getYearMonthString(Integer year, Integer month) {
    return String.valueOf(year) +
      YEAR_MONTH_SEPARATOR +
      String.valueOf(month).leftPad(2, '0');
  }

  public static Integer getYearIntFromYearMonthString(String yearMonth) {
    return Integer.valueOf(yearMonth.split(YEAR_MONTH_SEPARATOR)[0]);
  }

  public static Integer getMonthIntFromYearMonthString(String yearMonth) {
    // TODO
    System.debug(yearMonth);
    return Integer.valueOf(yearMonth.split(YEAR_MONTH_SEPARATOR)[1]);
  }
}
