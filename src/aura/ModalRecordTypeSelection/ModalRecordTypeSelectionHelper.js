({
	getObjectLabel : function(component, sObjectName) {
		if(component.get("v.sObjectLabel") == null){
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
		}
	},
	getRecordTypes : function(component, sObjectName, rtList) {
		var action = component.get("c.getRecordTypes");

		action.setParams({
			sObjectType: sObjectName,
			recordTypes: rtList
		});

		action.setCallback(this, function(response) {
	        if(response.getState() === "SUCCESS") {
	           	var options = response.getReturnValue();
				component.set("v.options", options);
		    }
		});
			    
		$A.enqueueAction(action);
	},
	openModal : function(component){
		var modalBox = component.find('modalBox');
		var modalBackdrop = component.find('modalBackdrop');
		$A.util.addClass(modalBox, 'slds-fade-in-open');
		$A.util.addClass(modalBackdrop,'slds-backdrop--open');
	},
	closeModal : function(component){
		var modalBox = component.find('modalBox');
		var modalBackdrop = component.find('modalBackdrop');
		$A.util.removeClass(modalBox, 'slds-fade-in-open');
		$A.util.removeClass(modalBackdrop,'slds-backdrop--open');
	},
	goToNewRecord : function(component){
    	var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": "/lightning/n/NewContent?RecordTypeId=" + component.get("v.value")
	    });
	    urlEvent.fire();
	}
})