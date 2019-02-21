public class ContentSearchFiltersController {

    public static final String FILTER_TYPE_CLUSTER_TYPE = 'Cluster';

    //FILTER WRAPPER
    public class FilterTypeWrapper {
        @auraEnabled public String name;
        @auraEnabled public List<FilterWrapper> values;

        public FilterTypeWrapper(String name, List<FilterWrapper> values){
            this.name = name;
            this.values = values;
        }
    }
    //FILTER VALUE WRAPPER
    public class FilterWrapper {
        @auraEnabled public String label;
        @AuraEnabled public String value;

        public FilterWrapper(String label, string value){
            this.label = label;
            this.value = value;
        }
    }
    

    @AuraEnabled
    public static List<FilterTypeWrapper> getFilters (){
        Set<Id> clusterIds = getCurrentUserClusterTree();
        List<Cluster__c> clusterList = [SELECT ExternalId__c, Name FROM Cluster__c WHERE id IN :clusterIds];
        List<RecordType> contentTypeList = [SELECT Name FROM RecordType WHERE sObjectType = 'Content__c'];
        List<Category__c> categoryList = [SELECT ExternalId__c, Name FROM Category__c WHERE Cluster__c IN :clusterIds];
        List<Tag__c> tagList = [SELECT ExternalId__c, Name FROM Tag__c WHERE Cluster__c IN :clusterIds];
    
        List<FilterWrapper> clusters = getClusterWrapperList(clusterList);
        List<FilterWrapper> contentTypes = getContentTypeWrapperList(contentTypeList);
        List<FilterWrapper> categories = getCategoryWrapperList(categoryList);
        List<FilterWrapper> tags = getTagWrapperList(tagList);

        List<FilterTypeWrapper> filters = new List<FilterTypeWrapper>();
        filters.add(new FilterTypeWrapper(System.Label.SearchContentClusterFilter, clusters));
        filters.add(new FilterTypeWrapper(System.Label.SearchContentTypeFilter, contentTypes));
        filters.add(new FilterTypeWrapper(System.Label.SearchContentCategoryFilter, categories));
        filters.add(new FilterTypeWrapper(System.Label.SearchContentTagFilter, tags));
        return filters;
    }

    private static List<FilterWrapper> getClusterWrapperList(List<Cluster__c> clusterList){
        List<FilterWrapper> clusters = new List<FilterWrapper>();
        for(Cluster__c cluster : clusterList){
            FilterWrapper clusterWrapper = new FilterWrapper(cluster.name, cluster.ExternalId__c);
            clusters.add(clusterWrapper);
        }
        return clusters;
    }

    private static List<FilterWrapper> getContentTypeWrapperList(List<RecordType> contentTypeList){
        List<FilterWrapper> contentTypes = new List<FilterWrapper>();
        for(RecordType contentType : contentTypeList){
            FilterWrapper contentTypeWrapper = new FilterWrapper(contentType.name, contentType.name);
            contentTypes.add(contentTypeWrapper);
        }
        return contentTypes;
    }

    private static List<FilterWrapper> getCategoryWrapperList(List<Category__c> categoryList){
        List<FilterWrapper> categories = new List<FilterWrapper>();
        for(Category__c category : categoryList){
            FilterWrapper categoryWrapper = new FilterWrapper(category.name, category.ExternalId__c);
            categories.add(categoryWrapper);
        }
        return categories;
    }

    private static List<FilterWrapper> getTagWrapperList(List<Tag__c> tagList){
        List<FilterWrapper> tags = new List<FilterWrapper>();
        for(Tag__c tag : tagList){
            FilterWrapper tagWrapper = new FilterWrapper(tag.name, tag.ExternalId__c);
            tags.add(tagWrapper);
        }
        return tags;
    }

    private static Set<Id> getCurrentUserClusterTree(){
        
        List<ClusterUser__c> clusterUser = [SELECT Cluster__c FROM ClusterUser__c WHERE User__c = :UserInfo.getUserId() LIMIT 1];
        if(!clusterUser.isEmpty()){
            Set<Id> clusters =  ClusterUtils.getEntireClusterBranch(clusterUser.get(0).Cluster__c);
            return clusters;
        }
        return null;
        
    }
    
}