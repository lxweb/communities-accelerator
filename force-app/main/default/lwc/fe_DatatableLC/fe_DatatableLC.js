import Assets from '@salesforce/resourceUrl/Assets';

import { LightningElement, api, track } from 'lwc';

export default class Fe_DatatableLC extends LightningElement {
    @api table;

    @track orientation;
    @track columnsToShow;
    @track showFilterModal = false;
    @track showFooterModal = false;
    @track showDetailModal = false;
    @track showActionModal = false;
    @track showCancelSearch = false;
    @track showFilterIcon = false;
    @track rowAction = [];
    @track globalAction = [];
    @track clickRow;

    numberOfColumns = 6;
    filterIcon = Assets + '/Assets/Icons/FilterIcon.svg';
    closeIcon = Assets + '/Assets/Icons/CloseIcon.svg';
    moreIcon = Assets + '/Assets/Icons/MoreIcon.svg';

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
    }

    renderedCallback() {
        if (this.table && !this.columnsToShow) {
            this.columnsToShow = this.table.columns.slice(0, this.numberOfColumns);
        }
        if (this.table.actions.length > 0 && this.rowAction.length === 0 && this.globalAction.length === 0) {
            this.typeActions();
        }
    }

    get columnClass() {
        return this.orientation ? "slds-col slds-size_2-of-4" : "slds-col slds-size_1-of-4";
    }

    get appliedFilters() {
        return (this.table.appliedFilters.length > 0) ? true : false;
    }

    get setDateFilter() {   
        var columns = JSON.parse(JSON.stringify(this.table.columns));
        var filterValues = ["Last Week", "Last Month", "Last Year", "Custom range"]; 
        columns.forEach(col => {
            if(col.filtrable && (col.type === "Date" || col.type === "datetime" || col.type === "Date/Time")) {
                col.filtrableValues = filterValues;
            }
        });
        return columns;
    }

    openFilterModal() {
        this.showFilterModal = true;
    }

    closeFilterModal() {
        this.showFilterModal = false;
    } 

    openDetailModal(event) {
        this.showDetailModal = true;
        this.clickRow = event.currentTarget.dataset.key;
    }

    closeDetailModal() {
        this.showDetailModal = false;
    }

    openActionModal() {
        this.showActionModal = true;
    }

    closeActionModal() {
        this.showActionModal = false;
        this.showDetailModal = false;
    }

    typeActions() {
        this.table.actions.forEach(act => {
            act.icon = Assets + '/Assets/Icons/' + act.icon +'.svg';
            if (act.recordType === "RowAction") {
                this.rowAction.push(act);
            } else {
                this.globalAction.push(act);
            }
        });
    }

    handleOrientation() {
        //TRUE = Portrail  
        this.orientation = (screen.orientation.angle === 0) ? true : false;
    }

    focusFilter() {
        this.showCancelSearch = true;
        this.showFilterIcon = true;
    }

    cancelFilter() {
        this.showCancelSearch = false;
        this.showFilterIcon = false;
    }

    deleteFilter(event) {
        var name = event.currentTarget.dataset.name;
        var value = event.currentTarget.dataset.value;
        var filters = JSON.parse(JSON.stringify(this.table));

        this.table.appliedFilters.forEach(fil => {
            if (fil.filter.name === name && fil.value1 === value) {
                filters.appliedFilters.splice(filters.appliedFilters.indexOf(fil), 1);
            }
        });
        this.table = filters;
        const values = JSON.stringify(filters.appliedFilters);
        this.filterEvent(values);
    }

    filterActive(event) {
        event.currentTarget.classList.toggle("active");
        this.showFooterModal = true;
    }

    filterRemove() {
        var button = this.template.querySelectorAll("button.active");
        var tableFooter = this.template.querySelector("div.table__footer");
        var filters = [];
        button.forEach(fil =>{
            fil.classList.remove("active");
        });
        if (this.table.appliedFilters.length > 0) {
            const values = JSON.stringify(filters);
            tableFooter.classList.toggle("hidden");
            this.filterEvent(values);
        }
        this.showFooterModal = false;
        this.showFilterIcon = false;
    }

    formatDate() {
        var today = new Date();
        var dates = [];
        dates = {
            now: today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0'),
            lastWeek: today.getFullYear() + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()-7).padStart(2, '0'),
            lastMonth: today.getFullYear() + '-' + String((today.getMonth()+1)-1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0'),
            lastYear: (today.getFullYear()-1) + '-' + String(today.getMonth()+1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0')
        };
        return dates;
    }

    dataFilter() {
        var button = this.template.querySelectorAll("button.active");
        var filters = [];   
        var filter;
        var dates = this.formatDate();
        var value1;
        var value2;
        button.forEach(fil =>{
            value1 = fil.dataset.value;
            value2 = null;
            if (fil.dataset.value === "Last Week") {
                value1 = dates.lastWeek;  //value1 = menor
                value2 = dates.now; //value2 = mayor
            } else if (fil.dataset.value === "Last Month") {
                    value1 = dates.lastMonth;
                    value2 = dates.now;
                } else if (fil.dataset.value === "Last Year") {
                        value1 = dates.lastYear;
                        value2 = dates.now;
                    }

            filter = {filter: {
                            name: fil.dataset.column, 
                            type: fil.dataset.type
                        },
                        value1: value1,
                        value2: value2
                    };
            filters.push(filter);
        });
        const values = JSON.stringify(filters);
        this.filterEvent(values);
        this.closeFilterModal();
        this.showCancelSearch = false;
    }

    filterEvent(values) {
        const filterItemSelected = new CustomEvent('filter', { detail: {values}, });
        this.dispatchEvent(filterItemSelected);
    }

    rowActionEvent(event) {
        var actions = [];   
        var action = { recordId: event.target.id,
                       componentName: event.target.component,
                       showAsModal: event.target.modal
                     };
        actions.push(action);
        const values = JSON.stringify(actions);
        const actionValue = new CustomEvent('action', { detail: {values}, });
        this.dispatchEvent(actionValue);
    }

    searchEvent(event) {
        const values = event.target.value;
        const searchValue = new CustomEvent('search', { detail: {values}, });
        this.dispatchEvent(searchValue);
    }

    clearFilterEvent() {
        const clearFilter = new CustomEvent('clearfilter');
        this.dispatchEvent(clearFilter);
        this.filterRemove();
    }
}