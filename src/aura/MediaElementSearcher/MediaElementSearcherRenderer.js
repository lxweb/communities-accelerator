({
	/*
	afterRender: method is executed when all the DOM elements on the page was complete rendered
	- For the Infinite Scroll you need to have on your cmp file:
	<aura:attribute name="scrollCallback" type="Object" access="private" />
	*/
	afterRender: function (component, helper) {
		//Extend the default afterRender method
		var afterRend = this.superAfterRender();
		var listElm = document.querySelector('#infinite-list');

		//** Init the Infinite Scroll
		//Set the lightning component with the scroll callback method
		component.set('v.scrollCallback', $A.getCallback( function() {
			//Add validation
			if (component.isValid() && !component.get('v.scrollCalled')) {
				if (listElm.clientHeight + listElm.scrollTop + 1 >= listElm.scrollHeight) {
					//Call your helper method to show more items
					helper.getMedElems(component);
					component.set('v.scrollCalled', true);
				}
			}
		}));

		//Add the event Listener 'scroll' to the window
		listElm.addEventListener('scroll', component.get('v.scrollCallback'));
		//** End the Infinite Scroll
		return afterRend;
	}
})