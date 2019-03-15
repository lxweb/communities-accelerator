import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';


export default class TabFilter extends LightningElement {
    @api listtabfilter; //Change to @api when Parent Component asign value
    @track selectedTabIndex = null;
    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        registerListener('tabItemClick', this.onTabChange, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    //Fires on tab click and changes the selected tab index
    onTabChange(event) {
        this.selectedTabIndex = event.index.toString(); 
    }
}