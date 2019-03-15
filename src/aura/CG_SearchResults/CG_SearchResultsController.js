({
	onItemSelect : function(component, event, helper) {
		helper.setRecordList(component, event.getParam('name'));
	},
	handleSearchResults: function(component, event, helper){
		var results 		= event.getParam("results");
		var selectedItem 	= event.getParam("selectedItem");
		
		component.set("v.results", results);
		component.set("v.selectedItem", selectedItem);

		helper.setRecordList(component, selectedItem);
		console.log("[CG_SearchResultsController.js][handleSearchResults] resutls: " + JSON.stringify(component.get("v.results")));
        // set the handler attributes based on event data
	}
})