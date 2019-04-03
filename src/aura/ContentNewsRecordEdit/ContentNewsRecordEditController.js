({	
	doInit : function(component, event, helper){
		helper.setContentData(component);
	},
	handleUpsertEvent : function(component, event, helper){
		var status = event.getParam("status");
		var contentId = event.getParam("contentId");
		var recordId = component.get("v.contentData.Id");
		if(recordId == contentId){
			event.stopPropagation();
			helper.updateContent(component, status);
		}
	},
	handleMediaElementEvent : function(component, event, helper){
		var mediaElementId = event.getParam("ID");
		var imageUrl = event.getParam("URL");
		var mediaElementName = event.getParam("NAME");
		component.set('v.mediaElementId', mediaElementId);
		component.set('v.imageUrl', imageUrl);
		component.set('v.mediaElementName', mediaElementName);
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
	},
	unassignFeatureImg: function(component, event, helper){
		helper.unassignFeatureImg(component, event, helper);
	},
})