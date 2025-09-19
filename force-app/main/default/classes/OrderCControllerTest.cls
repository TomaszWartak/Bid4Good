@isTest
private class OrderCControllerTest {
  @isTest
  static void getMonthName_shouldReturnCorrectMonthName() {
    System.assertEquals('January', OrderCController.getMonthName(1));
    System.assertEquals('December', OrderCController.getMonthName(12));
  }

  @isTest
  static void getMonthName_shouldReturnEmptyStringForInvalidMonth() {
    System.assertEquals('', OrderCController.getMonthName(0)); // poza zakresem
    System.assertEquals('', OrderCController.getMonthName(13)); // poza zakresem
  }
}
