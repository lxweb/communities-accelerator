import { LightningElement, api, track } from 'lwc';

export default class Fe_DatatableLC extends LightningElement {
    @api table;

    @track orientation;
    @track columnsToShow;

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
    }

    renderedCallback() {
        if(this.table && !this.columnsToShow) {
            this.columnsToShow = this.table.columns.slice(0, this.table.numberOfColumns);
        }
    }

    get columnClass() {
        return this.orientation ? "slds-col slds-size_2-of-4" : "slds-col slds-size_1-of-4";
    }

    handleOrientation() {    
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

    editTable(){
        var checkbox = this.template.querySelectorAll("div.checkbox");
        var edit = this.template.querySelector("p.edit-cancel");
        
        if (edit.innerText === "Edit") {
            checkbox.forEach(cb =>{
                cb.style.display = "block";
            })
            edit.innerText = "Cancel";
        }else {
            checkbox.forEach(cb =>{
                cb.style.display = "none";
            })
            edit.innerText = "Edit";
        }
    }

    searchEvent() {
        const searchValue = new CustomEvent('search');
        this.dispatchEvent(searchValue);
    }

    filterEvent(event) {
        const values = JSON.stringify({ 
            'name': event.currentTarget.dataset.column,
            'type': event.currentTarget.dataset.type, 
            'value': event.currentTarget.dataset.value});
        const filterItemSelected = new CustomEvent('filter', { detail: {values}, });
        this.dispatchEvent(filterItemSelected);
    }
}