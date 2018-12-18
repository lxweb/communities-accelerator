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
}