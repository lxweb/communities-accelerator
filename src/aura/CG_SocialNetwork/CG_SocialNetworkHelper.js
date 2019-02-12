({
	doInit : function(component, event, helper) {
		
		var action = component.get("c.getSocialNetworks");
 		action.setParams({
			brandId: helper.getUrlParameter("brand")
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.networkWrapper", action.getReturnValue());
	        }
	    });
	    console.log(action);
	    $A.enqueueAction(action);
	},
	getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), sParameterName, i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    }
})