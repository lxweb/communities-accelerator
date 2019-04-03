({
	doInit: function (component, event, helper) {
        helper.getFilterOptions(component, helper);
    },
    onRadio : function(component, event, helper){
        helper.onRadio(component, event);
    },
    onCheck : function(component, event, helper){
        helper.onCheck(component, event);
    },
    onChange : function(component, event, helper){
    	var value = event.getParam("value");
        var apiName = event.getSource().get("v.name");
    	helper.setSelectedValue(component, apiName, value);
    }
})