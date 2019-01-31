({
	doInit : function(component, event, helper) {
		
		var id = helper.getUrlParameter('brand');
		var componentExternalId = component.get("v.componentExternalId");

		var action = component.get("c.getBrandWrapper");
		action.setParams({
			brandId : id,
			componentExternalId : component.get("v.componentExternalId")
		});

		action.setCallback(this, function(f) {
			if(f.getState() === "SUCCESS"){
				component.set("v.brandDetailWrapper", action.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	getUrlParameter : function(sParam) { // URL + ?brand=a0H1U000001WuzLUAS
        var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), sParameterName, i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    }
})