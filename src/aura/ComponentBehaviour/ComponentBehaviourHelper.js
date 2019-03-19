({
	doInit : function(component, event, helper) {
		var recordId = component.get('v.recordId');
		var action = component.get('c.getComponentBehaviour');
		action.setParams({
			contentId: recordId
    	});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.behaviourMessage", response.getReturnValue());
			}
		});		
		$A.enqueueAction(action);
	}
})