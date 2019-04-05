import { LightningElement, api, track } from 'lwc';

export default class Fe_DatatableLC extends LightningElement {
    @api table;

    @track orientation;
    @track columnsToShow;

    numberOfColumns = 8;

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
    }

    renderedCallback() {
        if(this.table && !this.columnsToShow) {
            this.columnsToShow = this.table.columns.slice(0, this.numberOfColumns);
        }
    }

    get columnClass() {
        return this.orientation ? "slds-col slds-size_2-of-4" : "slds-col slds-size_1-of-4";
    }

    get appliedFilters() {
        return (this.table.appliedFilters.length > 0) ? true : false;
    }

    handleOrientation() {
        //TRUE = Portrail  
        this.orientation = (screen.orientation.angle === 0) ? true : false;
    }

    openDetail() {
        console.log("hola");
    }

    editTable() {
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

    showFilter() {
        var button = this.template.querySelector("button.cancelSearch");
        var icon = this.template.querySelector("lightning-icon.filterIcon");
        button.style.display = "inline-block"; 
        icon.style.display = "inline-block"; 
    }

    openFilter() {
        var modal = this.template.querySelector("div.modal");
        var closeModal = this.template.querySelector("button.closeModal");
        modal.classList.toggle("open");
        closeModal.classList.remove("open");
    }

    filterActive(event) {
        var footer = this.template.querySelector("div.modal__footer");
        event.currentTarget.classList.toggle("active");
        footer.classList.remove("hidden")
    }

    filterRemove() {
        var button = this.template.querySelectorAll("button.active");
        var footer = this.template.querySelector("div.modal__footer");
        button.forEach(fil =>{
            fil.classList.remove("active");
        });
        footer.classList.toggle("hidden")
    }

    searchEvent() {
        const searchValue = new CustomEvent('search');
        this.dispatchEvent(searchValue);
    }

    filterEvent() {
        var button = this.template.querySelectorAll("button.active");
        var filters = [];
        var filter;
        button.forEach(fil =>{
            filter = {filter: {
                            name: fil.dataset.column, 
                            type: fil.dataset.type
                        },
                        value1: fil.dataset.value
                    };
            filters.push(filter);
        });
        const values = JSON.stringify(filters);
        const filterItemSelected = new CustomEvent('filter', { detail: {values}, });
        this.dispatchEvent(filterItemSelected);
        this.openFilter();
    }

    clearFilterEvent() {
        const clearFilter = new CustomEvent('clearfilter');
        this.dispatchEvent(clearFilter);
        this.filterRemove();
    }
}