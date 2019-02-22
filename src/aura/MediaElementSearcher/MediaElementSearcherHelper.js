({
	searchByText : function(component, event, helper) {
		component.set('v.scrollCalled', true);
		component.set("v.isEndPage", false);
		component.set("v.offset", 0);
		component.set("v.searchValue", component.find("searchField").getElement().value);
		component.set("v.mediaElementList", '');
		helper.getMedElems(component);
	},

	getMedElems: function( component ) {
		//component.set("v.isLoading", true);
		var searchtext = component.get("v.searchValue");
		var elementPerPage = component.get("v.elementPerPage");
		var action = component.get("c.getData");

		action.setParams({
			stringOffset: component.get("v.offset").toString(),
			searchText: searchtext,
			stringElementPerPage: elementPerPage.toString()
		});

		action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
				if(action.getReturnValue() == ''){
					component.set("v.isEndPage", true);
				} else{
		        	if(component.get("v.mediaElementList") != ''){
		            	var medElemList = component.get("v.mediaElementList");
		            	var returnList = action.getReturnValue();

		            	returnList.forEach(function(ACC) {
							medElemList.push(ACC);
						});
						component.set("v.mediaElementList", medElemList);
		        	} else {
		        		component.set("v.mediaElementList", action.getReturnValue());
		        	}
				}
            	//component.set("v.isLoading", false);
            	component.set("v.offset", component.get("v.offset")+elementPerPage);

            	//Added to use the scroll once time
            	component.set('v.scrollCalled', false);
	        }
	    });

	    $A.enqueueAction(action);
	},

	closeModal : function(component, event, helper){		
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	}
})