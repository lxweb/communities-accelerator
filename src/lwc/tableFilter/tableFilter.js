import { LightningElement, api,track,wire } from 'lwc';
import ShowMore from '@salesforce/label/c.ShowMore';
import GeneralDelete from '@salesforce/label/c.General_Delete';
import GeneralView from '@salesforce/label/c.General_View';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';

export default class TableFilter extends NavigationMixin(LightningElement) {
    @api tabledata; //Change to @api when Parent Component asign value

    @track showMore;

    viewLbl;
    deleteLbl;

    @wire(CurrentPageReference) pageRef;

    constructor(){
        super();
        this.showMore = ShowMore;
        this.viewLbl = GeneralView;
        this.deleteLbl = GeneralDelete;
    }

    showActions(event){
        event.currentTarget.parentElement.classList.toggle("slds-is-open");
    }

    hideActions(){
        var divOpen = this.template.querySelector('div.divAction.slds-is-open');
        divOpen.classList.toggle("slds-is-open");
    }

    handleClick(event){
        var child = event.currentTarget.children[0];
        var label;
        var id;
        
        this.hideActions();

		if(child){
            if(child.tagName === "SPAN"){
                label = child.dataset.label;
                id = child.dataset.id;
            }
		}

        switch (label) {
            case this.viewLbl:
                this.navigateToWebPage("/" + id);
                break;
            case this.deleteLbl:
                this.deleteContent(id);
                break;
            default:
        }
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

    deleteContent(idContent){
        var value = idContent;
        const deleteContentRecord = new CustomEvent('deletecontentrecord', {bubbles:"true",
        detail: value
        });
        this.dispatchEvent(deleteContentRecord);
    }
        
}