({
	doInit: function (component, event, helper) {
        helper.getData(component);
    },
    doSaveDraft: function (component, event, helper) {
    	helper.saveDraft(component, event, helper);
    },
    doPublishContent: function (component, event, helper) {
    	helper.publish(component, event, helper);
    },
    doUnpublishContent: function (component, event, helper) {
    	helper.unpublish(component, event, helper);
    },
    onKeyUp: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;
        var isEscapeKey = event.keyCode === 27;
        var newName = component.find("name-input").get("v.value");
        if(isEnterKey){
            helper.setName(component, newName);
        }
        if(isEscapeKey){
            component.set("v.isNameEdit", false);
        }
    },
    editName: function (component, event, helper) {
        component.set("v.temporaryName", component.get("v.contentData").Name);
        component.set("v.isNameEdit", true);
        console.log("isEdit: " + component.get("v.isNameEdit"));
    }
})