import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import Style from '@salesforce/resourceUrl/Assets';

export default class CardDetail extends LightningElement {

    @api details = {
        type: 'Event',
        date: '7 Mar 2019',
        location: {
            name: 'Jose Ingenieros 2708, B.',
            href: 'https://www.google.com/maps/place/Jos%C3%A9+Ingenieros+2708,+B1643FRB+B%C3%A9ccar,+Buenos+Aires/@-34.473879,-58.5556469,17z/data=!3m1!4b1!4m5!3m4!1s0x95bcb0076e49a839:0xe1d0535502f7e572!8m2!3d-34.473879!4d-58.5534582'
        },
        title: 'Duis porta, ligula rhoncus euismod pretium.',
        imgSrc: 'https://static.wixstatic.com/media/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.jpg/v1/fill/w_1184,h_564,al_c,q_85/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.webp',
        body: 
        `<p>
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        </p>
        <div class="banner-img-container">
            <img class="banner-img" src="https://static.wixstatic.com/media/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.jpg/v1/fill/w_1184,h_564,al_c,q_85/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.webp" alt="Banner Image">
        </div>
        <p>
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        </p>
        <div class="banner-img-container">
            <img class="banner-img" src="https://static.wixstatic.com/media/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.jpg/v1/fill/w_1184,h_564,al_c,q_85/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.webp" alt="Banner Image">
        </div>
        <p>
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        </p>
        <p>
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        </p>
        <div class="banner-img-container">
            <img class="banner-img" src="https://static.wixstatic.com/media/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.jpg/v1/fill/w_1184,h_564,al_c,q_85/7d9c7e_7e0a396900a442b48964e226cbe76717~mv2.webp" alt="Banner Image">
        </div>`
    }

    // Best practice to know if the device is mobile.
    mobile = navigator.userAgent.toLowerCase().includes('mobi');

    renderedCallback() {
        loadStyle(this, Style + '/Assets/Styles/cardDetailExternalStyle.css')   
        loadStyle(this, Style + '/Assets/Styles/roboto.css') 
    }

    get isMobile() {
        return this.mobile ? 'mobile' : '';
    }

    get isEvent() {
        return this.details.type === 'Event';
    }

    get eventClass() {
        return this.isEvent ? 'date-container event' : 'date-container';
    }
}