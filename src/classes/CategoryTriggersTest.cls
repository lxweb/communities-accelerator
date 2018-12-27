@isTest(seeAllData = false)
public with sharing class CategoryTriggersTest {
	@isTest 
	static void insertCategoryTest(){
		/* Comment: Comprueba que al crear un Category__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		MockupFactory.generateAcceleratorSetting();

		Category__c categoryTest = new Category__c(Name='Category Test 01');
		String name = 'Argentina';
        String nameGroup = 'Buenos Aires';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(nameGroup, cg.Id, 1, 'ClusterGroup');
        Cluster__c cgGr = clusterList[0];
        categoryTest.Cluster__c=cgGr.Id;
		//When
		Test.startTest();
			insert(categoryTest);
		Test.stopTest();

		//Then
		Category__c catTestResult =[select id, ExternalId__c from Category__c where id =: categoryTest.id];
		System.assertNotEquals(catTestResult.ExternalId__c, null);
	}	

	@isTest 
	static void updateCategoryTest(){
		/* Comment: Comprueba que al crear un Category__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		Category__c categoryTest = new Category__c(Name='Category Test 01');
		insert(categoryTest);
		categoryTest.ExternalId__c = null;
		categoryTest.Name = 'Category Test 02';
		//When
		Test.startTest();
			update(categoryTest);
		Test.stopTest();

		//Then
		Category__c catTestResult2 =[select id, ExternalId__c from Category__c where id =: categoryTest.id];
		System.assertNotEquals(catTestResult2.ExternalId__c, null);
	}
	
}