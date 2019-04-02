import { LightningElement, api, track, wire } from 'lwc';
import generalCancel from '@salesforce/label/c.General_Cancel';
import generalClose from '@salesforce/label/c.General_Close';
import saveAndNext from '@salesforce/label/c.SaveAndNext';
import recordName from '@salesforce/label/c.ContentNameInput';
import contentCreateLabel from '@salesforce/label/c.Create';
import errorMessageLabel from '@salesforce/label/c.NewContentErrorMessage';
import templateLabel from '@salesforce/label/c.Template';
import requiredFieldMessage from '@salesforce/label/c.RequiredField';
import getRecordTypeName from '@salesforce/apex/CreateNewContentModalController.getRecordTypeName';
import createNewContent from '@salesforce/apex/CreateNewContentModalController.createNewContent';

import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


export default class RecordTypeSelectionModal extends NavigationMixin(LightningElement) {

    @api recordTypeId; //type="String"
    @api isTemplate; //type="Boolean"
    @api componentId; //type="String"
    @api navigationId; //type="String"
    @api salesforceDomain; //type="String"

    @track recordTypeLabel;
    @track contentCreateLabel;
    @track errorMessageLabel;
    @track templateLabel;
    @track modalTitle;
    @track requiredFieldMessage;
    @track isDisabled;

    recordNameValue;

    label = {
        generalCancel,
        saveAndNext,
        generalClose,
        recordName
    };

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    @api
    show() {
        this.showHideModal();
        this.getRecordTypeName();
    }

    constructor(){
        super();
        this.contentCreateLabel = contentCreateLabel;
        this.templateLabel = templateLabel;
        this.errorMessageLabel = errorMessageLabel;
        this.requiredFieldMessage = requiredFieldMessage;
        this.recordNameValue = null;
    }

    connectedCallback() {
        registerListener('btncreatecontentclicked', this.handleClickBtnHeader, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //Handle event dispatched by other component and open modal.
    handleClickBtnHeader(event){
        this.recordTypeId = event.recordTypeId;
        this.isTemplate = event.isTemplate;
        this.componentId = event.componentId;
        this.navigationId = event.navigationId;
        this.onInit();
        this.showHideModal();
    }

    //Get Data of the component
    onInit(){
        this.getRecordTypeName();
    }

    //Get record type name from apex
    getRecordTypeName(){ 
        getRecordTypeName({ recordTypeId: this.recordTypeId})
            .then(result => {
                this.recordTypeLabel = result;
                this.assignTitle();
            })
            .catch( err => {
                console.log(err);
                this.recordTypeLabel = '';
                this.assignTitle();
            });
    }

    //Sets the modal title.
    assignTitle(){
        this.modalTitle = this.contentCreateLabel + ' ' + this.recordTypeLabel;
        if(this.isTemplate){
            this.modalTitle += ' ' + this.templateLabel;
        }
    }

    //Open and hide modal. If the modal is open this class close it, but if it close open it.
    showHideModal(){
        var cmpTarget = this.template.querySelector('section.modalbox3');
        var cmpBack = this.template.querySelector('div.divBackdrop3');
       
        this.isDisabled = true;
        this.recordNameValue = null;

        cmpTarget.classList.toggle("slds-fade-in-open");
        cmpBack.classList.toggle("slds-backdrop_open");

    }

    //If input is not null, creates the record. Else error is returned.
    onNewRecord(){
        if(this.recordNameValue){
            this.setRecord();
        }else{
            this.errorMessage = this.requiredFieldMessage;
            this.showToast();
        }
    }

    //Create the record.
    setRecord(){
        var contentModal = this;
        createNewContent({ recordTypeId: this.recordTypeId, isTemplate : this.isTemplate, structureComponent :  this.componentId, structureNavigation : this.navigationId, recordName : this.recordNameValue})
            .then(result => {
                this.result = JSON.parse(JSON.stringify(result));
                if(result.isSuccess){
                    this.showHideModal();
                    if(contentModal.salesforceDomain == null){
                        this.navigateToWebPage("/" + this.result.message);
                    } else {
                        contentModal.dispatchEvent(new CustomEvent('contentcreated', {detail: { recordId: this.result.message }}));
                    }
                }else{
                    this.errorMessage = this.result.message;
            this.showToast();
                }
            })
            .catch( err => {
                console.log(err);
                this.errorMessage = this.errorMessageLabel;
                this.showToast();
            });
    }

    //Navigates to URL
    navigateToWebPage(url) {
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
        });
    }

    //Sets value of the input to the var.
    setValue(event){
        this.recordNameValue = event.target.value;
        this.isDisabled = false;
    }

    //Sets value of the input to the var.
    setValueBlur(event){
        this.recordNameValue = event.target.value;
        if(this.recordNameValue){
            this.isDisabled = true;
        }else{
            this.isDisabled = false;
        }
    }

    //Open toast with a message
    showToast() {
        const event = new ShowToastEvent({
            message: this.errorMessage,
            variant: "error",
            mode: "sticky"
        });
        this.dispatchEvent(event);
    }

}
