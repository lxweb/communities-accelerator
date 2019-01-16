({
    getTree: function (component, helper) {
       
        var action = component.get("c.getTree");
        action.setParams({
            recordId: component.get("v.recordId"),
            objectName: component.get("v.objectName"),
            parentLookUP: component.get("v.parentLookUp")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.root", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})