import { LightningElement, api } from 'lwc';

export default class EventCard extends LightningElement {
    @api event;
    @api formatedEvent;
    constructor() {
        super();
    }
    renderedCallback() {
        if(this.event.content !== null && !this.formatedEvent) {
            this.formatedEvent = {
                headerText: this.event.content.EventStartDate__c,
                title: this.event.content.ListTitle__c,
                bodyText: this.event.content.ListDescription__c,
                imgSrc: this.event.mediaElements[0].FileURLDesktop__c,
                footer: {
                    description: {
                        descPrimary: this.event.content.Name,
                        descSecondary: this.event.content.Name,
                    },
                },
            }
            console.log(this.formatedEvent);
        }
    }
}