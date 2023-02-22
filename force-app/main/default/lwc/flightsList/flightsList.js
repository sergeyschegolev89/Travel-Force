import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import getAvailableFligths from '@salesforce/apex/FligthsListController.getAvailableFligths';
import bookTicket from '@salesforce/apex/FligthsListController.bookTicket';
import ID_FIELD from '@salesforce/schema/Trip__c.Id';
import FLIGHT_FIELD from '@salesforce/schema/Trip__c.Flight__c';
import CONTACT_FIELD from '@salesforce/schema/Trip__c.Contact__c';
import PREFERRED_DATE from '@salesforce/schema/Trip__c.Preferred_trip_start__c';

const columns = [
    { 
        label: 'Flight Number', 
        fieldName: 'Name' 
    },
    {   
        label: 'Start', 
        fieldName: 'Start__c', 
        type:'date', 
        typeAttributes: {
            year: "numeric",
            month: "long",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        }
    },
    {  
        type: 'action', 
        typeAttributes: {
            rowActions: [{
                label: 'Select',
                name: 'select'
            }],
        },
    },
];

export default class FlightsList extends LightningElement {
    @api recordId;
    @track trip;
    columns = columns;
    load = false;
    preferreddate;

    @wire(getRecord, { recordId: '$recordId', fields: [ ID_FIELD, FLIGHT_FIELD, PREFERRED_DATE , CONTACT_FIELD] })
    tripRecord({ data, error }) {
        if (data) {
            this.trip = data;
            this.preferreddate = data.fields.Preferred_trip_start__c.value;
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error));
        }
    }
    

    @wire(getAvailableFligths,{ preferreddate: '$preferreddate' })
    flightsList;
    
    get flights() {
        return this.flightsList.data;
    }

    get loading() {
        return !this.flightsList.data || this.load;
    }

    get isEmptyList() {
        return this.flightsList.data && !this.flightsList.data.length;
    }

    async handleRowAction(event) {
        const row = event.detail.row;       
        if (getFieldValue(this.trip, FLIGHT_FIELD)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: `Ticket for this Trip has already been booked. To change or cancel booking please contact System Administrator`,
                    variant: 'warning'
                })
            );
            return;
        }
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[FLIGHT_FIELD.fieldApiName] = row.Id;
        const recordInput = { fields };
        try {
            this.load = true;
            const result = await bookTicket({ 
                contactId: getFieldValue(this.trip, CONTACT_FIELD), 
                flightId: row.Id 
            })
            if (result === 'Success') {
                await updateRecord(recordInput)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `Ticket for the Flight ${row.Name} has been successfully booked`,
                        variant: 'success'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: result,
                        variant: 'error'
                    })
                );
            }
        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        } finally {
            this.load = false;
        }
    }
}