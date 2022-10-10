import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class createFlight extends LightningElement {
   @api recordId;
   @api objectApiName;
   @track showModal = false;
  
   handleClick(e){
      this.showModal = true;
   }
   handleSuccess(e) {
        this.showModal = false;
   }
}