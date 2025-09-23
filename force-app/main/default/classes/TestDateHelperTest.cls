@isTest
private class TestDateHelperTest {

    @isTest
    static void getTestMonth_shouldReturn1_for_8_fm_0_0() {
        Integer accountNr = 0;
        Integer orderNr = 0;
        Integer result = TestDateHelper.getTestMonth(
            TestDataFactory.ORDERS_PER_ACCOUNT, 
            TestDataFactory.FIXED_MONTHS, 
            accountNr,
            orderNr);
        System.assertEquals(1, result);
    }

    @isTest
    static void getTestMonth_shouldReturn9_for_8_fm_0_4() {
        Integer accountNr = 0;
        Integer orderNr = 4;
        Integer result = TestDateHelper.getTestMonth(
            TestDataFactory.ORDERS_PER_ACCOUNT, 
            TestDataFactory.FIXED_MONTHS, 
            accountNr,
            orderNr);
        System.assertEquals(9, result);
    }

    @isTest
    static void getTestMonth_shouldReturn9_for_8_fm_0_7() {
        Integer accountNr = 0;
        Integer orderNr = 7;
        Integer result = TestDateHelper.getTestMonth(
            TestDataFactory.ORDERS_PER_ACCOUNT, 
            TestDataFactory.FIXED_MONTHS, 
            accountNr,
            orderNr);
        System.assertEquals(4, result);
    }

    @isTest
    static void getTestMonth_shouldReturn9_for_8_fm_2_1() {
        Integer accountNr = 2;
        Integer orderNr = 1;
        Integer result = TestDateHelper.getTestMonth(
            TestDataFactory.ORDERS_PER_ACCOUNT, 
            TestDataFactory.FIXED_MONTHS, 
            accountNr,
            orderNr);
        System.assertEquals(4, result);
    }
}