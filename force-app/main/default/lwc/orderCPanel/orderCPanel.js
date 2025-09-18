import { LightningElement, track, wire } from "lwc";
import getAccountWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountWithOrdersPicklistValues";

export default class OrderExplorer extends LightningElement {
  @track accountsPicklistValues = [];
  selectedAccountId;
  isLoading = true;

  @wire(getAccountWithOrdersPicklistValues)
  wiredAccounts({ data, error }) {
    this.isLoading = false;
    if (data) {
      this.accountsPicklistValues = data;
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

  get isEmpty() {
    return this.accountsPicklistValues.length === 0;
  }
}
