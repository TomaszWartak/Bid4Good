import { LightningElement, track, wire } from "lwc";
import { subscribe, unsubscribe, onError } from "lightning/empApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import { reduceErrors } from 'c/errorUtils';

import ADMIN_CONTACT_MESSAGE from '@salesforce/label/c.Contact_system_administrator';
import getAccountsWithOrdersPicklistValues_Cacheable from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues_Cacheable";
import getAccountsWithOrdersPicklistValues from "@salesforce/apex/OrderCController.getAccountsWithOrdersPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues";
import getPaymentDueDateMonthsForAccountPicklistValues_Cacheable from "@salesforce/apex/OrderCController.getPaymentDueDateMonthsForAccountPicklistValues_Cacheable";
import getOrdersForAccountAndDueDateMonth from "@salesforce/apex/OrderCController.getOrdersForAccountAndDueDateMonth";

export default class OrderExplorer extends LightningElement {
  // API FOR LAYOUT ------------------------------------------------------------------------------------------------

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
    this._selectedMonth = null; 
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

  // --- for No Accounts with Orders message
  get _isAccountListEmpty() {
    return (
      !this._isAccountPicklistLoading &&
      (!this._accountsPicklistValues ||
        this._accountsPicklistValues.length === 0)
    );
  }

  // INTERNAL --------------------------------------------------------------------------------------------------------
  areOrdersLoading = false;

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
        this.handleError(error); 
    }
  }

  // TODO - wygląda podobnie do wiredAccounts
  refreshAccounts() {
    // TODO
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
            this.handleError(error); 
        });
  }

  @wire(getPaymentDueDateMonthsForAccountPicklistValues_Cacheable, {
    accountId: "$_selectedAccountId"
  })
  wiredMonths({ data, error }) {
    // TODO log
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
        this.handleError(error); 
    }
  }

    // TODO - wygląda podobnie do wiredMonths
    refreshMonthsAndOrders() {
        // TODO
        console.log("refreshMonthsAndOrders()");

        if (!this._selectedAccountId) {
            return;
        }
        getPaymentDueDateMonthsForAccountPicklistValues({
            accountId: this._selectedAccountId
        })
        .then((data) => {
            this._monthsDueDatePicklistValues = data;
            // TODO: console log - usunac pozniej
            console.log(
                "Months from Apex:\n",
                JSON.stringify(this._monthsDueDatePicklistValues)
            );
        })
        .catch((error) => {
            this.handleError(error); 
        })
            
        this.refreshOrders();
    }

    refreshOrders() {
        // TODO
        console.log("refreshOrders()");
        if (!this._selectedAccountId || !this._selectedMonth) {
        this._orders = [];
        return;
        }

        this.areOrdersLoading = true;
        getOrdersForAccountAndDueDateMonth({
            accountId: this._selectedAccountId,
            dueDateMonth: parseInt(this._selectedMonth, 10)
        })
        .then((data) => {
            // TODO: console log - usunac pozniej
            this._orders = data.map((order) => ({
            ...order,
            orderUrl: `/lightning/r/Order__c/${order.Id}/view`
            }));
            // TODO
            console.log("Orders from Apex:\n", JSON.stringify(this._orders));
        })
        .catch((error) => {
            this.handleError(error); 
        })
        .finally(() => {
            this.areOrdersLoading = false;
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
    accountSubscription = {};
    orderSubscription = {};

    subscribeToCDC() {
        // AccountChangeEvent
        const accountChannel = "/data/AccountChangeEvent";
        subscribe(accountChannel, -1, (message) => {
            // TODO
            console.log("Account change event received:", message);
            this.refreshAccounts();
        }).then((response) => {
            this.accountSubscription = response;
        });

        // Order__ChangeEvent
        const orderChannel = "/data/Order__ChangeEvent";
        subscribe(orderChannel, -1, (message) => {
            // TODO
            console.log("Order__c change event received:", message);
            // Wywołaj loadOrders() bezpośrednio po otrzymaniu zdarzenia
            // this.loadOrders();
            this.refreshMonthsAndOrders();
        }).then((response) => {
            this.orderSubscription = response;
        });

        onError((error) => {
            // TODO
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

}
