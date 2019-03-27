({
    handleNavigateToDetail : function (component, event, helper){
        var values = JSON.parse(event.getParam("values"))
        
        var parentComponentId;
        var parentComponentType = component.get("v.componentWrapper.component.RecordType.DeveloperName");
        if (parentComponentType == 'RelatedEvents'){
            parentComponentId = component.get("v.parentComponentId");
        } else {
            parentComponentId = component.get("v.componentWrapper.component.ExternalId__c");
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": values.url +'?eventId=' + values.id + '&parentComponentId=' + parentComponentId
        });
        urlEvent.fire();
    }
})