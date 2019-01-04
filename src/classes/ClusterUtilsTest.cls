@isTest
public class ClusterUtilsTest {

    @testSetup
	static void setup(){
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('Test Cluster Root', null, 1, 'ClusterRoot');
        List<Cluster__c> clustersLevel2 = MockupFactory.createCluster('Test Cluster Level 2', clusterRoot.get(0).Id, 2, 'ClusterGroup');
        Set<Id> level2Ids = (new Map<Id, SObject>(clustersLevel2)).keySet();
        List<Cluster__c> clustersLevel3 = MockupFactory.createCluster('Test Cluster Level 3', new List<Id>(level2Ids), 2, 'ClusterGroup', 'es', 'en_US');
        Set<Id> level3Ids = (new Map<Id, SObject>(clustersLevel3)).keySet();
        List<Cluster__c> clustersLeaf = MockupFactory.createCluster('Test Cluster Leaf', new List<Id>(level3Ids), 2, 'ClusterLeaf', 'es', 'en_US');
    }

    @isTest
    static void getClustersParentsTest(){
        //Given
        // Scenario in test setup, a 4 level cluster tree.
        
        //When
        List<Set<String>> parentIds = new List<Set<String>>();
        for (Cluster__c cluster : [SELECT Id FROM Cluster__c WHERE name LIKE 'Test Cluster Leaf%']){
            parentIds.add(ClusterUtils.getClustersParents(cluster.Id));
        }

        //Then
        for (Set<String> setOfIds : parentIds){
            system.assertEquals(4, setOfIds.size());
        }
    }

    @isTest
    static void getClustersBelowTest(){
        //Given
        Cluster__c clusterRoot = [SELECT Id FROM Cluster__c WHERE name LIKE 'Test Cluster Root%' LIMIT 1];
        Cluster__c clusterLevel2 = [SELECT Id FROM Cluster__c WHERE name LIKE 'Test Cluster Level 2%' LIMIT 1];
        Cluster__c clusterLevel3 = [SELECT Id FROM Cluster__c WHERE name LIKE 'Test Cluster Level 3%' LIMIT 1];
        Cluster__c clusterLeaf = [SELECT Id FROM Cluster__c WHERE name LIKE 'Test Cluster Leaf%' LIMIT 1];

        //When
        ClusterUtils.ClusterWrapper clusterRootRealtedClusters = ClusterUtils.getClustersBelow(clusterRoot.Id);
        ClusterUtils.ClusterWrapper clusterLevel2RealtedClusters = ClusterUtils.getClustersBelow(clusterLevel2.Id);
        ClusterUtils.ClusterWrapper clusterLevel3RealtedClusters = ClusterUtils.getClustersBelow(clusterLevel3.Id);
        ClusterUtils.ClusterWrapper clusterLeafRealtedClusters = ClusterUtils.getClustersBelow(clusterLeaf.Id);

        //Then
        system.assertEquals(2, clusterRootRealtedClusters.relatedClusters.size());
        system.assertEquals(2, clusterLevel2RealtedClusters.relatedClusters.size());
        system.assertEquals(2, clusterLevel3RealtedClusters.relatedClusters.size());
        system.assert(clusterLeafRealtedClusters.relatedClusters.isEmpty());
    }
    
    @isTest
    static void getClusterIdFromMappingObjectTest(){
        //Given
        // User u = [SELECT Id FROM User WHERE username = 'test_user@test.com' LIMIT 1];

        //When
        String result = ClusterUtils.getClusterIdFromMappingObject('', '');
        //Then
        system.assertEquals(null, result);
    }

    @isTest
    static void getClusterRootFromNetworkTest(){
        //Given

        //When
        Cluster__c cluster = ClusterUtils.getClusterRootFromNetwork();

        //Then
        system.assertEquals(null, cluster);
    }

}