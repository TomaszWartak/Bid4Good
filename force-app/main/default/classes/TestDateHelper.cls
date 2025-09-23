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
    // TODO
    // Obliczamy globalny numer zamówienia.
    // acountNr * ordersPerAccount przesunie nas do właściwego bloku konta.
    // + orderNr wskazuje konkretne zamówienie w tym bloku.
    Integer globalOrderNr = (accountNr * ordersPerAccount) + orderNr;

    // Używamy operacji modulo (%), aby cyklicznie wybierać indeks z tablicy fixedMonths.
    // Jeżeli globalOrderNr jest większy niż ostatni indeks tablicy, operacja modulo
    // "zawinie" go z powrotem na początek.
    Integer index = Math.mod(globalOrderNr, fixedMonths.size());
    
    return fixedMonths[index];
  }
}
