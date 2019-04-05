import { LightningElement, api, wire, track } from 'lwc';
import getFilters from	'@salesforce/apex/ContentSearchFiltersController.getFilters';
import getObjectLabel from	'@salesforce/apex/ContentLandingHeaderController.getObjectLabel';
import getPicklistValues from	'@salesforce/apex/ContentLandingHeaderController.getPicklistValues';
import getTableWrapper from	'@salesforce/apex/ContentLandingRecordListController.getTableWrapper';
import getUpdatedTableWrapper from	'@salesforce/apex/ContentLandingRecordListController.getUpdatedTableWrapper';
import deleteContent from	'@salesforce/apex/ContentLandingRecordListController.deleteContent';
import createFromTemplate from	'@salesforce/apex/ContentUtils.createFromTemplate';
import ContentLandingAll from '@salesforce/label/c.ContentLandingAll';
import ContentLandingNone from '@salesforce/label/c.ContentLandingNone';
import ContentLandingContentType from '@salesforce/label/c.ContentLandingContentType';
import ContentLandingCluster from '@salesforce/label/c.ContentLandingCluster';
import ContentLandingCategory from '@salesforce/label/c.ContentLandingCategory';
import ContentLandingTags from '@salesforce/label/c.ContentLandingTags';
import SidebarFilterTitle from '@salesforce/label/c.SidebarFilterTitle';
import ContentLandingNew from '@salesforce/label/c.ContentLandingNew';
import ContentLandingTemplate from '@salesforce/label/c.ContentLandingTemplate';
import TemplateLabel from '@salesforce/label/c.Template';
import ContentDetailContent from '@salesforce/label/c.ContentDetailContent';
import General_Error from '@salesforce/label/c.General_Error';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class ContentContainer extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api filtersValues;
    @api tabledata;
    @api headerButtonsPrimary;
    @api headerButtonsSecondary;
    @api optionsFilterRadioButtonGroup;

    @api reloadTable(){
        this.tableDataDelete(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }
    
    @track renderHeader;
    @track renderFilterSidebar;
    @track renderTable;
    @track SidebarFilterTitle;
    
    filters;
    filtersStatus;
    objectLabel;
    haveObjectLabel;
    haveFilterStatus;
    statusValue;
    searchInputValue;
    contentTypeValue;
    radioButtonGroupValue;
    lblContent;

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    // Get Sidebar filters from APEX CLASS
    @wire(getFilters, { sObjectType: '$objectApiName' })
    wiredFilters({ error, data }) {
        if (error) {
            this.filters = null
            this.setRenderFilterSidebar(false);
            console.log(error);
        } else if (data) {
            this.filters = JSON.parse(JSON.stringify(data.filters));
            this.adaptDataFilters();
            this.setRenderFilterSidebar(true);
        }
    }

    // Get Object Label from APEX CLASS
    @wire(getObjectLabel, { sObjectType: '$objectApiName' })
    wiredObjectLabel({ error, data }) {
        if (error) {
            this.objectLabel = null;
            this.haveObjectLabel = false;
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
            console.log(error);
        } else if (data) {
            this.objectLabel = data;
            this.haveObjectLabel = true;
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
        }
    }

    // Get Status filters from APEX CLASS
    @wire(getPicklistValues, { sObjectType: '$objectApiName', fieldApiName:"Status__c"})
    wiredFilterStatus({ error, data }) {
        if (error) {
            this.filtersStatus = null;
            this.haveFilterStatus = false;
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
            console.log(error);
        } else if (data) {
            this.filtersStatus = JSON.parse(JSON.stringify(data));
            this.haveFilterStatus = true;
            this.adaptDataStatus();
            this.setRenderHeader(this.haveFilterStatus && this.haveObjectLabel);
        }
    }

    // Get data of the table from APEX CLASS
    @wire(getTableWrapper, { contentTypeId: null, clusterId: null, categoryId: null, tagIds: null, status: ContentLandingAll, searchText: null,isTemplate: false })
    wiredTableData({ error, data }) {
        if (error) {
            this.tabledata = null;
            this.setRenderTable(false);
            console.log(error);
        } else if (data) {
            this.tabledata = JSON.parse(data);
            // this.haveTableData = true;
            this.setRenderTable(true);
        }
    }

    constructor() {
        super();
        this.statusValue = ContentLandingAll;
        this.searchInputValue = null;
        this.radioButtonGroupValue = false;
        this.filtersValues = 
        [ 
            {label: ContentLandingCluster, value: null, id: null},
            {label: ContentLandingCategory, value: null, id: null},
            {label: ContentLandingTags, value: null, id: null},
        ];
        this.SidebarFilterTitle = SidebarFilterTitle;
        this.headerButtonsPrimary = [
            {
                type: 'primary',
                label: ContentLandingNew,
                labelAlternative: null,
                action: 'handleOnClick',
                typeAction: 'dispatchEvent',
                show: true
            }
        ]
        this.headerButtonsSecondary = [
            {
                type: 'secondary',
                label: ContentLandingTemplate,
                labelAlternative: null,
                action: 'handleOnClickCreateTemplate',
                typeAction: 'dispatchEvent',
                show: true
            }
        ];
        this.lblContent = ContentDetailContent.charAt(0) + ContentDetailContent.slice(1).toLowerCase();
        this.optionsFilterRadioButtonGroup = [
            { name: "filterRadio", label: this.lblContent, value: false, checked: true },
            { name: "filterRadio", label: TemplateLabel, value: true, checked: false },
        ];
    }

    connectedCallback() {
        registerListener('tabItemClick', this.handleTabChange, this);
    }

    //Delete all pubsub events
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //Set var to indicate if the header component can render or not
    setRenderHeader(bool){
        this.renderHeader = bool;
    }

    //Set var to indicate if the filter sidebar component can render or not
    setRenderFilterSidebar(bool){
        this.renderFilterSidebar = bool;
    }

    //Set var to indicate if the table component can render or not
    setRenderTable(bool){
        this.renderTable = bool;
    }

    adaptDataStatus(){
        this.filtersStatus.forEach(element => {
            if (element.defaultValue === "true"){
                element.defaultValue = "false";
            }
        });
        this.filtersStatus = [{"defaultValue": "true", "label": ContentLandingAll, "value": ContentLandingAll}, ...this.filtersStatus];
    }

    adaptDataFilters(){
        this.filters.forEach(element => {
            if (!element.isMultiPicklist){
                element.values = [{"id": ContentLandingNone, "isSelected": false, "label": ContentLandingNone}, ...element.values];
            }
        });
    }

    //Change value of sidebar filter when is selected
    filterMap(currentFilters, ContentLanding, value, multipleSelection) {        
        var filtersValue = currentFilters.map(element => {
             if(element.label === ContentLanding){
                if(multipleSelection){
                    if(value.check) {
                       if(!element.value){
                           element.value = value.label;
                           element.id = value.value;
                       } else {
                           let values = element.value.split(', ');
                           let ids = element.id.split(', ');
                           values.push(value.label);
                           ids.push(value.value);
                           element.value = values.join(', ');
                           element.id = ids.join(', ');
                       }
                    }else{
                        let values = element.value.split(', ');
                        let ids = element.id.split(', ');
                        if(values.length < 2){
                            element.value = null;
                            element.id = null;
                        } else {
                            ids.splice(ids.findIndex(x => x === value.value),1);
                            values.splice(values.findIndex(x => x === value.label),1);
                            element.value = values.join(', ');
                            element.id = ids.join(', ');
                        }
                    }
                }else{
                    if(value.label === ContentLandingNone){
                        element.value = null;
                        element.id = null;
                    }else{
                        element.value = value.label;
                        element.id = value.value;
                    }
                }
            }
            return element;
        });
        this.filtersValues = filtersValue;
    }

    //Handler sidebar events
    handlerFilterSidebarEvent(event){
        var value = JSON.parse(JSON.parse(JSON.stringify(event.detail)).value);
        var filters = JSON.parse(JSON.stringify(this.filtersValues));
        if(value){
            switch (value.accordeon) {
                case ContentLandingCluster:
                this.filterMap(filters, ContentLandingCluster, value, false);
                // Get data of the table from APEX CLASS
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                case ContentLandingContentType:
                    if(value.value === ContentLandingNone){
                            this.contentTypeValue = null;
                    }else{
                            this.contentTypeValue = value.value;
                    }
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                case 'Categories':
                this.filterMap(filters, ContentLandingCategory, value, false);
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                case ContentLandingTags:
                this.filterMap(filters, ContentLandingTags, value, true);
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
                break;
                default:
                this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
            }
            this.filtersValues = filters;
        }else {
            this.contentTypeValue = null;
            this.filtersValues = 
            [ 
                {label: ContentLandingCluster, value: null, id: null},
                {label: ContentLandingCategory, value: null, id: null},
                {label: ContentLandingTags, value: null, id: null},
            ];
           this.tableDataFilter();
        }
    }

    //Handler Status events
    handleTabChange(event) {
        this.statusValue = event.tab.label;
        this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }

    onSearchEvent(event){
        var value = JSON.parse(JSON.parse(JSON.stringify(event.detail)).value).value;
        this.searchInputValue = value === '' ? null : value;
        this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }


    tableDataFilter(clusterId, categoryId, tagIds){
        this.setRenderTable(false);
        getTableWrapper({ contentTypeId: this.contentTypeValue, clusterId: clusterId, categoryId: categoryId , tagIds: tagIds, status: this.statusValue, searchText: this.searchInputValue,isTemplate: this.radioButtonGroupValue })
            .then(result => {
                this.tabledata = JSON.parse(result);
                this.setRenderTable(true);
            })
            .catch( err => {
                console.log(err);
                this.tabledata = null;
                this.setRenderTable(false);
            });
    }

    tableDataDelete(clusterId, categoryId, tagIds){
        this.setRenderTable(false);
        getUpdatedTableWrapper({ contentTypeId: this.contentTypeValue, clusterId: clusterId, categoryId: categoryId , tagIds: tagIds, status: this.statusValue, searchText: this.searchInputValue,isTemplate: this.radioButtonGroupValue })
            .then(result => {
                this.tabledata = JSON.parse(result);
                this.setRenderTable(true);
            })
            .catch( err => {
                console.log(err);
                this.tabledata = null;
                this.setRenderTable(false);
            });
    }

    handleDeleteContent(event){
        var idContent = event.detail;
        event.stopPropagation();
        deleteContent({ contentId: idContent})
            .then(result => {
                this.tableDataDelete(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
            })
            .catch( err => {
                console.log(err);
            });
    }

    handleCreateContent(event){
        var idContent = event.detail;
        event.stopPropagation();
        createFromTemplate({ templateId: idContent})
            .then(result => {
                this.navigateToWebPage("/" + result); //result = recordId
            })
            .catch( err => {
                console.log(err);
                if(err.body.message){
                    this.showToast(General_Error,err.body.message,'error');
                }
            });
    }

    handleRadioButtonGroupEvent(event){
        this.radioButtonGroupValue = event.detail;
        this.tableDataFilter(this.filtersValues[0].id, this.filtersValues[1].id, this.filtersValues[2].id);
    }  

    navigateToWebPage(url) {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }

     //Open toast with a message
     showToast(toastTitle,toastMessage,toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
            mode: (toastVariant === "success") ? 'dismissable' : 'sticky'
        });
        this.dispatchEvent(event);
    }
}