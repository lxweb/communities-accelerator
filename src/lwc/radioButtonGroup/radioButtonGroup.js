import { LightningElement, api, track } from 'lwc';

export default class RadioButtonGroup extends LightningElement {
    @api options;
    @api cmptitle;
    @api cmpname;
    
    @track defaultvalue;

    radioBtnGroupSelected(event){
        var child = event.currentTarget.childNodes[0];
        
        if(child.tagName === "INPUT"){
            child.checked = true;
            this.defaultvalue = child.getAttribute("value");
        }

        const radioButtonGroupSelected = new CustomEvent('radiobuttongroupselected', {
        detail: this.defaultvalue
        });
        this.dispatchEvent(radioButtonGroupSelected);
        
    }

}