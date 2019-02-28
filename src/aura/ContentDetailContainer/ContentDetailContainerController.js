({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
	handleUpsertEvent : function(component, event, helper){
		var test = event.getParam("action");
		console.log(test);
	},
	handleUpsertEvent : function(component, event, helper){
		var action = event.getParam("action");
		helper.upsertContent(component, action);
	},
	handleMediaElementEvent : function(component, event, helper){
		var mediaElementId = event.getParam("ID");
		var imageUrl = event.getParam("URL");
		component.set('v.mediaElementId', mediaElementId);
		component.set('v.imageUrl', imageUrl);
	}
})