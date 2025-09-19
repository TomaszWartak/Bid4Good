public with sharing class TestDateHelper {
  private static Integer nextTestMonthIndex = 0;

  public static Date getFixedMonthTestDate(Integer[] fixedMonths) {
    if (nextTestMonthIndex >= fixedMonths.size()) {
      nextTestMonthIndex = 0;
    }
    Integer testMonth = fixedMonths[nextTestMonthIndex];
    nextTestMonthIndex++;
    return Date.newInstance(2025, testMonth, 15);
  }
}
