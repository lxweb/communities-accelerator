({
	getSearchResults: function (component, searchedString) {
       
        var action = component.get("c.getSearchResults");
        action.setParams({
            searchedString: searchedString
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
            	var results 	= action.getReturnValue();
                var appEvent 	= $A.get("e.c:SetSearchResults");
		        appEvent.setParams({
		            "results" 		: results,
		            "selectedItem" 	: (results && results.length > 0) ? results[0].sectionApiName : null
		        });
		        appEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})