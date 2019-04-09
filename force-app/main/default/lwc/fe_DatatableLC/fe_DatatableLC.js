import { LightningElement, api, track } from 'lwc';

export default class Fe_DatatableLC extends LightningElement {
    @api table;

    @track orientation;

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
    }

    get columnClass(){
        return this.orientation ? "slds-col slds-size_2-of-4" : "slds-col slds-size_1-of-4";
    }

    handleOrientation(){    
        if (screen.orientation.angle === 0){
            this.orientation = true;            //Portrail
        }
        else{
            this.orientation = false;   
        }
    }

    openDetail(){
        console.log("hola");
    }

    filterEvent(event){
        const values = JSON.stringify({ 
            'name': event.currentTarget.dataset.column,
            'type': event.currentTarget.dataset.type, 
            'value': event.currentTarget.dataset.value});
        const filterItemSelected = new CustomEvent('filter', { detail: {values}, });
        this.dispatchEvent(filterItemSelected);
    }
}