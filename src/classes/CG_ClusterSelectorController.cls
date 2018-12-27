public with sharing class CG_ClusterSelectorController {


    //WRAPPER
    public class TreeWrapper {
        @auraEnabled public String label;
        @auraEnabled public String name;
        @auraEnabled public Boolean expanded;
        @auraEnabled public String clusterLanding;
        @auraEnabled public String clustertype;
        @auraEnabled public List<TreeWrapper> items;
        @auraEnabled public Boolean leafOnly;

        public TreeWrapper(ClusterUtils.ClusterWrapper p_clusterWrapper, Boolean leaf){
            leafOnly = leaf;
            if(p_clusterWrapper!= null && p_clusterWrapper.cluster!=null){
                this.label = p_clusterWrapper.cluster.Name;
                this.name = p_clusterWrapper.cluster.Id;
                this.expanded = (p_clusterWrapper.relatedClusters!=null && p_clusterWrapper.relatedClusters.size()>0);
                this.clusterLanding = p_clusterWrapper.cluster.ClusterLandingUrl__c;
                this.clustertype = p_clusterWrapper.cluster.RecordType.DeveloperName;
                items = new List<TreeWrapper>();
            }
        }
    }
    
    @AuraEnabled
    public static String getClusterRedirect (String clusterLandingUrl){
        String retURL = null;
        List<Navigation__c> queryResult = [SELECT Id, URL__c FROM Navigation__c WHERE Id =: clusterLandingUrl ];
        if(!queryResult.isEmpty()){
            retURL = queryResult[0].URL__c;
        }    
        return retURL;
    }
    
    @AuraEnabled
    public static TreeWrapper getClusterRoot(String externalId, String componentId){
        return externalId == null ? getClusterRootForComponent(componentId) : getClusterRootByExternalId(externalId);
    }
    
    @AuraEnabled
    public static TreeWrapper getClusterRootByExternalId(String externalId){
        System.debug('getClusterRootByExternalId');
        Boolean leafOnly=false;
        Cluster__c clusterRoot;
        Component__c component = CG_ClusterSelectorController.getComponent(externalId);
        List<Cluster__c> queryResult = new List<Cluster__c>();
        if(component!=null ){
            leafOnly= component.OnlyClusterLeaf__c;
            queryResult = [SELECT Id, MappingObject__c, MappingObjectField__c, MappingClusterField__c, ClusterLandingUrl__c, RecordType.DeveloperName 
                            FROM Cluster__c 
                            WHERE RecordType.DeveloperName in ('ClusterRoot','ClusterGroup') 
                                AND Id =: component.FirstCluster__c ];
        }
        if(!queryResult.isEmpty()){
            clusterRoot = queryResult[0];
        }else{
        //  clusterRoot = ClusterUtils.getClusterRootFromNetwork();
            return null;
        }
        ClusterUtils.ClusterWrapper clusterWrappper =ClusterUtils.getClustersBelow(clusterRoot.Id);
        TreeWrapper tree = CG_ClusterSelectorController.getTree(clusterWrappper, leafOnly);       
        return tree;
    }

    @AuraEnabled
    public static TreeWrapper getClusterRootForComponent(String componentId){
        System.debug('getClusterRootForComponent' + componentId);
        String clusterId = getComponentClusterId(componentId);
        Boolean leafOnly=false;
        ClusterUtils.ClusterWrapper clusterWrappper = ClusterUtils.getClustersBelow(clusterId);
        TreeWrapper tree = CG_ClusterSelectorController.getTree(clusterWrappper, leafOnly);     
        
        return tree;
    }
    
    public static String getComponentClusterId(String componentId){
        Boolean leafOnly=false;
        Component__c component = [SELECT Id, Cluster__c, ClusterExternalId__c FROM Component__c WHERE Id =: componentId LIMIT 1];
        return component.Cluster__c;
    }
       
    private static TreeWrapper getTree(ClusterUtils.ClusterWrapper clusterWrapper, Boolean leafOnly){
        if(clusterWrapper==null){
            return null;
        }
        TreeWrapper item = new TreeWrapper(clusterWrapper, (clusterWrapper.cluster.RecordType.DeveloperName.equalsIgnoreCase('ClusterLeaf'))?false:leafOnly);
        List<TreeWrapper> itemList = new List<TreeWrapper>();

        for (ClusterUtils.ClusterWrapper clusterW : clusterWrapper.relatedClusters) {
            itemList.add(CG_ClusterSelectorController.getTree(clusterW, leafOnly));
        }
        item.items.addAll(itemList); 
        return item;

    } 

    private static Component__c getComponent(String externalId){
        Component__c component = null;
        try{
            component = [SELECT FirstCluster__c, OnlyClusterLeaf__c 
                                        from Component__c where ExternalId__c =: externalId];
        }
        catch(Exception e){}
        return component;
    }

}