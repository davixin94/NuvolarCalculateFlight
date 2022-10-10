import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCodes from '@salesforce/apex/flightCalculator.getAvailableAirports';
import getDistance from '@salesforce/apex/flightCalculator.calculateFlight';
import saveFlight from '@salesforce/apex/flightCalculator.saveFlight';

export default class createFlightComponent extends LightningElement {
   @api recordId;
   @api objectApiName;
   @track showModal = false;
   @track showModalConfirmation = false;

   @track listAirports = [];

   departure = '';
   arrival = '';
   departureLabel = '';
   arrivalLabel = '';
   finalDistance = 0.0;
  
   handleClick(e){
    getCodes({}).then(list => {
        if(list){
            let mapAirPorts = new Map(Object.entries(list));
            for (let[key, value] of mapAirPorts){
                this.listAirports = [...this.listAirports,
                {value: key, label: value}]
            }
        }
    })
    this.showModal = true;
   }

   saveFlight(){
    getDistance({departure: this.departure, arrival: this.arrival}).then(distance =>{
        if(distance != 0.0){
            this.finalDistance = distance;
        }
    })
    this.showModal = false;
    this.showModalConfirmation = true; 
   }

   confirmFlight(){
    saveFlight({departure: this.departure, arrival: this.arrival, distance: this.finalDistance});
    this.showModalConfirmation = false;
   }
   handleCancel(e) {
        this.showModal = false;
        this.showModalConfirmation = false;
   }

   setDeparture(e){
    this.departure = e.detail.value;
    this.departureLabel = e.target.options.find(opt => opt.value === e.detail.value).label;
   }
   setArrival(e){
    this.arrival = e.detail.value;
    this.arrivalLabel = e.target.options.find(opt => opt.value === e.detail.value).label;
   }
}