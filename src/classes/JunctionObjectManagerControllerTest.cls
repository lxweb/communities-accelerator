@isTest 
public with sharing class JunctionObjectManagerControllerTest {

	@isTest 
	static void TEST_CASE_1() {
		// Comment: Desde un componente Banner busco todos los registros de contenido, sin condiciones

		// Given
		//MockupFactory.createRecords();
		Component__c comp = [SELECT id FROM Component__c LIMIT 1];
		
		// When 
		Test.startTest();
		JunctionObjectManagerController.RecordsWrapper rw = JunctionObjectManagerController.getRecords(comp.id, 'ContentAssignment__c',  'Component__c', 'Content__c', null);
		Test.stopTest();

		// Then
		System.assertEquals(1, [SELECT Id FROM Content__c WHERE Id = :rw.recordsSelected[0].Id].size());
	}

	@isTest 
	static void TEST_CASE_2() {// TODO 
		// Comment: Desde un componente Banner busco todos los registros de contenido, con condiciones

		// Given
		//MockupFactory.createRecords();
		Component__c comp = [SELECT id, ExternalId__c FROM Component__c LIMIT 1];
		system.debug('Nahue :'+ comp.ExternalId__c);
		// When 
		Test.startTest();
		JunctionObjectManagerController.RecordsWrapper rw = JunctionObjectManagerController.getRecords(comp.id, 'ContentAssignment__c',  'Component__c', 'Content__c', 'WHERE ExternalId__c = \''+ comp.ExternalId__c + '\'');
		Test.stopTest();
   
		// Then 
		Content__c var = [SELECT Id, ExternalId__c FROM Content__c WHERE Id = :rw.recordsSelected[0].Id];

		System.assertnotEquals(var, null);
	}

	@isTest 
	static void TEST_CASE_3() {
		// Comment: Desde un componente Banner le relaciono dos registros de contenido.

		// Given
		//MockupFactory.createRecords();
		Component__c comp = [SELECT id FROM Component__c LIMIT 1];
		List<String> listSelectedIds = new List<String>(); 
		listSelectedIds.add([SELECT Id FROM Content__c LIMIT 1][0].Id);
		listSelectedIds.add([SELECT Id FROM Content__c LIMIT 1][0].Id);
		listSelectedIds.add(comp.id);
		
		// When 
		Test.startTest();
		String response = JunctionObjectManagerController.saveRelationships(comp.id, 'ContentAssignment__c', 'Component__c', 'Content__c', listSelectedIds);
		Test.stopTest();

		// Then
		System.assertEquals('OK', response);
	}

}