({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
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
		component.set('v.mediaElementId', mediaElementId);
		component.set('v.imageUrl', imageUrl);
	}
})