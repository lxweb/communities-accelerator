@isTest
private class FE_ClusterSelectorControllerTest {

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf');
        List<Component__c> componentList = MockupFactory.createComponent('Cluster Selector', 1, clusterRoot[0]);
		
	}

	@isTest 
	static void getComponentWrapperTest() {
		// Given
		List<Component__c> componentList = [SELECT Id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];
		
		// When
		Test.startTest();
		FE_ComponentManager.ComponentWrapper componentWr = FE_ClusterSelectorController.getComponentWrapper(null, componentList[0].Id, 'Desktop');
		Test.stopTest();

		// Then
		System.assertNotEquals(componentWr, null);
		System.assertNotEquals(componentWr.data, null);
	}	

	@isTest 
	static void getClusterRootByComponentIdTest() {
		// Given
		List<Component__c> componentList = [SELECT Id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];
		
		// When
		Test.startTest();
		FE_ComponentManager.ComponentWrapper componentWr = FE_ClusterSelectorController.getComponentWrapper(null, componentList[0].Id, 'Desktop');
		Test.stopTest();

		// Then
		System.assertNotEquals(componentWr, null);
	}

	@isTest 
	static void getClusterRootByExternalIdTest() {
		// Given
		List<Component__c> componentList = [SELECT Id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];
		
		// When
		Test.startTest();
		FE_ComponentManager.ComponentWrapper componentWr = FE_ClusterSelectorController.getComponentWrapper(componentList[0].ExternalId__c, null, 'Desktop');
		Test.stopTest();

		// Then
		System.assertNotEquals(componentWr, null);
	}

	@isTest 
	static void getClusterRedirectTest() {
		// Given
		List<Component__c> componentList = [SELECT Id, ExternalId__c, Cluster__c FROM Component__c LIMIT 1];
		List<Navigation__c> navigationList = MockupFactory.createNavigation('NavigationTest', 'www.google.com', 1, componentList[0].Cluster__c);

		// When
		Test.startTest();
		FE_ComponentManager.ComponentWrapper componentWr = FE_ClusterSelectorController.getComponentWrapper(null, componentList[0].Id, 'Desktop');
		String url = FE_ClusterSelectorController.getClusterRedirect(navigationList[0].Id);
		Test.stopTest();

		// Then
		System.assertEquals(url, 'www.google.com');
	}	
}