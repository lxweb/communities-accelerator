import { LightningElement, api } from 'lwc';
import { formatContent } from 'c/contentFormatter'

export default class CardHoc extends LightningElement {
    @api content;
    @api formatedContent;
    @api type;
   
    renderedCallback() {
        if(!this.formatedContent){
            this.formatedContent = formatContent(this.content, this.type);
        }
    }
}