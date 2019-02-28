({
	getHeaderDetail : function(component,helper) {
        
   		if(component.get("v.contentData")!=null){
   		   	var headerData = component.get("v.contentData");
			if(headerData.Name ){
				component.set("v.Name",headerData.Name);
			}
			if(headerData.LastModifiedDate){
				component.set("v.LastModifiedDate",headerData.LastModifiedDate);
			}
			if(headerData.Status__c){
				component.set("v.Status",headerData.Status__c);
			}
			if(headerData.CreatedBy){
				component.set("v.CreatedById",headerData.CreatedBy.Name);
			}else {
				component.set("v.CreatedById",component.get("v.currentUserName"));
			}
			
			component.set("v.RecordType",headerData.RecordType.Name );	
   		}
	},

	saveDraft : function(component, event, helper) {

		var cmpEvent = component.getEvent("upsertContentsEvent");
        cmpEvent.setParams({
            "action" : "Draft" });
        cmpEvent.fire();
	},

	publish : function(component, event, helper) {
		var cmpEvent = component.getEvent("upsertContentsEvent");
        cmpEvent.setParams({
            "action" : "Publish" });
        cmpEvent.fire();
	},

	unPublish : function(component, event, helper) {

		var cmpEvent = component.getEvent("upsertContentsEvent");
        cmpEvent.setParams({
            "action" : "UnPublish" });
        cmpEvent.fire();
	}

})