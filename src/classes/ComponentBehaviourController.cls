public class ComponentBehaviourController {

    @auraEnabled
    public static String getComponentBehaviour(String contentId){
        Content__c content = [SELECT Id, RecordTypeId, StructureComponent__c FROM Content__c WHERE Id =: contentId];
        String componentId = content.StructureComponent__c;
        return componentId != null ? getBehaviourMessage(componentId) : null;  
    }

    private static String getBehaviourMessage(String componentId){
        //Get DataSource
        Component__c component = [SELECT Id, dataSource__c, TagCriteria__c FROM Component__c WHERE Id =: componentId];
        String dataSource = component.dataSource__c;
        //Get records related to DataSource
        String behaviourMessage;
        if(dataSource == 'ManualAssignment'){
            behaviourMessage = Label.ComponentBehaviourManualAssignment;
        }
        if(dataSource == 'Tags'){
            behaviourMessage = getTagsMessage(component);
        }
        if(dataSource == 'Categories'){
            behaviourMessage = getCategoriesMessage(component);
        }
        if(dataSource == 'TagsCategories'){            
            behaviourMessage = getTagsMessage(component) + '\n\n';
            behaviourMessage += getCategoriesMessage(component);
        }
        // Build Message
        return behaviourMessage;
    }

    private static String getTagsMessage(Component__c component){
        String behaviourMessage;
        behaviourMessage = Label.ComponentBehaviourTags + '\n';
        List<TagAssignment__c> tagAssignments = [SELECT Id, Tag__c, Tag__r.Name, Order__c FROM TagAssignment__c WHERE Component__c =: component.Id ORDER BY Order__c ASC];
        for(TagAssignment__c tagAssignment : tagAssignments){
            behaviourMessage += '\n' + tagAssignment.Order__c + '. ' + tagAssignment.Tag__r.Name;
        }
        behaviourMessage += '\n\n Tag criteria: ' + component.TagCriteria__c;
        return behaviourMessage;
    }

    private static String getCategoriesMessage(Component__c component){
        String behaviourMessage;
        behaviourMessage = Label.ComponentBehaviourCategories + '\n';
        List<CategoryAssignment__c> categoryAssignments = [SELECT Id, Category__c, Category__r.Name FROM CategoryAssignment__c WHERE Component__c =: component.Id];
        for(CategoryAssignment__c categoryAssignment : categoryAssignments){
            behaviourMessage += '\n - ' + categoryAssignment.Category__r.Name;
        }
        return behaviourMessage;
    }

}