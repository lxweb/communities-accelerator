import { LightningElement, api, track } from 'lwc';

export default class RelatedCardList extends LightningElement {
    @api contents;
    @api type;
    @track orientation;

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
    }
    disconnectedCallback() {
        window.removeEventListener("orientationchange")
    }

    handleOrientation() {
        if(screen.orientation.angle === 0) {
            this.orientation = true
        } else {
            this.orientation = false;
        }
    }

    get columnWidth() {
        return this.orientation ? 'slds-col slds-size_4-of-4' : 'slds-col slds-size_2-of-4 column-spacer'
    }

    get typeWrapper() {
        return this.type.toLowerCase() + 's';
    }

}