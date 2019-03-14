import { LightningElement, api } from 'lwc';

export default class Card extends LightningElement {
    @api config; 
    //{ headerText:string,
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

}