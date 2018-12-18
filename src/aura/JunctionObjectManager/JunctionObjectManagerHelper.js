({
	getRecords : function(component) {
		component.set("v.isLoading", true);
		
		var action = component.get("c.getRecords");
		action.setParams({
			recordId: component.get("v.recordId"),
			junctionObjectAPIName: component.get("v.junctionObjectAPIName"),
			parentLookup: component.get("v.parentLookup"),
			secondaryLookup: component.get("v.secondaryLookup"),
			whereCondition: component.get("v.whereCondition")
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.recordsWrapper", action.getReturnValue());
            	component.set("v.isLoading", false);

            	if(action.getReturnValue().recordsSelected.length < 5){
            		component.set("v.variableDivHeight", (40 + (action.getReturnValue().recordsSelected.length * 30) + 'px'));
            	}else{
            		component.set("v.variableDivHeight", '162px');
            	}
	        }
	    });
	    $A.enqueueAction(action);
	},

	save : function(component, event, helper) {
		component.set("v.isLoading", true);
		var listSelectedIds = [];
		var allCheckbox = component.find("i_input_checkbox");

		if(allCheckbox.length === undefined){
			if(allCheckbox.get("v.value") == true) {
				listSelectedIds.push(allCheckbox.get("v.text"));
			}
		}else{
			for(var i = 0; i < allCheckbox.length; i++) {
				if(allCheckbox[i].get("v.value") == true) {
					listSelectedIds.push(allCheckbox[i].get("v.text"));
				}
			}
		}

		var action = component.get("c.saveRelationships");
		action.setParams({
			recordId: component.get("v.recordId"),
			junctionObjectAPIName: component.get("v.junctionObjectAPIName"),
			parentLookup: component.get("v.parentLookup"),
			secondaryLookup: component.get("v.secondaryLookup"),
			listSelectedIds: listSelectedIds
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	var showToast = $A.get('e.force:showToast');

            	if(action.getReturnValue() == 'OK'){
					showToast.setParams({
						'title'   : $A.get("$Label.c.General_Success"),
						'message' : $A.get("$Label.c.General_RecordsSavedSuccessfully"),
						'type'    : 'success'
					});
				}else{
					showToast.setParams({
						'title'   : $A.get("$Label.c.General_Error"),
						'message' : action.getReturnValue(),
						'type'    : 'error'
					});
				}
				component.set("v.isLoading", false);
				showToast.fire();

				component.set("v.isEdit", false);
				helper.getRecords(component);
	        }
	    });
	    $A.enqueueAction(action);
	},

	selectAll: function(component, event) {
		var selectedHeaderCheck = event.getSource().get("v.value");
		var getAllId = component.find("i_input_checkbox");
		if(!Array.isArray(getAllId)){
			if(selectedHeaderCheck == true){ 
				component.find("i_input_checkbox").set("v.value", true);
			}else{
				component.find("i_input_checkbox").set("v.value", false);
			}
		}else{
			if(selectedHeaderCheck == true) {
				for(var i = 0; i < getAllId.length; i++) {
					component.find("i_input_checkbox")[i].set("v.value", true);
				}
			}else{
				for(var i = 0; i < getAllId.length; i++) {
					component.find("i_input_checkbox")[i].set("v.value", false);
				}
			}
		}
	},

	search: function(component) {
		var searchInput = component.find("i_input_search").getElement().value;
		var tableRows = component.find('i_table_edit').getElement().getElementsByClassName('c_item_searchable');
		for(var i = 0; i < tableRows.length; i++) { 
			if(String(tableRows[i].getElementsByTagName('a')[0].innerHTML).toLowerCase().includes(searchInput.toLowerCase())){
				tableRows[i].style.display = 'table-row';
			}else{
				tableRows[i].style.display = 'none';
			}
		}
	}

})