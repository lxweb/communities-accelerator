import { LightningElement, api } from 'lwc';
import ContentLandingNew from '@salesforce/label/c.ContentLandingNew';
import ContentLandingTemplate from '@salesforce/label/c.ContentLandingTemplate';
import General_Search from '@salesforce/label/c.General_Search';

export default class HeaderListViewPage extends LightningElement {
    @api objectlabel; //Change to @api when Parent Component asign value
    @api filterselected;
    @api filtersstatus;

    label = {
        ContentLandingNew,
        ContentLandingTemplate,
        General_Search,
    };

    searchEnter(event) {
        if (event.which === 13 || event.keyCode === 13) {
            this.searchOnFocusOut(event);
        }
    }

    searchOnFocusOut(event){
        let value = JSON.stringify({ 
            'value': event.target.value
        });
        this.eventDispatch(value);
    }

    eventDispatch(value){
        const filterItemSelected = new CustomEvent('searchenter', {bubbles:"true",
        detail: {value}
        });
        this.dispatchEvent(filterItemSelected);
    }
}