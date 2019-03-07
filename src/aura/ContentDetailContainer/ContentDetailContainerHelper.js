({
	doInit : function(component, event, helper) {
		//var recordTypeId = component.get("v.pageReference").state.recordTypeId;
		var recordId = component.get('v.recordId');
		var recordTypeId;
		if(component.get("v.pageReference"))
			recordTypeId = component.get("v.pageReference").state.RecordTypeId;
		var action;
		//If we're viewing an existing content.
		if(recordId){
			action = component.get('c.getDataExisting');
			action.setParams({
				recordId: recordId
        	});
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					if(response.getReturnValue()){
						component.set("v.currentUserName", response.getReturnValue().currentUserName);
						component.set("v.contentData", response.getReturnValue().content);
						component.set("v.visibilitySelectors", response.getReturnValue().visibilitySelectors);
						if(response.getReturnValue().content.MediaElementAssignments__r != null){
							component.set('v.imageUrl', response.getReturnValue().content.MediaElementAssignments__r[0].MediaElement__r.FileURLDesktop__c);
						}	
					}else{
						this.displayErrorMessage($A.get("$Label.c.NewsContentDetailLoadError"));
						return;
					}
				}
			});
		//If we are creating a new content
		}else if(recordTypeId){
			action = component.get('c.getDataNew');
			action.setParams({
				contentRecordTypeId: recordTypeId
        	});
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set("v.currentUserName", response.getReturnValue().currentUserName);
					component.set("v.contentData", response.getReturnValue().content);
					component.set("v.visibilitySelectors", response.getReturnValue().visibilitySelectors);
				}
			});
		}else{
			this.displayErrorMessage($A.get("$Label.c.NewsContentDetailLoadError"));
			return;
		}
		
		$A.enqueueAction(action);
	},

	upsertContent : function(component, eventAction){
		var content = component.get('v.contentData');
		if(content.ListTitle__c == ''){
			this.displayErrorMessage($A.get("$Label.c.NewsContentDetailRequiredField"));
			return;
		}
		var visibilitySelectors = component.get('v.visibilitySelectors');
		var mediaElementId = component.get('v.mediaElementId');
		var action = component.get('c.saveContent');
		action.setParams({
			content : content,
			visibilitySelectorsString : JSON.stringify(visibilitySelectors),
			mediaElementId : mediaElementId,
			action : eventAction,
			contentOldTagAssignments : content.Tags__r
        });
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				if(response.getReturnValue()){
					component.set('v.contentData', response.getReturnValue());
					var navEvt = $A.get("e.force:navigateToSObject");
    				navEvt.setParams({
						"recordId": response.getReturnValue().Id,
   					 });
    				navEvt.fire();
				}else{
					this.displayErrorMessage($A.get("$Label.c.NewsContentDetailError"));
				}
			}
		});
		$A.enqueueAction(action);
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
	}
})