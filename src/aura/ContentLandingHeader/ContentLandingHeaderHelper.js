({
	getObjectLabel : function(component, sObjectName) {
		var action = component.get("c.getObjectLabel");

			action.setParams({
				sObjectType: sObjectName
			});

			action.setCallback(this, function(response) {
		        if(response.getState() === "SUCCESS") {
		           	var sObjectLabel = response.getReturnValue();
					component.set("v.sObjectLabel", sObjectLabel);
			    }
			});
			    
			$A.enqueueAction(action);
	},
	getStatusValues : function(component, sObjectName, fieldApiName) {
		var action = component.get("c.getPicklistValues");
		
		action.setParams({
			sObjectType		: sObjectName,
			fieldApiName	: fieldApiName
		});

		action.setCallback(this, function(response) {
		    if(response.getState() === "SUCCESS") {
		      	var statusValues = response.getReturnValue();
				component.set("v.statusValues", statusValues);
				console.log("statusValues: " + JSON.stringify(statusValues));
		    }
		});
		    
		$A.enqueueAction(action);
	}
})