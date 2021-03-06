@isTest
private class FE_AdvanceContentControllerTest {
	
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf');
        List<Component__c> componentList = MockupFactory.createComponent('Advance Content', 1, clusterRoot[0]);
		List<Content__c> contentList = MockupFactory.createContent('Advance Content', clusterRoot[0], 1);
		MockupFactory.createContentAssignment(contentList, componentList);
        MockupFactory.createMediaElement(1);       
	}

	@isTest 
	static void getComponentWrapperTest() {
		// Given
		List<Component__c> componentList = [SELECT id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];
		List<Content__c> contentList = [SELECT id, HTMLContent__c FROM Content__c LIMIT 1];
		contentList[0].HTMLContent__c = 'Html Advance Content Test';
		update contentList;

		//Navigation Record
        Navigation__c nav = new Navigation__c(Name = 'NavTest', URL__c = 'testNav');
        insert nav;

		// When
		Test.startTest();
		FE_ComponentManager.ComponentWrapper componentWr = FE_AdvanceContentController.getComponentWrapper(componentList[0].ExternalId__c, componentList[0].Cluster__c, 'Desktop','s/testNav');
		Test.stopTest();

		// Then
		System.assertNotEquals(componentWr, null);
		System.assertNotEquals(componentWr.data, null);
	}	
}