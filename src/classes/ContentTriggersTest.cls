@isTest(seeAllData = false)
public with sharing class ContentTriggersTest {

	@isTest 
	static void insertContentTest(){
		/* Comment: Comprueba que al crear un Content__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		Content__c contentTest = new Content__c(Name='Content Test 01');

		//When
		Test.startTest();
			insert(contentTest);
		Test.stopTest();

		//Then
		Content__c contentTestResult =[select id, ExternalId__c from Content__c where id =: contentTest.id];
		System.assertNotEquals(contentTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateContentTest(){
		/* Comment: Comprueba que al actualizar un Content__c se actualiza
		con el correspondiente ExternalId__c */
		
		//Given
		Content__c contentTest = new Content__c(Name='Content Test 01');
		insert(contentTest);
		ContentTest.ExternalId__c = null;
		ContentTest.Name = 'Content Test 02';
		//When
		Test.startTest();
			update(contentTest);
		Test.stopTest();

		//Then
		Content__c contentTestResult2 =[select id, ExternalId__c from Content__c where id =: contentTest.id];
		System.assertNotEquals(contentTestResult2.ExternalId__c, null);
	}
}