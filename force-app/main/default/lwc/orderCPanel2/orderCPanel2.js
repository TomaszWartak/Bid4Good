import { LightningElement, track, wire } from "lwc";
import { subscribe, unsubscribe, onError } from "lightning/empApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { reduceErrors } from 'c/errorUtils';
import { refreshApex } from '@salesforce/apex';

import ADMIN_CONTACT_MESSAGE from '@salesforce/label/c.Contact_system_administrator';

import getAccountsWithOrdersPicklistValues_Cacheable from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues_Cacheable";
import getAccountsWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues_Cacheable from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues_Cacheable";
import getOrdersForAccountAndDueDateMonth from "@salesforce/apex/OrderCController.getOrdersForAccountAndDueDateMonth";

export default class OrderExplorer extends LightningElement {
  // API for "OrderCPanel.HTML" ------------------------------------------------------------------------------------------------

  // --- for spinner while loading Accounts
  isAccountPicklistLoading = true;

  // --- for Account Picker
  get isAccountListNotEmpty() {
    return !this.isAccountListEmpty;
  }
  @track accountsPicklistValues = [];
  wiredAccountsPicklistValuesResult;
  @track selectedAccountId;
  handleAccountChange(event) {
    this.selectedAccountId = event.detail.value;
    this.selectedMonth = null; 
    this.refreshMonthsAndOrders();
  }

  // --- for Months due date picker
  get isMonthsDueDateListNotEmpty() {
    return !this.isAccountListEmpty; // If account list is not empty, months list is also not empty
  }
  @track monthsDueDatePicklistValues = [];
  wiredMonthsDueDatePicklistValuesResult;
  @track selectedMonth;
  handleMonthsDueDateChange(event) {
    this.selectedMonth = event.target.value;
    this.refreshOrders();
  }

  // --- for Orders List
  get _isOrdersListNotEmpty() {
    return !this._areOrdersLoading && this.orders && this.orders.length > 0;
  }
  @track orders = [];
  wiredOrdersResult;
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
      type: "date",
      typeAttributes: {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      }
    },
    {
      label: "Amount",
      fieldName: "Total_Amount__c",
      type: "currency",
      typeAttributes: { currencyCode: 'USD' }
    }
  ];

  // --- for "No Accounts with Orders" message
  get isAccountListEmpty() {
    return (
      !this.isAccountPicklistLoading &&
      (!this.accountsPicklistValues ||
        this.accountsPicklistValues.length === 0)
    );
  }

  // INTERNAL --------------------------------------------------------------------------------------------------------
  _areOrdersLoading = false;

  @wire(getAccountsWithOrdersPicklistValues_Cacheable)
  wiredAccounts( result ) {
    // log
    console.log("wiredAccounts()");
    this.wiredAccountsPicklistValuesResult = result;
    if (result.data) {
      this.accountsPicklistValues = result.data;
      this.isAccountPicklistLoading = false;
      // TODO: 
      console.log(
        "Accounts from Apex:\n",
        JSON.stringify(this.accountsPicklistValues)
      );
    }
    if (result.error) {
        this.handleError(result.error); 
    }
  }

  // TODO - wygląda podobnie do wiredAccounts
  refreshAccounts() {
    // TODO
    console.log("refreshAccounts()");
    getAccountsWithOrdersPicklistValues()
        .then((data) => {
            this._accountsPicklistValues = data;
            // TODO: 
            console.log(
            "Accounts from Apex:\n",
            JSON.stringify(this.accountsPicklistValues)
            );
        })
        .catch((error) => {
            this.handleError(error); 
        });
  }

  @wire(getPaymentDueDateMonthsForAccountPicklistValues_Cacheable, {
    accountId: "$selectedAccountId"
  })
  wiredMonths( result ) {
    // TODO 
    console.log("wiredMonths()");
    this.wiredMonthsDueDatePicklistValuesResult = result;
    if (result.data) {
        this.monthsDueDatePicklistValues = result.data;
        // TODO:
        console.log(
            "Months from Apex:\n",
            JSON.stringify(this.monthsDueDatePicklistValues)
        );
    }
    if (result.error) {
        this.handleError(result.error); 
    }
  }


    refreshMonthsAndOrders() {
        // TODO
        console.log("refreshMonthsAndOrders()");

        if (!this.selectedAccountId) {
            return;
        };

        refreshApex(this.wiredMonthsDueDatePicklistValuesResult)
          .then(() => {
            this.refreshOrders();  
          });
    }

    @wire(getOrdersForAccountAndDueDateMonth, {
      accountId: "$selectedAccountId",
      dueDateMonth: "$selectedMonth"
    })
    wiredOrders( result ) {
        // TODO 
        console.log("wiredOrders()");
        this.wiredOrdersResult = result;
        if (result.data) {
          this.orders = result.data.map((order) => ({
                ...order,
                orderUrl: `/lightning/r/Order__c/${order.Id}/view`
            }));
            // TODO
            console.log("Orders from Apex:\n", JSON.stringify(this.orders))
        };
        if (result.error) {
          this.handleError(result.error); 
        } 
    }

    refreshOrders() {
        // TODO
        console.log("refreshOrders()");
        if (!this.selectedAccountId || !this.selectedMonth) {
            this.orders = [];
            return;
        }

        this._areOrdersLoading = true;

        refreshApex(this.wiredOrdersResult)
          .finally(() => {
            this._areOrdersLoading = false;
          });
    }

    refreshOrders2() { // TODO - duplicate of refreshOrders()
        // TODO
        console.log("refreshOrders2()");
        if (!this.selectedAccountId || !this.selectedMonth) {
            this.orders = [];
            return;
        }

        this._areOrdersLoading = true;
        getOrdersForAccountAndDueDateMonth({
            accountId: this.selectedAccountId,
            dueDateMonth: parseInt(this.selectedMonth, 10)
        })
        .then((data) => {
            // TODO: 
            this.orders = data.map((order) => ({
                ...order,
                orderUrl: `/lightning/r/Order__c/${order.Id}/view`
            }));
            // TODO
            console.log("Orders from Apex:\n", JSON.stringify(this.orders));
        })
        .catch((error) => {
            this.handleError(error); 
        })
        .finally(() => {
            this._areOrdersLoading = false;
        });
    }

    // --- ERROR HANDLING -----------------------------------------------------------------------------------------------
    handleError(error) {
        /* TODO */ console.log('handleError:', error);
        const errorMessage = reduceErrors(error).join(', ');
        /* TODO */ console.error('Error message:', errorMessage);
        const evt = new ShowToastEvent({
            title: "ERROR LOADING DATA",
            message: JSON.parse(errorMessage).message+'. '+ADMIN_CONTACT_MESSAGE,
            variant: "error", 
            mode: 'sticky'    
        });
        this.dispatchEvent(evt);
    }
        
    // --- LIFE CYCLE HOOKS ------------------------------------------------------------------------------------------------
    connectedCallback() {
        this.subscribeToCDC();
    }

    disconnectedCallback() {
        this.unsubscribeFromCDC();
    }

    // --- CDC service ------------------------------------------------------------------------------------------------
    _accountCDCSubscription = {};
    _orderCDCSubscription = {};

    subscribeToCDC() {
        const accountChannel = "/data/AccountChangeEvent";
        subscribe(accountChannel, -1, (message) => {
            // TODO
            console.log("Account change event received:", message);
            this.refreshAccounts();
        }).then((response) => {
            this.accountSubscription = response;
        });

        const orderChannel = "/data/Order__ChangeEvent";
        subscribe(orderChannel, -1, (message) => {
            // TODO
            console.log("Order__c change event received:", message);
            this.refreshMonthsAndOrders();
        }).then((response) => {
            this._orderCDCSubscription = response;
        });

        onError((error) => {
            // TODO
            console.error("CDC Error:", error);
        });
    }

    unsubscribeFromCDC() {
        if (this._accountCDCSubscription?.id) {
          unsubscribe(this._accountCDCSubscription, () => {});
        }
        if (this._orderCDCSubscription?.id) {
          unsubscribe(this._orderCDCSubscription, () => {});
        }
    }

}
