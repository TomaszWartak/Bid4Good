@isTest
private class DateUtilsTest {
  @isTest
  static void getMonthName_shouldReturnCorrectMonthName_forValidMonthNumber() {
    System.assertEquals('January', DateUtils.getMonthName(1));
    System.assertEquals('December', DateUtils.getMonthName(12));
  }

  @isTest
  static void getMonthName_shouldReturnEmptyString_forInvalidMonthNumber() {
    System.assertEquals('', DateUtils.getMonthName(0)); 
    System.assertEquals('', DateUtils.getMonthName(13));
  }
}
