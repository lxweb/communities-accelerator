@isTest(seeAllData = false)
public with sharing class ComponentTriggersTest {

	@isTest 
	static void insertComponentTest(){
		/* Comment: Comprueba que al crear un Component__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		Component__c componentTest = new Component__c(Name='Component Test 01');

		//When
		Test.startTest();
			insert(componentTest);
		Test.stopTest();

		//Then
		Component__c componentTestResult =[select id, ExternalId__c from Component__c where id =: componentTest.id];
		System.assertNotEquals(componentTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateComponentTest(){
		/* Comment: Comprueba que al actualizar un Component__c se actualiza
		con el correspondiente ExternalId__c */
		
		//Given
		Component__c componentTest = new Component__c(Name='Component Test 01', 
									OrderBy__c = 'Custom Sorting', 
									OrderByAdvance__c = 'CreatedDate');
		insert(componentTest);
		componentTest.ExternalId__c = null;
		componentTest.Name = 'Component Test 02';
		//When
		Test.startTest();
			update(componentTest);
		Test.stopTest();

		//Then
		Component__c componentTestResult2 =[select id, ExternalId__c from Component__c where id =: componentTest.id];
		System.assertNotEquals(componentTestResult2.ExternalId__c, null);
	}

	@isTest
	static void checkIfClusterWasChangedInComponent(){
		//PA-206 Governance de Componentes(Reparenting)
		/*Comment: Comprueba que al modificar el Cluster, el componente no tenga 
		Contenidos, Tags o Categorias relacionadas con el Componente*/
		
		//Given
		MockupFactory.generateAcceleratorSetting();
		String nameRecordType = 'Banner';
		Cluster__c clusterTest1 = new Cluster__c(Name = 'Cluster Test 1', ExternalId__c = 'ClusterTest1');
		insert (clusterTest1);
		Cluster__c clusterTest2 = new Cluster__c(Name = 'Cluster Test 2', ExternalId__c = 'ClusterTest2');
		insert (clusterTest2);
		List<Component__c> componentListTest = MockupFactory.createComponent(nameRecordType, 1);
		List<Content__c> contentListTest = MockupFactory.createContent(nameRecordType, clusterTest1, 1);
		List<ContentAssignment__c> contentAssignmentListTest = MockupFactory.createContentAssignment(contentListTest, componentListTest);

		//When
		Test.startTest();
		Component__c[] componentTest = [SELECT Id, Cluster__c FROM Component__c WHERE Name = 'Banner'];
		if(componentTest.size() > 0){
			componentTest[0].Cluster__c = clusterTest2.Id;	
		}
		update(componentTest);
		Test.stopTest();
		
		//Then
		Component__c componentTestResult3 = [SELECT Id, Cluster__c FROM Component__c WHERE Id =: componentListTest]; 
		System.assertNotEquals(componentTestResult3.Cluster__c,clusterTest2.Id);
	}

	@isTest
	static void insertComponentSharing()
	{
		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Cluster__c> clusterList = [SELECT Id, Name FROM Cluster__c WHERE Name LIKE 'ClusterRootTest%' LIMIT 1 ];
		System.debug('ClusterTriggersTest method clusterList: '+clusterList);
		String nameRecordType = 'Banner';
		// When
		Test.startTest();
		List<Content__c> contentListTest = MockupFactory.createContent(nameRecordType, clusterList[0], 1);
		Test.stopTest();


		System.debug('ClusterTriggersTest method contentListTest: '+contentListTest);

		// Then
		List<Component__Share> shareList = [SELECT Id, ParentId FROM Component__Share WHERE ParentId = :contentListTest[0].Id AND RowCause = 'Clustering__c'];
		System.debug('ClusterTriggersTest method shareList: '+shareList);

		System.assertEquals(3, shareList.size());

	}
}