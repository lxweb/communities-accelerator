({	
	doInit : function(component, event, helper){
		helper.setContentData(component);
	},
	handleUpsertEvent : function(component, event, helper){
		console.log("[ContentNewsRecordEditController.js][handleUpsertEvent]");
		var status = event.getParam("status");
		helper.updateContent(component, status);
	},
})