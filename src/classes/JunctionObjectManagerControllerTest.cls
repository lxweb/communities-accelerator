@isTest 
public with sharing class JunctionObjectManagerControllerTest {

	@isTest 
	static void findContent(){
		//Comment: Desde un componente Banner busco todos los registros de contenido, sin condiciones

		//Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global',null, 1,'ClusterRoot');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Content__c> cont = MockupFactory.createContent('Banner',cluster[0],1);
		List<ContentAssignment__c> contAssign = MockupFactory.createContentAssignment(cont,comp);

		//When 
		Test.startTest();
		JunctionObjectManagerController.RecordsWrapper rw = JunctionObjectManagerController.getRecords(comp[0].Id, 'ContentAssignment__c',  'Component__c', 'Content__c', null);
		Test.stopTest();

		//Then
		List<Content__c> contentResult = [SELECT Id FROM Content__c WHERE Id = :rw.recordsSelected]; 
		System.assertEquals(1, contentResult.size());
	}

	@isTest 
	static void findContentWithCriteria(){
		// Comment: Desde un componente Banner busco todos los registros de contenido, con condiciones

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global',null, 1,'ClusterRoot');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Content__c> cont = MockupFactory.createContent('Banner',cluster[0],1);
		List<ContentAssignment__c> contAssign = MockupFactory.createContentAssignment(cont,comp);
	
		// When 
		Test.startTest();
		JunctionObjectManagerController.RecordsWrapper rw = JunctionObjectManagerController.getRecords(comp[0].id, 'ContentAssignment__c',  'Component__c', 'Content__c', 'WHERE ExternalId__c = \''+ comp[0].ExternalId__c + '\'');
		Test.stopTest();
   
		// Then 
		Content__c var = [SELECT Id, ExternalId__c FROM Content__c WHERE Id = :rw.recordsSelected];
		System.assertNotEquals(var, null);
	}

	@isTest 
	static void contentRelatedToComponent() {
		// Comment: Desde un componente Banner le relaciono dos registros de contenido.

		// Given
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> cluster = MockupFactory.createCluster('Global', null, 1, 'ClusterRoot');
		List<Component__c> comp = MockupFactory.createComponent('Banner', 1);
		List<Content__c> cont = MockupFactory.createContent('Banner', cluster[0], 2);
		List<ContentAssignment__c> contAssign = MockupFactory.createContentAssignment(cont,comp);

		List<String> listSelectedIds = new List<String>(); 
		listSelectedIds.add(cont[0].Id);
		listSelectedIds.add(cont[1].Id);

		// When 
		Test.startTest();
		String response = JunctionObjectManagerController.saveRelationships(comp[0].Id, 'ContentAssignment__c', 'Component__c', 'Content__c', listSelectedIds);
		Test.stopTest();

		// Then
		System.assertEquals('OK', response);
	}

}