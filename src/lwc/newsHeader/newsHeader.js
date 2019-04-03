import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class NewsHeader extends LightningElement {
    @api title;
    @api primaryControlArray;
    @api secondaryControlArray;
    @api breadcrumbsArray;
    @wire(CurrentPageReference) pageRef;

    handlePrimaryControl(event) {
        fireEvent(this.pageRef, 'headerPrimaryControlClick', event.target.dataset.label);
    }

    handleSecondaryControl(event) {
        fireEvent(this.pageRef, 'headerPrimaryControlClick', event.target.label);
    }
}