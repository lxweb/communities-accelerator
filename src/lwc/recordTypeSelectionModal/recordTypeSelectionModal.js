import { LightningElement, api, track, wire } from 'lwc';
import getObjectLabel from	'@salesforce/apex/ModalRecordTypeController.getObjectLabel';
import getRecordTypes from	'@salesforce/apex/ModalRecordTypeController.getRecordTypes';
import getNoRedirectRecordTypes from	'@salesforce/apex/ModalRecordTypeController.getNoRedirectRecordTypes';
import ModalRecordTypeTitle from '@salesforce/label/c.ModalRecordTypeTitle';
import General_Close from '@salesforce/label/c.General_Close';
import GeneralContents from '@salesforce/label/c.GeneralContents';
import StructureContent from '@salesforce/label/c.StructureContent';
import StructureContentDescription from '@salesforce/label/c.StructureContentDescription';
import General_Cancel from '@salesforce/label/c.General_Cancel';
import General_Next from '@salesforce/label/c.General_Next';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

export default class RecordTypeSelectionModal extends NavigationMixin(LightningElement) {

	@api objectapiname; //type="String"
	@api sObjectLabel; //type="String"
	@api rtDevNameList; //type="List"
	@api options; //type="List"
	@api option; //type="List"
	@api value; //type="String"
	
	@track modalRecordTypeTitle;
	@track generalClose;
	@track generalContents;
	@track structureContent;
	@track structureContentDescription;
	@track generalCancel;
	@track generalNext;

	//Reference used for the pubsub module
	@wire(CurrentPageReference) pageRef;

	constructor(){
		super();
		this.modalRecordTypeTitle = ModalRecordTypeTitle + ' ';
		this.generalClose = General_Close;
		this.generalContents = GeneralContents;
		this.structureContent = StructureContent;
		this.structureContentDescription = StructureContentDescription;
		this.generalCancel = General_Cancel;
		this.generalNext = General_Next;
	}

	connectedCallback() {
		registerListener('btnheaderlistviewclicked', this.handleClickBtnHeader, this);
	}

	disconnectedCallback() {
		unregisterAllListeners(this);
	}
	
	//Get object label from apex
	getObjectLbl(){
		getObjectLabel({ sObjectType: this.objectapiname})
			.then(result => {
				this.sObjectLabel = JSON.parse(JSON.stringify(result));
			})
			.catch( err => {
				console.log(err);
				this.sObjectLabel = null;
			});
	}

	//Get record types from apex
	getRecordType(){ 
		getRecordTypes({ sObjectType: this.objectapiname, recordTypes: this.rtDevNameList})
			.then(result => {
				var opt = [];
				var structureContent;
				this.options = JSON.parse(JSON.stringify(result));
				structureContent = {Id: 'structureContent',
														Name: "Structure Content", 
														Description: this.structureContentDescription};
				opt.push(structureContent);
				this.option = JSON.parse(JSON.stringify(opt));
			})
			.catch( err => {
				console.log(err);
				this.options = null;
				this.option = null;
			});
	}

	//Get Data of the component
	onInit(){
		this.value = null;
		this.deselectRadioButtons();
		this.getObjectLbl();
		this.getRecordType();
	}

	//Open and hide modal. If the modal is open this class close it, but if it close open it.
	showHideModal(){
		var cmpTarget = this.template.querySelector('section.modalbox2');
		var cmpBack = this.template.querySelector('div.divBackdrop2');

		cmpTarget.classList.toggle("slds-fade-in-open");
		cmpBack.classList.toggle("slds-backdrop_open");

	}

	onNewRecord(){
		this.goToNewRecord();
		this.showHideModal();
	}

	//Set attribute value when click on radio button option
	optionSelected(event){
		var recordTypeId = event.target.getAttribute("value");
		this.value = recordTypeId;
	}

	//Go to the new record page
	goToNewRecord(){	
		getNoRedirectRecordTypes({})
			.then(result => {
				var noRedirectRecordTypes = JSON.parse(JSON.stringify(result));
				if(this.value === "structureContent"){
					this.navigateToWebPage("/lightning/n/Sitemap");
				} else if(! noRedirectRecordTypes.includes(this.value)){
					this.navigateToWebPage("/lightning/n/NewContent?RecordTypeId=" + this.value);
				}
			})
			.catch( err => {
					console.log(err);
					this.noRedirectRecordTypes = null;
					this.value = null;
			});
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

	//Get if the button is disabled or not
	get isDisabled(){
		return this.value === null;
	}

	handleClickBtnHeader(){
		this.onInit();
		this.showHideModal();
	}

	deselectRadioButtons(){
		var inputs = this.template.querySelectorAll("input");

		inputs.forEach(element => {
			if(element.tagName === "INPUT" && element.type === "radio"){
				element.checked = false;
			}
	});
	}

}