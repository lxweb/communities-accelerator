@isTest
private class NavigationTriggersTest
{

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}
	
	@isTest
	static void insertTagSharing()
	{
		

		// Given
		//List<String> clustersList = new List<String>();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);

		// When
		Test.startTest();
		List<Navigation__c> tagList = MockupFactory.createNavigation('navTest1', 'Url.com', 1,clusterList[0].Id);
		
		Test.stopTest();
		System.debug('ClusterTriggersTest method tagList: '+tagList);

		// Then
		List<Navigation__Share> shareList = [SELECT Id, ParentId FROM Navigation__Share WHERE ParentId = :tagList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(3, shareList.size());

	}
}