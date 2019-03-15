({
	setRecordList : function(component, selectedItem) {
		var results 		= component.get("v.results");
		var selectedResult 	= results.find( result => result.sectionApiName === selectedItem );


        var appEvent 	= $A.get("e.c:SetRecordList");
		appEvent.setParams({
			"title"				: selectedResult.sectionName,
			"iconName"			: selectedResult.iconName,
		    "columns" 			: selectedResult.fieldsToShow,
		    "data"				: selectedResult.records,
		    "dataTableSchema" 	: selectedResult.objectAPIName,
		    "totalNumberOfRows" : selectedResult.records.length
		});
		appEvent.fire();

		console.log("[CG_SearchResultsHelper.js][setRecordList] selectedResult: " + JSON.stringify(selectedResult));
	}
})