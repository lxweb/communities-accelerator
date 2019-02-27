({
	doInit : function(component, event, helper) {
        
		var action = component.get("c.getTableWrapper");
        action.setParams({
            contentTypeId: null, // component.get("v.contentTypeId"),
            clusterId: null, // component.get("v.clusterId"),
            categoryId: null, // component.get("v.categoryId"),
            tagIds: null // component.get("v.tagIds")
        });
        
        action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS"){
                console.log(action.getReturnValue());
                component.set("v.tableWrapper", JSON.parse(action.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
	}
})