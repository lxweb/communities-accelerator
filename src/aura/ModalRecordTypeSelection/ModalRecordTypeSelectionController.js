({
	onInit : function(component, event, helper) {
        helper.getObjectLabel(component, component.get("v.sObjectName"));
        helper.getRecordTypes(component, component.get("v.sObjectName"), component.get("v.rtDevNameList"));
	},
	onShow : function(component, event, helper) {
		var modalBox = component.find('modalBox');
		var modalBackdrop = component.find('modalBackdrop');
		$A.util.addClass(modalBox, 'slds-fade-in-open');
		$A.util.addClass(modalBackdrop,'slds-backdrop--open');
	},
    onHide : function(component, event, helper) {
		var modalBox = component.find('modalBox');
		var modalBackdrop = component.find('modalBackdrop');
		$A.util.removeClass(modalBox, 'slds-fade-in-open');
		$A.util.removeClass(modalBackdrop,'slds-backdrop--open');
	},
    onNewRecord : function(component, event, helper) {
	},
	optionSelected : function(component,event,helper){
        var recordTypeId = event.target.getAttribute("value");
        component.set("v.value", recordTypeId);
    }
})