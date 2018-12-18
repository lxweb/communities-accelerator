({
	doInit: function (component, helper) {
		component.set("v.isLoading", true);

        var action = component.get("c.getRecord");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.record", action.getReturnValue());
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    }
})