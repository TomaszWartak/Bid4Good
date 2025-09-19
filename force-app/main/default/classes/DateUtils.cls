public with sharing class DateUtils {
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
}
