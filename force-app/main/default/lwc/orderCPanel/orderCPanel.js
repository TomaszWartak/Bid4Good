import { LightningElement, track, wire } from "lwc";
import getAccountsWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues";
import getOrdersForAccountAndDueDateMonth from "@salesforce/apex/OrderCController.getOrdersForAccountAndDueDateMonth";

export default class OrderExplorer extends LightningElement {
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

  loadOrders() {
    this.orders = [];
    // TODO: console log - usunac pozniej
    console.log("loadOrders entry");
    if (this.selectedAccountId && this.selectedMonth) {
      this.isOrdersLoading = true;
      // Call Apex method to get orders for selected account and month
      getOrdersForAccountAndDueDateMonth({
        accountId: this.selectedAccountId,
        dueDateMonth: parseInt(this.selectedMonth, 10)
      })
        .then((data) => {
          this.orders = data;
          this.isOrdersLoading = false;
          console.log("Orders from Apex:", JSON.stringify(data));
        })
        .catch((error) => {
          console.error(error);
          this.isOrdersLoading = false;
        });
    }
  }
}
