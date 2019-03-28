({
	getData : function(component){
		var action = component.get('c.getData');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId')
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var dataWrapper = response.getReturnValue();
				if(dataWrapper){
					component.set("v.contentData", dataWrapper.content);
					component.set("v.timeZone", dataWrapper.timeZone);
				}else{
					helper.displayErrorMessage($A.get("$Label.c.NewsContentDetailLoadError"));
				}
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	setName : function(component, newName){
		var action = component.get('c.setName');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId'),
			name: newName
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var newName = response.getReturnValue();
				var contentData = component.get("v.contentData");
				contentData.Name = newName;
				component.set("v.contentData", contentData);
				component.set("v.isNameEdit", false);
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	setStatus : function(component, status){
		var action = component.get('c.setStatus');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId'),
			status: status
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var status = response.getReturnValue();
				var contentData = component.get("v.contentData");
				helper.showCorrectMessage(component, contentData.Status__c, status);
				contentData.Status__c = status;
				component.set("v.contentData", contentData);
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	createFromTemplate : function(component){
		var action = component.get('c.createFromTemplate');
		var helper = this;

		action.setParams({
			recordId: component.get('v.recordId')
    	});

		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentCreatedFromTemplate"), component.get("v.contentData").Name));
				var contentId = response.getReturnValue();
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId": contentId,
					 });
				navEvt.fire();
			} else if (state === "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error';
				if (errors && Array.isArray(errors) && errors.length > 0) {
				    message = errors[0].message;
				}
				helper.displayErrorMessage(message);
			}
		});

		$A.enqueueAction(action);
	},
	showCorrectMessage : function(component, previousStatus, actualStatus){
		var recordTypeName 	= component.get("v.contentData").recordType.Name;
		var recordName 		= component.get("v.contentData").Name;
		var helper 			= this;

		if(previousStatus === 'Draft' && actualStatus === 'Draft'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailDraftMessage"), recordTypeName, recordName));
		} else if(previousStatus === 'Draft' && actualStatus === 'Published'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailPublishMessage"), recordTypeName, recordName));
		} else if(previousStatus === 'Published' && actualStatus === 'Draft'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailUnpublishMessage"), recordTypeName, recordName));
		} else if(previousStatus === 'Published' && actualStatus === 'Published'){
			helper.displaySuccessMessage(helper.stringFormat($A.get("$Label.c.ContentDetailPublishMessage"), recordTypeName, recordName));
		}
	},
	saveDraft : function(component, event, helper) {
		console.log("[ContentDetailHeaderHelper.js][saveDraft] hasDetailComponent: " + component.get("v.hasDetailComponent"));
		if(component.get("v.hasDetailComponent")){
			var cmpEvent = $A.get("e.c:upsertContentsEvent");
	        cmpEvent.setParams({
	            "status" : "Draft" });
	        cmpEvent.fire();
	    } else
	    	helper.setStatus(component, 'Draft');
	},
	publish : function(component, event, helper) {
		console.log("[ContentDetailHeaderHelper.js][publish] hasDetailComponent: " + component.get("v.hasDetailComponent"));
		if(component.get("v.hasDetailComponent")){
			var cmpEvent = $A.get("e.c:upsertContentsEvent");
	        cmpEvent.setParams({
	            "status" : "Published" });
	        cmpEvent.fire();
	    } else
	    	helper.setStatus(component, 'Published');
	},
	unpublish : function(component, event, helper) {
		console.log("[ContentDetailHeaderHelper.js][unpublish] hasDetailComponent: " + component.get("v.hasDetailComponent"));
		if(component.get("v.hasDetailComponent")){
			var cmpEvent = $A.get("e.c:upsertContentsEvent");
	        cmpEvent.setParams({
	            "status" : "Draft" });
	        cmpEvent.fire();
	    } else
	    	helper.setStatus(component, 'Draft');
	},
	displayErrorMessage : function(message){
		var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Error",
						message: message,
						type: "error"
					});
		toastEvent.fire();
	},
	displaySuccessMessage : function(message){
		var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						title: "Success!",
						message: message,
						type: "success"
					});
					toastEvent.fire();
	},
	stringFormat: function(string) {
	    var outerArguments = arguments;
	    return string.replace(/\{(\d+)\}/g, function() {
	        return outerArguments[parseInt(arguments[1]) + 1];
	    });
	}

})