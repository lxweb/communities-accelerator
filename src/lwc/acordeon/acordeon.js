import { LightningElement, api } from 'lwc';

export default class Acordeon extends LightningElement {

    @api filters;

    openAccordeon(event){
        var panel;
        event.target.classList.toggle("active");
        panel = event.target.nextElementSibling;
        if (panel.style.maxHeight){
            panel.style.maxHeight = null;
            panel.classList.toggle("active");
        } else {
            panel.style.maxHeight = panel.scrollHeight + "px";
            panel.classList.toggle("active");
        } 
    }

    acordeonRadioBtnSelected(event){
        var value = JSON.stringify({ 'value': event.currentTarget.value, 
        'accordeon': event.currentTarget.dataset.accordeon,
        'check': event.currentTarget.checked,
        'label': event.currentTarget.dataset.label});
        
        event.target.classList.toggle("active");

        this.eventDispatch(value);
        
    }

    acordeonCheckboxSelected(event){
        var value = JSON.stringify({ 
        'value': event.currentTarget.value, 
        'accordeon': event.currentTarget.dataset.accordeon,
        'check': event.currentTarget.checked,
        'label': event.currentTarget.dataset.label});
        
        event.target.classList.toggle("active");

        this.eventDispatch(value);
    }

    eventDispatch(value){
        const filterItemSelected = new CustomEvent('filterselected', {bubbles:"true",
        detail: {value}
        });
        this.dispatchEvent(filterItemSelected);
    }

    removeFilters(){
        var filters = JSON.parse(JSON.stringify(this.filters));
        filters.forEach(f => {
            f.values.forEach(a => {
                a.isSelected = false;

            })
        });
        this.filters = filters;
        this.eventDispatch(null);
    }
}