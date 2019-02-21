@isTest
public class ContentSearchFiltersControllerTest {

    @isTest 
    static void getFiltersTest(){
        //Given
        MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf');
		MockupFactory.createCategory('Category', 2, clusterLeaf.get(0).id);
		MockupFactory.createClusterUser(clusterRoot.get(0).id, UserInfo.getUserId(), 1, 'Read/Write');
        MockupFactory.createTag('Tag Name', '', 2, clusterLeaf.get(0).id);
        MockupFactory.createContent('Event', clusterLeaf.get(0), 3);
        
		//When
		Test.startTest();
		List<ContentSearchFiltersController.FilterTypeWrapper> filters = ContentSearchFiltersController.getFilters();
		Test.stopTest();

		//Then
		System.assertEquals(filters.size(), 4);
        System.assertEquals(filters.get(0).values.size(), 4);
        List<RecordType> contentRecordTypes = [SELECT id FROM RecordType WHERE SObjectType = 'Content__c'];
        System.assertEquals(filters.get(1).values.size(), contentRecordTypes.size());
        System.assertEquals(filters.get(2).values.size(), 2);
        System.assertEquals(filters.get(3).values.size(), 2);
    }
}