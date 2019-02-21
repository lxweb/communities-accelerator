({
	doInit : function(component, event, helper) {
		var action = component.get('c.getFilters');
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.filters', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})