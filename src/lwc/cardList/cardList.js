import { LightningElement, api } from 'lwc';

export default class CardList extends LightningElement {
    @api contents;
    @api type;
}