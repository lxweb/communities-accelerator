({
	getRecords : function(component, event, helper) {
		var junctionObjectHardcode = "MediaElementAssignment__c";

		//component.set("v.isLoading", true);
		component.set("v.mediaElementList", '');
		component.set("v.mediaElementPlace", '');
		component.set("v.searchValue",'');

		var action = component.get("c.getRecord");

		action.setParams({
			recordId: component.get("v.recordId"),
			places: component.get("v.places"),
			parentLookup: component.get("v.parentLookup"),
			junctionObject: junctionObjectHardcode
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordWrapperList", action.getReturnValue());
            	//component.set("v.isLoading", false);
	        }
	    });

	    $A.enqueueAction(action);
	},

	getMedElemsButton: function(component, event, helper) {
		component.set("v.isEndPage", false);
		component.set("v.mediaElementPlace", event.getSource().get("v.value"));// get place
		component.set("v.offset", 0);
		component.set("v.searchValue",'');
		component.set("v.mediaElementList", '');
		component.set("v.scrollCalled", true);
		console.log('component');
		console.log(component.find("ss01"));
		component.find("ss01").focus();
		helper.getMedElems(component);
	},

	getMedElems: function( component ) {
		//component.set("v.isLoading", true);
		var searchValue = component.get("v.searchValue");

		var elementPerPage = component.get("v.elementPerPage");
		var action = component.get("c.getMediaElements");

		action.setParams({
			stringOffset: component.get("v.offset").toString(),
			searchText: searchValue,
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

	choseMediaElement : function(component, event, helper) {

		var mElementId = event.target.getAttribute('id');
		var junctionObjectHardcode = "MediaElementAssignment__c";

		var action = component.get("c.assignMediaElementToId");
		action.setParams({
			recordId: component.get("v.recordId"),
			place: component.get("v.mediaElementPlace"),
			parentLookup: component.get("v.parentLookup"),
			junctionObject: junctionObjectHardcode,
			mediaElementId: event.target.getAttribute('id')
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	//component.set("v.isLoading", false);
            	component.set("v.mediaElementList", '');
            	helper.getRecords(component, event, helper);
	        }
	    });

	    $A.enqueueAction(action);
	},

	deleteMediaElement : function(component, event, helper) {
		var answer = confirm($A.get("$Label.c.General_AreYouSure"));
		if (answer == true){
			// var jObjectId = event.target.getAttribute('id');
			var jObjectId = event.getSource().get("v.value");

			var junctionObjectHardcode = "MediaElementAssignment__c";

			var action = component.get("c.deleteJunctionObject");

			action.setParams({
				junctionObjectId: jObjectId,
				junctionObjectApiName: junctionObjectHardcode
			});

		    action.setCallback(this, function(f) {
	            if(f.getState() === "SUCCESS") {
	            	//component.set("v.isLoading", false);
	            	helper.getRecords(component, event, helper);
		        }
		    });

		    $A.enqueueAction(action);
		}
	},

	searchByText : function(component, event, helper) {
		component.set('v.scrollCalled', true);
		component.set("v.isEndPage", false);
		component.set("v.offset", 0);
		component.set("v.searchValue", component.find("searchField").getElement().value);
		component.set("v.mediaElementList", '');
		helper.getMedElems(component);
	}
})