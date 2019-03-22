import { LightningElement, api, track } from 'lwc';

export default class Card extends LightningElement {
    @api config; 
    //{id:string ,
    // type:sting,
    // headerText:string,
    // title:string,
    // bodyText:string,
    // imgSrc:string,
    // footer: { 
    //  description: { 
    //           descPrimary:string,
    //           descSecondary:string
    //       },
    //  controls: [{ label:string, action:string, icon:boolean }]
    //  }
    //}
    @api variant;
    @track orientation;

    constructor() {
        super();
        this.handleOrientation();
    }

    connectedCallback() {
        window.addEventListener("orientationchange", () => this.handleOrientation());
    }

    handleOrientation() {
        if(screen.orientation.angle === 0) {
            this.orientation = true
        } else {
            this.orientation = false;
        }
    }

    get isEvent() {
        return this.config.type === 'Event'
    }

    get headerClass() {
        return this.config.type === 'Event'? 'header head-event' : 'header head-news'; 
    }

    get primaryDescClass() {
        return this.config.type === 'Event'? 'desc-normal' : 'desc-highlight'; 
    }

    get secondaryDescClass() {
        return this.config.type === 'Event'? 'desc-highlight' : 'desc-normal'; 
    }

}