import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { subscribe, MessageContext } from 'lightning/messageService';
import REFRESH_CHANNEL from '@salesforce/messageChannel/RefreshAccount__c';

export default class RefreshAccount extends LightningElement {
    @api recordId;
    wiredRecordResult;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    // Wykorzystujemy getRecord, aby uzyskać obiekt potrzebny do refreshApex
    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name'] }) 
    wiredRecord(result) {
        this.wiredRecordResult = result;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            // Subskrybujemy kanał
            this.subscription = subscribe(
                this.messageContext,
                REFRESH_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        // Ważne: Sprawdzamy, czy wiadomość dotyczy bieżącego rekordu
        if (message.recordId === this.recordId && this.wiredRecordResult) {
             console.log('Otrzymano sygnał odświeżania dla bieżącego rekordu.');
            refreshApex(this.wiredRecordResult)
                .then(() => {
                    console.log('Compact Layout zaktualizowany.');
                });
        }
    }
    
}