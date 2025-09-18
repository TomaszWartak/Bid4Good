import { LightningElement, track, wire } from "lwc";
import getAccountWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountWithOrdersPicklistValues";

export default class OrderExplorer extends LightningElement {
  @track accountsPicklistValues = []; // [{label, value}]
  selectedAccountId;
  @wire(getAccountWithOrdersPicklistValues)
  wiredAccounts({ data, error }) {
    if (data) this.accountsPicklistValues = data;
    if (error) console.error(error);
  }
  handleAccountChange(event) {
    this.selectedAccountId = event.detail.value;
  }
}
