import { LightningElement,  api } from 'lwc';
export default class CustomRichText extends LightningElement {
   

 
    @api handleReceiveUrl(URL){
        // Receive URL from Lightning Component (container).
        var Rich = this.template.querySelector('lightning-input-rich-text');
        var newValue = Rich.value += '<img src="' + URL + '" >'; //Concatenate URL into current text.
        Rich.value = newValue;
       
    }
    
      handleTextChange(event){   //On RichText change, clone text from RichText to AreaText in HTML Format.
        var textArea = this.template.querySelector('textarea');
        textArea.value  = event.detail.value;
    }

    handleAreaText(){ //On TextArea change, clone text from TextArea to RichText in plain text format.
        var Rich = this.template.querySelector('lightning-input-rich-text');
        var textArea = this.template.querySelector('textarea');
        Rich.value = textArea.value;        
    }


    displaySource(){ //Display TextArea, hide RichText.
        var divRich = this.template.querySelector('div.rich');
        var divSource = this.template.querySelector('div.source');
        divRich.style.display="none";
        divSource.style.display="block";
    }

    hideSource(){ //Display RichText, hide TextArea.
        var divRich = this.template.querySelector('div.rich');
        var divSource = this.template.querySelector('div.source');
        divRich.style.display="block";
        divSource.style.display="none";
    }

   /* handleSaveEvent(){
        // Get the labels of selected checkboxes
        var Rich = this.template.querySelector('lightning-input-rich-text');
        const messageTest = Rich.value;
        const messageEvent = new CustomEvent('saveevent', {
            detail: { messageTest },
        });        
        // Fire the custom event
        this.dispatchEvent(messageEvent);

    }*/


    handleImageEvent() {    
        // Fire the custom event to Lightning component (container)
        this.dispatchEvent(new CustomEvent('imageclicked'));
    }


    customButtons = [
        {
            category: "REMOVE_FORMATTING",
            buttons: [
                {
                   
                    label: 'Image',
                    iconName: 'utility:image',
                    format: 'Image',
                    handler: () =>  {
                        this.handleImageEvent();
              
                    }
                }
            ]
        },

    ];


    get myCustomButtons() {
        return this.customButtons;
    }

    get myVal() {
        return ' ';

    }

    
}