import { LightningElement, track, wire } from "lwc";
import getAccountsWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues";
import getPaymentDueDateMonthsPicklistValues from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsPicklistValues";

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
    this.selectedAccountId = event.detail.value;
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

  // Months due date handling
  @wire(getPaymentDueDateMonthsPicklistValues)
  wiredMonthsDueDate({ data, error }) {
    if (data) {
      this.monthsDueDatePicklistValues = data;
      // Set default value to the first option if available
      if (data.length > 0) {
        this.selectedMonth = data[0].value;
      }
      // TODO: console log - usunac pozniej
      console.log(
        "Months from Apex:",
        JSON.stringify(this.monthsDueDatePicklistValues)
      );
    }
    if (error) {
      console.error(error);
    }
  }

  handleMonthsDueDateChange(event) {
    this.monthsDueDate = event.target.value;
  }
}
