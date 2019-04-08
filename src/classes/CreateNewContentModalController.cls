public with sharing class CreateNewContentModalController {

    //SAVE RESPONSE WRAPPER
    public class SaveResponseWrapper {
        @auraEnabled public Boolean isSuccess;
        @auraEnabled public String message;

        public SaveResponseWrapper(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(String recordTypeId){
        return Schema.SObjectType.Content__c.getRecordTypeInfosById().get(recordTypeId).getName();
    }

    @AuraEnabled
    public static SaveResponseWrapper createNewContent(String recordTypeId, Boolean isTemplate, String componentId, String navigationUrl, String recordName, String clusterId){
        Content__c newContent = new Content__c(
            Name = recordName.left(60),
            RecordTypeId = recordTypeId,
            IsTemplate__c = isTemplate,
            StructureComponent__c = componentId,
            StructureNavigation__c = getNavigationByUrl(navigationUrl),
            Cluster__c = clusterId
        );
        try{
            insert newContent;
            return new SaveResponseWrapper(true,newContent.Id);
        }catch(DMLException e){
            System.debug(e.getMessage() + ' Error during new content creation');
            System.debug(e.getStackTraceString());
            return new SaveResponseWrapper(false, e.getDMLMessage(0));
        }catch(Exception e){
            System.debug(e.getMessage() + ' Error during content upsert process, rolling back');
            System.debug(e.getStackTraceString());
            return new SaveResponseWrapper(false, 'error when creating new record');
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getClusters(){
        // Prepare results
        List<LookupSearchResult>    results     = new List<LookupSearchResult>();
        List<Cluster__c>            clusters    = ClusterUtils.getClustersBelowList(getClusterUserId());
        String                      clusterIcon = 'custom:custom26';

        for (Cluster__c cluster : clusters) {
            results.add(new LookupSearchResult(cluster.Id, 'Cluster__c', clusterIcon, cluster.Name, cluster.ExternalId__c + ' • '+ cluster.RecordType.Name));
        }

        return JSON.serialize(results);
    }

    public static Id getClusterUserId(){
        List<ClusterUser__c> clusterUser = [SELECT Id, Cluster__c FROM ClusterUser__c WHERE User__c =:UserInfo.getUserId()];
        if(clusterUser.size() == 0)
            throw new AuraException('You have no cluster associated');
        return clusterUser.get(0).Cluster__c;
    }

    public static Id getNavigationByUrl(String url){
        List<Navigation__c> navs = [SELECT Id FROM Navigation__c WHERE URL__c = :url];
        if(!navs.isEmpty())
            return navs.get(0).Id;

        return null;
    }

}