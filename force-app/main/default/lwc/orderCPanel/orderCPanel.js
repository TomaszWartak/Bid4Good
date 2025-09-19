import { LightningElement, track, wire } from "lwc";
import getAccountWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountWithOrdersPicklistValues";

export default class OrderExplorer extends LightningElement {
  @track accountsPicklistValues = [];
  selectedAccountId;
  isLoading = true;

  @wire(getAccountWithOrdersPicklistValues)
  wiredAccounts({ data, error }) {
    if (data) {
      this.accountsPicklistValues = data;
      this.isLoading = false;
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

  //   get hasAccounts() {
  //     return (
  //       this.accountsPicklistValues && this.accountsPicklistValues.length > 0
  //     );
  //   }

  get isEmpty() {
    return (
      !this.isLoading &&
      (!this.accountsPicklistValues || this.accountsPicklistValues.length === 0)
    );
  }

  get isNotEmpty() {
    return !this.isEmpty;
  }
}
