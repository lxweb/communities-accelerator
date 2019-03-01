({
	onInit : function(component, event, helper) {
        component.set("v.defaultRecordType", component.get("v.pageReference").state.recordType);
	}
})