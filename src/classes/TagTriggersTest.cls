@isTest(seeAllData = false)
public with sharing class TagTriggersTest {

	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}


	@isTest 
	static void insertTagTest(){
		/* Comment: Comprueba que al crear un tag__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		Tag__c tagTest = new Tag__c(Name='Tag Test 01');

		//When
		Test.startTest();
			insert(tagTest);
		Test.stopTest();

		//Then
		Tag__c tagTestResult =[select id, ExternalId__c from Tag__c where id =: tagTest.id];
		System.assertNotEquals(tagTestResult.ExternalId__c, null);
	}

	@isTest
	static void updatetagTest(){
		/* Comment: Comprueba que al actualizar un tag__c se actualiza
		con el correspondiente ExternalId__c */
		
		//Given
		Tag__c tagTest = new Tag__c(Name='Tag Test 01');
		insert(tagTest);
		tagTest.ExternalId__c = null;
		tagTest.Name = 'tagl Test 02';
		//When
		Test.startTest();
			update(tagTest);
		Test.stopTest();

		//Then
		Tag__c tagTestResult2 =[select id, ExternalId__c from Tag__c where id =: tagTest.id];
		System.assertNotEquals(tagTestResult2.ExternalId__c, null);
	}

	@isTest
	static void insertTagSharing()
	{
		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		// When
		Test.startTest();
		List<Tag__c> tagList = MockupFactory.createTag('TagTest1', 'Test Tag', 1,clusterList[0].Id);
		Test.stopTest();
		System.debug('ClusterTriggersTest method tagList: '+tagList);

		// Then
		List<Tag__Share> shareList = [SELECT Id, ParentId FROM Tag__Share WHERE ParentId = :tagList[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(3, shareList.size());

	}

	@isTest 
	static void insertAnotherTagTest(){
		
		/* Comment: Comprueba que al crear un Category__c se inserta existiendo otro Category__c
			para el mismo Cluster__c */

		//Given
		Tag__c tagTest = new Tag__c(Name='Tag Test 01');
		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup');
        Cluster__c cgGr = clusterList[0];
        tagTest.Cluster__c=cgGr.Id;
        
		insert(tagTest);
		Tag__c tagTest2 = new Tag__c(Name='Category Test 02');
		tagTest2.Cluster__c=cgGr.Id;
		//When
		Test.startTest();
		insert(tagTest2);
		Test.stopTest();

		//Then
		Tag__c tagTestResult2 =[select id, ExternalId__c from Tag__c where id =: tagTest.id];
		System.assertNotEquals(tagTestResult2.ExternalId__c, null);
	}

}