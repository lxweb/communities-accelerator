({
	doInit : function(component, event, helper) {
		var action = component.get('c.getFilters');
		action.setParams({
            sObjectType: component.get("v.sObjectName")
        });
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.filters', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})