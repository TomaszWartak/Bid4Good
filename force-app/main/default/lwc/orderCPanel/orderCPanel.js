import { LightningElement, track, wire } from "lwc";
import { subscribe, unsubscribe, onError } from "lightning/empApi";

import getAccountsWithOrdersPicklistValues_Cacheable from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues_Cacheable";
import getAccountsWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues_Cacheable from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues_Cacheable";
import getOrdersForAccountAndDueDateMonth from "@salesforce/apex/OrderCController.getOrdersForAccountAndDueDateMonth";

export default class OrderExplorer extends LightningElement {
  // API FOR LAYOUT ---------------------

  // --- for spinner while loading Accounts
  _isAccountPicklistLoading = true;

  // --- for Account Picker
  get _isAccountListNotEmpty() {
    return !this._isAccountListEmpty;
  }
  @track _accountsPicklistValues = [];
  @track _selectedAccountId;
  _handleAccountChange(event) {
    this._selectedAccountId = event.detail.value;
    this._selectedMonth = null; // Zresetuj miesiąc po zmianie konta
    this.refreshMonthsAndOrders();
  }

  // --- for Months due date picker
  get _isMonthsDueDateListNotEmpty() {
    return !this._isAccountListEmpty; // If account list is not empty, months list is also not empty
  }
  @track _monthsDueDatePicklistValues = [];
  @track _selectedMonth;
  _handleMonthsDueDateChange(event) {
    this._selectedMonth = event.target.value;
    this.refreshOrders();
  }

  // --- for Orders List
  get _isOrdersListNotEmpty() {
    return !this.areOrdersLoading && this._orders && this._orders.length > 0;
  }
  @track _orders = [];
  _ordersColumns = [
    {
      label: "Order Name",
      fieldName: "orderUrl",
      type: "url",
      typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
    },
    {
      label: "Payment Due Date",
      fieldName: "Payment_Due_Date__c",
      type: "date"
    }
  ];

  // --- for No Accounts with Orders message
  get _isAccountListEmpty() {
    return (
      !this._isAccountPicklistLoading &&
      (!this._accountsPicklistValues ||
        this._accountsPicklistValues.length === 0)
    );
  }

  // INTERNAL --------------------------------------
  areOrdersLoading = false;

  // Użyjemy @wire do początkowego ładowania danych na podstawie parametrów
  // To zapewni buforowanie dla optymalizacji, gdy parametry się zmieniają
  @wire(getAccountsWithOrdersPicklistValues_Cacheable)
  wiredAccounts({ data, error }) {
    // log
    console.log("wiredAccounts()");
    if (data) {
      this._accountsPicklistValues = data;
      this._isAccountPicklistLoading = false;
      // TODO: console log - usunac pozniej
      console.log(
        "Accounts from Apex:\n",
        JSON.stringify(this._accountsPicklistValues)
      );
    }
    if (error) {
      console.error(error);
    }
  }

  // TODO - wygląda podobnie do wiredAccounts
  refreshAccounts() {
    // log
    console.log("refreshAccounts()");
    getAccountsWithOrdersPicklistValues()
      .then((data) => {
        this._accountsPicklistValues = data;
        // TODO: console log - usunac pozniej
        console.log(
          "Accounts from Apex:\n",
          JSON.stringify(this._accountsPicklistValues)
        );
      })
      .catch((error) => {
        console.error("refreshAccounts error:", error);
      });
  }

  @wire(getPaymentDueDateMonthsForAccountPicklistValues_Cacheable, {
    accountId: "$_selectedAccountId"
  })
  wiredMonths({ data, error }) {
    // log
    console.log("wiredMonths()");
    if (data) {
      this._monthsDueDatePicklistValues = data;
      // TODO: console log - usunac pozniej
      console.log(
        "Months from Apex:\n",
        JSON.stringify(this._monthsDueDatePicklistValues)
      );
    }
    if (error) {
      console.error(error);
    }
  }

  // TODO - wygląda podobnie do wiredMonths
  refreshMonthsAndOrders() {
    // log
    console.log("refreshMonthsAndOrders()");

    if (!this._selectedAccountId) {
      return;
    }
    getPaymentDueDateMonthsForAccountPicklistValues({
      accountId: this._selectedAccountId
    }).then((data) => {
      this._monthsDueDatePicklistValues = data;
      // TODO: console log - usunac pozniej
      console.log(
        "Months from Apex:\n",
        JSON.stringify(this._monthsDueDatePicklistValues)
      );
    });

    this.refreshOrders();
  }

  refreshOrders() {
    console.log("refreshOrders()");
    if (!this._selectedAccountId || !this._selectedMonth) {
      this._orders = [];
      return;
    }

    this.areOrdersLoading = true;
    getOrdersForAccountAndDueDateMonth({
      // getTest({
      accountId: this._selectedAccountId,
      dueDateMonth: parseInt(this._selectedMonth, 10)
    })
      .then((data) => {
        // TODO: console log - usunac pozniej
        this._orders = data.map((order) => ({
          ...order,
          orderUrl: `/lightning/r/Order__c/${order.Id}/view`
        }));
        console.log("Orders from Apex:\n", JSON.stringify(this._orders));
      })
      .catch((error) => {
        console.error(error);
      })
      .finally(() => {
        this.areOrdersLoading = false;
      });
  }

  // --- LIFE CYCLE HOOKS ---
  /**/ connectedCallback() {
    this.subscribeToCDC();
  }

  /**/ disconnectedCallback() {
    this.unsubscribeFromCDC();
  }

  // --- CDC service ---
  /**/ accountSubscription = {};
  /**/ orderSubscription = {};

  subscribeToCDC() {
    // AccountChangeEvent
    const accountChannel = "/data/AccountChangeEvent";
    subscribe(accountChannel, -1, (message) => {
      console.log("Account change event received:", message);
      this.refreshAccounts();
    }).then((response) => {
      this.accountSubscription = response;
    });

    // Order__ChangeEvent
    const orderChannel = "/data/Order__ChangeEvent";
    subscribe(orderChannel, -1, (message) => {
      console.log("Order__c change event received:", message);
      // Wywołaj loadOrders() bezpośrednio po otrzymaniu zdarzenia
      // this.loadOrders();
      this.refreshMonthsAndOrders();
    }).then((response) => {
      this.orderSubscription = response;
    });

    onError((error) => {
      console.error("CDC Error:", error);
    });
  }

  unsubscribeFromCDC() {
    if (this.accountSubscription?.id) {
      unsubscribe(this.accountSubscription, () => {});
    }
    if (this.orderSubscription?.id) {
      unsubscribe(this.orderSubscription, () => {});
    }
  }

  /*  

  subscribeToCDC() {
    // AccountChangeEvent
    const accountChannel = '/data/AccountChangeEvent';
    subscribe(accountChannel, -1, message => {
      console.log('Account change event received:', message);
      this.refreshAccounts();
    }).then(response => {
      this.accountSubscription = response;
    });

    // Order__ChangeEvent
    const orderChannel = '/data/Order__ChangeEvent';
    subscribe(orderChannel, -1, message => {
      console.log('Order__c change event received:', message);
      this.refreshOrdersAndMonths();
    }).then(response => {
      this.orderSubscription = response;
    });

    // Handle errors
    onError(error => {
      console.error('CDC Error:', error);
    });
  }

  refreshAccounts() {
    // log
    console.log('refreshAccounts()');
    getAccountsWithOrdersPicklistValues()
      .then((data) => {
        this.accountsPicklistValues = data;
      })
      .catch((error) => {
        console.error('refreshAccounts error:', error);
      });
  }

  refreshOrdersAndMonths() {
    // log
    console.log('refreshOrdersAndMonths()');

    if (!this.selectedAccountId) return;

    getPaymentDueDateMonthsForAccountPicklistValues({
      accountId: this.selectedAccountId
    })
    .then((data) => {
      this.monthsDueDatePicklistValues = data;
    });

    if (this.selectedMonth) {
      this.loadOrders();
    }
  }

  unsubscribeFromCDC() {
    if (this.accountSubscription?.id) {
      unsubscribe(this.accountSubscription, response => {
        console.log('Unsubscribed from AccountChangeEvent');
      });
    }
    if (this.orderSubscription?.id) {
      unsubscribe(this.orderSubscription, response => {
        console.log('Unsubscribed from Order__cChangeEvent');
      });
    }
  }

  @track accountsPicklistValues = [];
  selectedAccountId;
  isAccountPicklistLoading = true;

  @wire(getAccountsWithOrdersPicklistValues)
  wiredAccounts({ data, error }) {
    if (data) {
      this.accountsPicklistValues = data;
      this.isAccountPicklistLoading = false;
      // TODO: console log - usunac pozniej
      console.log(
        "Accounts from Apex:",
        JSON.stringify(this.accountsPicklistValues)
      );
    }
    if (error) {
      console.error(error);
    }
  }

  handleAccountChange(event) {
    // TODO: console log - usunac pozniej
    console.log("handleAccountChange()");
    this.selectedAccountId = event.detail.value;
    this.loadMonthsDueDate();
  }

  get isAccountListEmpty() {
    return (
      !this.isAccountPicklistLoading &&
      (!this.accountsPicklistValues || this.accountsPicklistValues.length === 0)
    );
  }

  get isAccountListNotEmpty() {
    return !this.isAccountListEmpty;
  }

  @track monthsDueDatePicklistValues = [];
  selectedMonth;

  loadMonthsDueDate() {
    this.monthsDueDatePicklistValues = [];
    this.monthOfDueDate = null;
    // TODO: console log - usunac pozniej
    console.log("loadMonthsDueDate entry");
    if (this.selectedAccountId) {
      getPaymentDueDateMonthsForAccountPicklistValues({
        accountId: this.selectedAccountId
      })
        .then((data) => {
          this.monthsDueDatePicklistValues = data;
          if (data.length > 0) {
            this.monthOfDueDate = data[0].value;
          }
          console.log("Months from Apex:", JSON.stringify(data));
        })
        .catch((error) => {
          console.error(error);
        });
    }
  }

  handleMonthsDueDateChange(event) {
    // TODO
    console.log("handleMonthsDueDateChange()");
    this.monthOfDueDate = event.target.value;
    this.loadOrders();
  }

  get isMonthsDueDateListNotEmpty() {
    return (
      this.monthsDueDatePicklistValues &&
      this.monthsDueDatePicklistValues.length > 0
    );
  }

  @track orders = [];
  isOrdersLoading = false;

  get isOrdersListNotEmpty() {
    return !this.isOrdersLoading && this.orders && this.orders.length > 0;
  }

  // TODO
  // get monthOfDueDate() {
  //   return this.selectedMonth;
  // }

  set monthOfDueDate(value) {
    this.selectedMonth = value;
    this.loadOrders();
  }

  ordersColumns = [
    {
      label: "Order Name",
      fieldName: "orderUrl",
      type: "url",
      typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
    },
    {
      label: "Payment Due Date",
      fieldName: "Payment_Due_Date__c",
      type: "date"
    }
  ];

  loadOrders() {
    this.orders = [];
    // TODO: console log - usunac pozniej
    console.log("loadOrders entry");
    if (this.selectedAccountId && this.selectedMonth) {
      //log
      console.log("loadOrders calling Apex");

      this.isOrdersLoading = true;
      // Call Apex method to get orders for selected account and month
      getOrdersForAccountAndDueDateMonth({
        accountId: this.selectedAccountId,
        dueDateMonth: parseInt(this.selectedMonth, 10)
      })
        .then((data) => {
          // log
          console.log("loadOrders Apex returned data");
          console.log("loadOrders data:", JSON.stringify(data));
          console.log("loadOrders data length:", data.length);

          // TODO this.orders = data;
          this.orders = data.map((order) => ({
            ...order,
            orderUrl: `/lightning/r/Order__c/${order.Id}/view`
          }));
          this.isOrdersLoading = false;
          console.log("Orders from Apex:", JSON.stringify(data));
        })
        .catch((error) => {
          console.error(error);
          this.isOrdersLoading = false;
        });
    }
  } */
}
