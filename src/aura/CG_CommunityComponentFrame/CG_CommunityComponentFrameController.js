({
	doInit : function(component, event, helper) {
		//code
	},
	doViewComponent : function(component, event, helper) {
		helper.viewComponent(component, event, helper);
	},
	doViewContent : function(component, event, helper) {
		helper.viewContent(component, event, helper);
	},
	doNewContent : function(component, event, helper){
		helper.newContent(component, event, helper);
	},
	doShowEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, true);
	},
	doHideEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, false);
	}
})