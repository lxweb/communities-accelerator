({
	doInit: function (component, event, helper) {
        helper.getHeaderDetail(component, helper);
    },

    doSaveDraft: function (component, event, helper) {
    	helper.saveDraft(component, event, helper);
    },

    doPublishContent: function (component, event, helper) {
    	helper.publish(component, event, helper);
    },

    doUnPublishContent: function (component, event, helper) {
    	helper.unPublish(component, event, helper);
    }
	
})