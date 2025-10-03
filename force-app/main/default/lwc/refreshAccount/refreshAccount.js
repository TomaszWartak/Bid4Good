import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { subscribe, onError } from 'lightning/empApi';

export default class RefreshAccount extends LightningElement {
    @api recordId;
    wiredRecordResult;

    accountCDCSubscription = {};

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name'] }) 
    wiredRecord(result) {
        this.wiredRecordResult = result;
    }

    // --- LIFE CYCLE HOOKS ------------------------------------------------------------------------------------------------
    connectedCallback() {
        this.subscribeToCDC();
    }

    disconnectedCallback() {
        this.unsubscribeFromCDC();
    }

    // --- CDC service ------------------------------------------------------------------------------------------------

    subscribeToCDC() {
        // TODO
        console.log('Subskrypcja do kanału AccountChangeEvent - ON');
        const accountChannel = "/data/AccountChangeEvent";
        const messageCallback = (response) => {
            console.log("Account change event received:", response );

            const eventPayload = response.data.payload;
            const changedFields = eventPayload.ChangeEventHeader.changedFields;
            const recordIds = eventPayload.ChangeEventHeader.recordIds; 
            const eventAppliesToThisRecord = recordIds.includes(this.recordId);
            const targetFieldChanged = changedFields.includes('Total_Orders_Number__c');
            
            if (eventAppliesToThisRecord && targetFieldChanged && this.wiredRecordResult) {
                // TODO
                console.log('Walidacja OK. Pole Total_Orders_Number__c zostało zmienione dla bieżącego rekordu. Wywolywanie refreshApex.');
                refreshApex(this.wiredRecordResult)
                    .then(() => {
                        // TODO
                        console.log('Compact Layout zaktualizowany przez CDC Account.');
                    });
            }
        };
        subscribe( 
            accountChannel, 
            -1, 
            messageCallback
        ).then((response) => {
            this.accountCDCSubscription = response;
        });

        onError((error) => {
            // TODO
            console.error("CDC Error:", error);
        });
    }

    unsubscribeFromCDC() {
        if (this.accountCDCSubscription?.id) {
            // TODO
            console.log('Subskrypcja do kanału AccountChangeEvent - OFF');
            unsubscribe( this.accountCDCSubscription, () => {});
        }
    }
}