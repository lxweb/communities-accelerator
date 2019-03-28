({	
	doInit : function(component, event, helper){
		helper.setContentData(component);
	},
	handleUpsertEvent : function(component, event, helper){
		var status = event.getParam("status");
		helper.updateContent(component, status);
	},
	handleMediaElementEvent : function(component, event, helper){
		var mediaElementId = event.getParam("ID");
		var imageUrl = event.getParam("URL");
		component.set('v.mediaElementId', mediaElementId);
		component.set('v.imageUrl', imageUrl);
	},
	onExternalIdKeyUp : function(component, event, helper){
		var isEnterKey = event.keyCode === 13;
        var isEscapeKey = event.keyCode === 27;
        var contentData = component.get("v.contentData");
        if(isEnterKey){
			component.set("v.isExtIdEdit", false);
        }
        if(isEscapeKey){
        	contentData.ExternalId__c = component.get("v.oldExtId");
        	component.set("v.contentData", contentData);
            component.set("v.isExtIdEdit", false);
        }
	},
	editExternalId : function(component, event, helper){
		component.set("v.isExtIdEdit", true);
		component.set("v.oldExtId", component.get("v.contentData").ExternalId__c);
		setTimeout(function(){
            var input = component.find("externalid-input");
            input.focus();
        }, 0);
	},
	onExternalIdInputBlur : function(component, event, helper){
		component.set("v.isExtIdEdit", false);
	}
})