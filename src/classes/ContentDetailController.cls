public with sharing class ContentDetailController {
    //DATA WRAPPER
    public class DataWrapper{
        @AuraEnabled public Content__c                      content;
        @AuraEnabled public List<VisibilitySelectorWrapper> visibilitySelectors;
        @AuraEnabled public String                          timeZone;
        @AuraEnabled public SecurityWrapper                 security;
        @AuraEnabled public List<String>                    bannerFrameTypes;
        
        public DataWrapper(Content__c content, SecurityWrapper security, List<VisibilitySelectorWrapper> visibilitySelectors, String timeZone, List<String> bannerFrameTypes){
            this.content                = content;
            this.visibilitySelectors    = visibilitySelectors;
            this.security               = security;
            this.timeZone               = timeZone;
            this.bannerFrameTypes       = bannerFrameTypes;
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
        @AuraEnabled public String                          label;
        @AuraEnabled public String                          apiName;
        @AuraEnabled public Boolean                         isMultiPicklist;
        @AuraEnabled public List<VisibilityOptionWrapper>   values;
        @AuraEnabled public String                          selectedValue;
        @AuraEnabled public String                          placeholder;

        public VisibilitySelectorWrapper(String label, String apiName, Boolean isMultiPicklist, List<VisibilityOptionWrapper> values, String selectedValue, String placeholder){
            this.label              = label;
            this.apiName            = apiName;
            this.isMultiPicklist    = isMultiPicklist;
            this.values             = values;
            this.selectedValue      = selectedValue;
            this.placeholder        = placeholder;
        }
    }

    //VISIBILITY OPTION WRAPPER
    public class VisibilityOptionWrapper {
        @AuraEnabled public String  label;
        @AuraEnabled public String  value;
        @AuraEnabled public Boolean isSelected;

        public VisibilityOptionWrapper(String label, string value, Boolean isSelected){
            this.label      = label;
            this.value      = value;
            this.isSelected = isSelected;
        }
    }

    @AuraEnabled
    public static DataWrapper getData(String recordId){
        DataWrapper data;
        try{
            //Gets the data from the current content.
            Content__c contentRecord = getContentData(recordId);
            //Gets the entire cluster branch of the current user.
            Set<Id> clusterIds = getClusterBranch(contentRecord.Cluster__c);
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
            List<String> bannerFrameTypes = getBannerFrameTypes();

            data = new DataWrapper(contentRecord, sw, visibilitySelectorList, UserInfo.getTimeZone().getID(), bannerFrameTypes);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return data;
    }

    private static Set<Id> getTagsFromContentRecord(Content__c content){
        Set<Id> tagIds = new Set<Id>();
        for(TagAssignment__c tagAssignment : content.tags__r){
            tagIds.add(tagAssignment.Tag__c);
        }
        return tagIds;
    }

    private static Content__c getContentData(String recordId){
        String contentFields = getContentFields();
        Content__c content = Database.query('SELECT (SELECT Tag__c FROM Tags__r),(SELECT MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE placement__c LIKE \'%ImageList\'),RecordType.Name,RecordType.DeveloperName,' 
                                            + contentFields + ' FROM Content__c WHERE id = :recordId');
        content.Body__c = externalIdToUrl(content.Body__c);
        return content;
    }

    private static VisibilitySelectorWrapper getCategorySelectorWrapper(Set<Id> clusterIds, String contentCategoryId){
        List<Category__c> categories = [SELECT id, name FROM Category__c WHERE Cluster__c IN :clusterIds];
        List<VisibilityOptionWrapper> categoryWrapperList = new List<VisibilityOptionWrapper>();
        String selectedValue = null;
        for(Category__c category : categories){
            VisibilityOptionWrapper categoryWrapper;  
            if(category.id == contentCategoryId){
                categoryWrapper = new VisibilityOptionWrapper(category.name, category.Id, true);
                selectedValue = category.Id;
            }else{
                categoryWrapper = new VisibilityOptionWrapper(category.name, category.Id, false);
            }
            categoryWrapperList.add(categoryWrapper);
        }
        VisibilitySelectorWrapper categorySelectorWrapper = new VisibilitySelectorWrapper('Category', 'Category__c', false, categoryWrapperList, selectedValue, Label.ComboboxCategoryPlaceholder);
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
        VisibilitySelectorWrapper categorySelectorWrapper = new VisibilitySelectorWrapper('Tags', 'Tag__c', true, tagWrapperList, null, Label.MultiComboboxTagPlaceholder);
        return categorySelectorWrapper;
    }

    private static Set<Id> getClusterBranch(Id clusterId){
        Set<Id> clusters = (Set<Id>)JSON.deserialize(JSON.serialize(ClusterUtils.getClustersParents(clusterId)), Set<Id>.class);
        return clusters;
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
                if(tagToTagAssignment.get(tagOption.value) == null){
                    tagAssignmentsToCreate.add(new TagAssignment__c(Content__c = content.id, Tag__c = tagOption.value));
                }
            }else{
                //If a tag was removed from the content
                if(tagToTagAssignment.get(tagOption.value) != null){
                    tagAssignmentsToDelete.add(new TagAssignment__c(id=tagToTagAssignment.get(tagOption.value)));
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
                content.Category__c = category.value;
                break;
            }
        }
        content.Body__c = urlToExternalId(content.Body__c);
        content.Status__c   = status;
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

    private static List<String> getBannerFrameTypes(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Content__c.BannerFrameType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }    
        return pickListValuesList;
    }

    private static String externalIdToUrl(String body){
        return body == null ? null : RichTextController.replaceExternalIdsWithURLs(body);
    }

    private static String urlToExternalId(String body){
        return body == null ? null : RichTextController.replaceURLsWithExternalIds(body);
    }
}
