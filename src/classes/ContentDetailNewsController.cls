public with sharing class ContentDetailNewsController {
	//DATA WRAPPER
    public class DataWrapper{
        @auraEnabled public Content__c 						content;
        @auraEnabled public List<VisibilitySelectorWrapper> visibilitySelectors;
        @auraEnabled public String 							timeZone;
        @AuraEnabled public SecurityWrapper					security;
        
        public DataWrapper(Content__c content, SecurityWrapper security, List<VisibilitySelectorWrapper> visibilitySelectors, String timeZone){
            this.content                = content;
            this.visibilitySelectors    = visibilitySelectors;
            this.security    			= security;
            this.timeZone    			= timeZone;
        }
    }

    //SECURITY WRAPPER
    public class SecurityWrapper{
        @AuraEnabled public Boolean     hasEditAccess;
        @AuraEnabled public Boolean     hasCreateContentPermission;
        @AuraEnabled public Boolean     hasRecordTypeAvailable;

        public SecurityWrapper(Boolean hasEditAccess, Boolean hasCreateContentPermission, Boolean hasRecordTypeAvailable){
            this.hasEditAccess              = hasEditAccess;
            this.hasCreateContentPermission = hasCreateContentPermission;
            this.hasRecordTypeAvailable     = hasRecordTypeAvailable;
        }
    }

    //VISIBILITY WRAPPER
    public class VisibilitySelectorWrapper {
        @auraEnabled public String 							label;
        @auraEnabled public String 							apiName;
        @auraEnabled public Boolean 						isMultiPicklist;
        @auraEnabled public List<VisibilityOptionWrapper> 	values;

        public VisibilitySelectorWrapper(String label, String apiName, Boolean isMultiPicklist, List<VisibilityOptionWrapper> values){
            this.label 				= label;
            this.apiName 			= apiName;
            this.isMultiPicklist 	= isMultiPicklist;
            this.values 			= values;
        }
    }

    //VISIBILITY OPTION WRAPPER
    public class VisibilityOptionWrapper {
        @auraEnabled public String 	label;
        @AuraEnabled public String 	id;
        @AuraEnabled public Boolean isSelected;

        public VisibilityOptionWrapper(String label, string id, Boolean isSelected){
            this.label 		= label;
            this.id 		= id;
            this.isSelected = isSelected;
        }
    }

    @AuraEnabled
    public static DataWrapper getData(String recordId){
    	DataWrapper data;
    	try{
	        //Gets the entire cluster branch of the current user.
	        Set<Id> clusterIds = getClusterBranch();
	        //Gets the data from the current content.
	        Content__c contentRecord = getContentData(recordId);
	        //Gets the tags related to the content record.
	        Set<Id> tagIds = getTagsFromContentRecord(contentRecord);
	        //Gets all the visibility options, with the current content options set as true.
	        SecurityWrapper sw = new SecurityWrapper(hasEditAccess(recordId), hasCreateContentPermission(), hasRecordTypeAvailable(contentRecord.RecordType.DeveloperName));
	        List<VisibilitySelectorWrapper> visibilitySelectorList = new List<VisibilitySelectorWrapper>();
	        if(sw.hasEditAccess){
		        //visibilitySelectorList.add(getClusterSelectorWrapper(getSubordinateClusters(), contentRecord.cluster__c));
		        visibilitySelectorList.add(getCategorySelectorWrapper(clusterIds, contentRecord.category__c));
	        }
	        visibilitySelectorList.add(getTagSelectorWrapper(clusterIds, tagIds, sw.hasEditAccess));
	        data = new DataWrapper(contentRecord, sw, visibilitySelectorList, UserInfo.getTimeZone().getID());
        } catch(Exception e) {
        	throw new AuraHandledException(e.getMessage());
        }
        return data;
    }

	/*private static List<Cluster__c> getSubordinateClusters(){
		List<ClusterUser__c> clusterUser = [SELECT Cluster__c FROM ClusterUser__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        if(!clusterUser.isEmpty()){
            List<Cluster__c> clusters =  ClusterUtils.getClustersBelowList(clusterUser.get(0).cluster__c);
            return clusters;
        }
        return null;
	}*/

    private static Set<Id> getTagsFromContentRecord(Content__c content){
        Set<Id> tagIds = new Set<Id>();
        for(TagAssignment__c tagAssignment : content.tags__r){
            tagIds.add(tagAssignment.Tag__c);
        }
        return tagIds;
    }

    private static VisibilitySelectorWrapper getClusterSelectorWrapper(List<Cluster__c> clusters, String contentClusterId){
        List<VisibilityOptionWrapper> clusterWrapperList = new List<VisibilityOptionWrapper>();
        for(Cluster__c cluster : clusters){
            clusterWrapperList.add(new VisibilityOptionWrapper(cluster.name, cluster.Id, (cluster.id == contentClusterId)));
        }
        return new VisibilitySelectorWrapper('Cluster', 'Cluster__c', false, clusterWrapperList);
    }

    private static Content__c getContentData(String recordId){
        String contentFields = getContentFields();
        Content__c content = Database.query('SELECT (SELECT Tag__c FROM Tags__r),(SELECT MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE placement__c LIKE \'%ImageList\'),RecordType.Name,RecordType.DeveloperName,' 
                                            + contentFields + ' FROM Content__c WHERE id = :recordId');
        return content;
    }

    private static VisibilitySelectorWrapper getCategorySelectorWrapper(Set<Id> clusterIds, String contentCategoryId){
        List<Category__c> categories = [SELECT id, name FROM Category__c WHERE Cluster__c IN :clusterIds];
        List<VisibilityOptionWrapper> categoryWrapperList = new List<VisibilityOptionWrapper>();
        for(Category__c category : categories){
            VisibilityOptionWrapper categoryWrapper;  
            if(category.id == contentCategoryId){
                categoryWrapper = new VisibilityOptionWrapper(category.name, category.Id, true);
            }else{
                categoryWrapper = new VisibilityOptionWrapper(category.name, category.Id, false);
            }
            categoryWrapperList.add(categoryWrapper);
        }
        VisibilitySelectorWrapper categorySelectorWrapper = new VisibilitySelectorWrapper('Category', 'Category__c', false, categoryWrapperList);
        return categorySelectorWrapper;
    }

    private static VisibilitySelectorWrapper getTagSelectorWrapper(Set<Id> clusterIds, Set<Id> tagIds, Boolean hasEditAccess){
        List<Tag__c> tags;
        if(hasEditAccess)
        	tags = [SELECT id, name FROM Tag__c WHERE Cluster__c IN :clusterIds];
        else
        	tags = [SELECT id, name FROM Tag__c WHERE Id IN :tagIds];

        List<VisibilityOptionWrapper> tagWrapperList = new List<VisibilityOptionWrapper>();
        for(Tag__c tag : tags){
            VisibilityOptionWrapper tagWrapper;  
            if(tagIds.contains(tag.Id)){
                tagWrapper = new VisibilityOptionWrapper(tag.name, tag.Id, true);
            }else{
                tagWrapper = new VisibilityOptionWrapper(tag.name, tag.Id, false);
            }
            tagWrapperList.add(tagWrapper);
        }
        VisibilitySelectorWrapper categorySelectorWrapper = new VisibilitySelectorWrapper('Tags', 'Tag__c', true, tagWrapperList);
        return categorySelectorWrapper;
    }

    private static Set<Id> getClusterBranch(){
        List<ClusterUser__c> clusterUser = [SELECT Cluster__c FROM ClusterUser__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        if(!clusterUser.isEmpty()){
            Set<Id> clusters =  ClusterUtils.getEntireClusterBranch(clusterUser.get(0).cluster__c);
            return clusters;
        }
        return null;
    }

    private static String getContentFields(){
        String commaSeparatedFields = '';
        Set<String> fieldNames = GeneralUtils.getObjectFieldNames('Content__c');
        commaSeparatedFields = String.join(new List<String>(fieldNames), ',');
        return commaSeparatedFields;
    }

    @AuraEnabled
    public static Boolean saveContent(Content__c content, String visibilitySelectorsString, String mediaElementId, String status, List<TagAssignment__c> contentOldTagAssignments){
        Savepoint sp = Database.setSavepoint();
        try{
            List<VisibilitySelectorWrapper> visibilitySelectors = (List<VisibilitySelectorWrapper>)JSON.deserialize(visibilitySelectorsString, List<VisibilitySelectorWrapper>.class);
            content = updateContent(content, visibilitySelectors, status);
            updateTagAssignments(content, getSelectorByApiName(visibilitySelectors, 'Tag__c'), contentOldTagAssignments);
            if(mediaElementId != null)
                updateMediaElementAssignment(content, mediaElementId);
            return true;
        }catch(DMLException e){
            Database.rollback(sp);
            System.debug(e.getMessage() + ' Error during content upsert process, rolling back');
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }catch(Exception e){
            Database.rollback(sp);
            System.debug(e.getMessage() + ' Error during content upsert process, rolling back');
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(label.NewsContentDetailError);
        }        
    }

    private static void updateMediaElementAssignment(Content__c content, String mediaElementId){

        Boolean MEAAlreadyCreated = false;
        String meListPlacement = content.recordType.name + 'ImageList';
        String meDetailPlacement = content.recordType.name + 'ImageDetail';
        if(content.id != null){
            List<MediaElementAssignment__c> MEAToDelete = new List<MediaElementAssignment__c>();
            List<MediaElementAssignment__c> oldMediaElementAssignments = [SELECT id, mediaElement__c FROM MediaElementAssignment__c WHERE Content__c = :content.id AND (placement__c = :meListPlacement OR placement__c = :meDetailPlacement)];
            for(MediaElementAssignment__c mea : oldMediaElementAssignments){
                if(mea.mediaElement__c != mediaElementId){
                    MEAToDelete.add(mea);
                }else{
                    MEAAlreadyCreated = true;
                }
            }
            delete MEAToDelete;
        }
        if(!MEAAlreadyCreated){
            MediaElementAssignment__c mediaelementAssignmentList = new MediaElementAssignment__c(content__c = content.id, mediaElement__c = mediaElementId, placement__c = meListPlacement);
            MediaElementAssignment__c mediaelementAssignmentDetail = new MediaElementAssignment__c(content__c = content.id, mediaElement__c = mediaElementId, placement__c = meDetailPlacement);
            List<MediaElementAssignment__c> MEAToCreate = new List<MediaElementAssignment__c>{mediaelementAssignmentList, mediaelementAssignmentDetail};
            insert MEAToCreate;
        }
    }

    private static void updateTagAssignments(Content__c content, VisibilitySelectorWrapper tagVisibility, List<TagAssignment__c> contentOldTagAssignments){
        Map<String, String> tagToTagAssignment = new Map<String, String>();
        List<TagAssignment__c> tagAssignmentsToDelete = new List<TagAssignment__c>();
        List<TagAssignment__c> tagAssignmentsToCreate = new List<tagAssignment__c>();
        if(contentOldTagAssignments != null){
            for(TagAssignment__c tagAssignment : contentOldTagAssignments){
                tagToTagAssignment.put(tagAssignment.Tag__c, tagAssignment.Id);
            }
        }
        
        for(VisibilityOptionWrapper tagOption : tagVisibility.values){
            if(tagOption.isSelected){
                //If a new tag is being added to the content
                if(tagToTagAssignment.get(tagOption.id) == null){
                    tagAssignmentsToCreate.add(new TagAssignment__c(Content__c = content.id, Tag__c = tagOption.id));
                }
            }else{
                //If a tag was removed from the content
                if(tagToTagAssignment.get(tagOption.id) != null){
                    tagAssignmentsToDelete.add(new TagAssignment__c(id=tagToTagAssignment.get(tagOption.id)));
                }
            }
        }
        if(!tagAssignmentsToCreate.isEmpty()){
            insert tagAssignmentsToCreate;
        }
        if(!tagAssignmentsToDelete.isEmpty()){
            delete tagAssignmentsToDelete;
        }

    }

    private static Content__c updateContent(Content__c content, List<VisibilitySelectorWrapper> visibilitySelectors, String status){
        VisibilitySelectorWrapper categorySelector = getSelectorByApiName(visibilitySelectors, 'Category__c');
        System.debug('categorySelector: ' + JSON.serialize(categorySelector));
        
        for(VisibilityOptionWrapper category : categorySelector.values){
            if(category.isSelected){
                content.Category__c = category.id;
                break;
            }
        }
        content.Status__c 	= status;
        update content;
        return content;
    }

    private static VisibilitySelectorWrapper getSelectorByApiName(List<VisibilitySelectorWrapper> visibilitySelectorList, String apiName){
        for(VisibilitySelectorWrapper visibilitySelector : visibilitySelectorList){
            if(visibilitySelector.apiName == apiName){
                return visibilitySelector;
            }
        }
        return null;
    }

    //SECURITY METHODS

    private static Boolean hasCreateContentPermission(){
        return Schema.sObjectType.Content__c.isCreateable();
    }

    private static Boolean hasEditAccess(String recordId){
        UserRecordAccess ura = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        return ura.HasEditAccess;
    }

    private static Boolean hasRecordTypeAvailable(String recordTypeDeveloperName){
        return Schema.SObjectType.Content__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).isAvailable();
    }

}