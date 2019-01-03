@isTest(seeAllData = false)
public with sharing class ContentTriggersTest {

	@isTest 
	static void insertContentTest(){
		/* Comment: Comprueba que al crear un Content__c se inserta
		con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');

		//When
		Test.startTest();
		List<Content__c> contentTest = MockupFactory.createContent('Banner', clusterArg[0], 1);
		Test.stopTest();

		//Then
		Content__c contentTestResult =[SELECT ExternalId__c FROM Content__c WHERE Id =: contentTest[0].Id];
		System.assertNotEquals(contentTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateContentTest(){
		/* Comment: Comprueba que al actualizar un Content__c se actualiza
		con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterArg = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
		List<Content__c> contentTest = MockupFactory.createContent('Banner', clusterArg[0], 1);
		contentTest[0].ExternalId__c = null;
		contentTest[0].Name = 'Content Test 02';

		//When
		Test.startTest();
		update(contentTest);
		Test.stopTest();

		//Then
		Content__c contentTestResult2 =[SELECT ExternalId__c FROM Content__c WHERE Id =: contentTest[0].Id];
		System.assertNotEquals(contentTestResult2.ExternalId__c, null);
	}

	@isTest
	static void insertComponentSharing()
	{
		/*
		Valida la creacion de las Manual Sharing al moemnto de crear un Tag*/

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		//System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		
		// When
		Test.startTest();
		List<Content__c> contentList = MockupFactory.createContent('Banner', getClusterList[0], 1);
		Test.stopTest();

		// Then
		List<Content__Share> shareList = [SELECT Id, ParentId FROM Content__Share WHERE ParentId = :contentList[0].Id AND RowCause = 'Clustering__c'];

		System.assertEquals(3, shareList.size());

	}


	@isTest
	static void updateNavigationSharing(){
		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 2, 'ClusterRoot');
		List<Cluster__c> getClusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 2 ];
		System.debug('ClusterTriggersTest method getClusterList: '+getClusterList);
		
		List<Content__c> contentList = MockupFactory.createContent('Banner', getClusterList[0], 1);
		List<Content__c> getContentList = [SELECT Id, Name FROM Content__c WHERE Name LIKE 'Banner%'];
		System.debug('ClusterTriggersTest method getContentList: '+getContentList);

		Content__c getContenToUpdate = getContentList[0];
		getContenToUpdate.Cluster__c = getClusterList[1].Id;
		List<Content__c> contenToUpdateList = new List<Content__c>{getContenToUpdate};
		System.debug('ClusterTriggersTest method contenToUpdateList: '+contenToUpdateList);
		// When
		Test.startTest();
		update contenToUpdateList;
		Test.stopTest();


		System.debug('ClusterTriggersTest method contenToUpdateList: '+contenToUpdateList);

		// Then
		List<Content__Share> shareList = [SELECT Id, ParentId FROM Content__Share WHERE ParentId = :contenToUpdateList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(6, shareList.size());

	}
}