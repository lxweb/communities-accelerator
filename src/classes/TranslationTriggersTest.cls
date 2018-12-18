@isTest(seeAllData = false)
public with sharing class TranslationTriggersTest {

	@isTest 
	static void insertTranslationTest(){
		/* Comment: Comprueba que al crear un Translation__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		Translation__c translationTest = new Translation__c(Name='Translation Test 01');

		//When
		Test.startTest();
			insert(translationTest);
		Test.stopTest();

		//Then
		Translation__c translationTestResult =[select id, ExternalId__c from Translation__c where id =: translationTest.id];
		System.assertNotEquals(translationTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateTranslationTest(){
		/* Comment: Comprueba que al actualizar un Translation__c se actualiza
		con el correspondiente ExternalId__c */
		
		//Given
		Translation__c translationTest = new Translation__c(Name='Translation Test 01');
		insert(translationTest);
		translationTest.ExternalId__c = null;
		translationTest.Name = 'Translationl Test 02';
		//When
		Test.startTest();
			update(translationTest);
		Test.stopTest();

		//Then
		Translation__c translationTestResult2 =[select id, ExternalId__c from Translation__c where id =: translationTest.id];
		System.assertNotEquals(translationTestResult2.ExternalId__c, null);
	}
}