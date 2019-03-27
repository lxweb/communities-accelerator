import { LightningElement, track, api} from 'lwc';
import { loadStyle,loadScript } from 'lightning/platformResourceLoader';
import Assets from '@salesforce/resourceUrl/Assets';

export default class Banner extends LightningElement {

    @api bannerData;

    @track elements;
    @track position = 0;
    

    connectedCallback() {
        this.elements = this.bannerData.slice();
        loadStyle(this, Assets + '/Assets/Bootstrap/css/bootstrap.min.css')  
        loadScript(this, Assets + '/Assets/Bootstrap/js/bootstrap.min.js')
        loadScript(this, Assets + '/Assets/Bootstrap/js/popper.min.js')
        loadScript(this, Assets + '/Assets/Bootstrap/js/jquery-3.3.1.min.js')
    }

    next(){
        if(this.position < this.elements.length -1 ){ 
            this.elements[this.position].class = this.elements[this.position].class.replace(' active','');
            this.elements[this.position].indicatorClass = '';
            this.position++;
            this.elements[this.position].class = this.elements[this.position].class.concat(' active');
            this.elements[this.position].indicatorClass = 'active';
        }
    }

    previous(){
        if(this.position > 0){
            this.elements[this.position].class = this.elements[this.position].class.replace(' active','');  
            this.elements[this.position].indicatorClass = '';
            this.position--; 
            this.elements[this.position].class = this.elements[this.position].class.concat(' active');
            this.elements[this.position].indicatorClass = 'active';
        }
    }
}