({
	// Your renderer method overrides go here
	/*afterRender: method is executed when all the DOM elements on the page was complete rendered
	*/
	afterRender: function (component, helper) {
	   //Extend the default afterRender method
	   var afterRend = this.superAfterRender();
	 
	   //** Init the Infinite Scroll
	   //Set the lightning component with the scroll callback method
	   component.set('v.scrollCallback', $A.getCallback( function() {
	      if (component.isValid() && !component.get('v.scrollCalled')) {
	         if ( window['scrollY'] + window['innerHeight'] >= document.body.offsetHeight){
	            //Call your helper method to show more items
	            helper.loadMore(component, helper);
	            component.set('v.scrollCalled', true);
	         }
	      }
	   }));
	 
	   //Add the event Listener 'scroll' to the window
	   window.addEventListener('scroll', component.get('v.scrollCallback'));
	   //** End the Infinite Scroll
	 
	   return afterRend;
	}

})