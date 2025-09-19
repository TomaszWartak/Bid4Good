import { LightningElement, track, wire } from "lwc";
import getAccountsWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues";

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
    this.selectedMonth = null;
    if (this.selectedAccountId) {
      getPaymentDueDateMonthsForAccountPicklistValues({
        accountId: this.selectedAccountId
      })
        .then((data) => {
          this.monthsDueDatePicklistValues = data;
          if (data.length > 0) {
            this.selectedMonth = data[0].value;
          }
          console.log("Months from Apex:", JSON.stringify(data));
        })
        .catch((error) => {
          console.error(error);
        });
    }
  }

  handleMonthsDueDateChange(event) {
    this.monthsDueDate = event.target.value;
  }
}
