({
    doInit : function(component, event, helper) {
        var showComponentFrame = component.get('v.showComponentFrame');
        
        if(showComponentFrame){
            if(String(window.location.href).includes('livepreview.') || String(window.location.href).includes('sitestudio.')){
                component.set('v.showComponentFrame', false);
            }
        }
	},
	doViewComponent : function(component, event, helper) {
		helper.viewComponent(component, event, helper);
	},
	doViewContent : function(component, event, helper) {
		helper.viewContent(component, event, helper);
	},
	doShowEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, true);
	},
	doHideEditFrame : function(component, event, helper) {
		helper.showHideEditFrame(component, helper, false);
	},
	doNewContent : function(component, event, helper){
		helper.newContent(component, event, helper);
	}
})