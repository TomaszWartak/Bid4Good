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

  @IsTest
  static void getYearMonthString_shouldReturnLeadingZero_forMarch() {
    // Given
    Date testDate = Date.newInstance(2025, 3, 15); // marzec 2025

    // When
    String result = DateUtils.getYearMonthString(testDate);

    // Then
    System.assertEquals(
      '2025-03',
      result,
      'Should return year and two-digit month (03) for March'
    );
  }

  @IsTest
  static void getYearMonthString_shouldReturnTwoDigitMonth_forNovember() {
    // Given
    Date testDate = Date.newInstance(2025, 11, 5); // listopad 2025

    // When
    String result = DateUtils.getYearMonthString(testDate);

    // Then
    System.assertEquals(
      '2025-11',
      result,
      'Should return year and two-digit month (11) for November'
    );
  }

  @IsTest
  static void getYearIntFromYearMonthString_shouldReturnCorrectYear() {
    // given
    String ym = '2025-10';

    // when
    Integer result = DateUtils.getYearIntFromYearMonthString(ym);

    // then
    System.assertEquals(2025, result, 'Should correctly extract the year part');
  }

  @IsTest
  static void getMonthIntFromYearMonthString_shouldReturnCorrectMonth() {
    // given
    String ym = '2025-10';

    // when
    Integer result = DateUtils.getMonthIntFromYearMonthString(ym);

    // then
    System.assertEquals(10, result, 'Should correctly extract the month part');
  }

  @IsTest
  static void getMonthIntFromYearMonthString_shouldHandleLeadingZero() {
    // given
    String ym = '2024-03';

    // when
    Integer result = DateUtils.getMonthIntFromYearMonthString(ym);

    // then
    System.assertEquals(
      3,
      result,
      'Should correctly parse month with leading zero'
    );
  }
}
