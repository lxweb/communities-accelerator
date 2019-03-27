import { LightningElement, track } from 'lwc';
import { loadStyle,loadScript } from 'lightning/platformResourceLoader';
import Assets from '@salesforce/resourceUrl/Assets';

export default class Banner extends LightningElement {

    @track position = 0;

    @track elements = [
        {
            id: 0,
            class: 'carousel-item active',
            indicatorClass: 'active',
            imgSrc: 'https://static.wixstatic.com/media/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.jpg/v1/fill/w_1184,h_564,al_c,q_85/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.webp',
            title: 'First slide label',
            description: 'Nulla vitae elit libero, a pharetra augue mollis interdum.'
        },
        {
            id: 1,
            class: 'carousel-item',
            indicatorClass: '',
            imgSrc: 'https://static.wixstatic.com/media/7d9c7e_ad976b831f4c40a9b131950fd1766fe8~mv2_d_4272_2436_s_4_2.jpg/v1/fill/w_950,h_728,al_c,q_85,usm_0.66_1.00_0.01/7d9c7e_ad976b831f4c40a9b131950fd1766fe8~mv2_d_4272_2436_s_4_2.webp',
            title: 'Second slide label',
            description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
        },
        {
            id: 2,
            class: 'carousel-item',
            indicatorClass: '',
            imgSrc: 'https://static.wixstatic.com/media/7d9c7e_96eab3aa358244db868d5971a30c57e4~mv2.jpg/v1/fill/w_1410,h_671,al_c,q_85/7d9c7e_96eab3aa358244db868d5971a30c57e4~mv2.webp',
            title: 'Third slide label',
            description: 'Praesent commodo cursus magna, vel scelerisque nisl consectetur.'
        },
    ]

    renderedCallback() {
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