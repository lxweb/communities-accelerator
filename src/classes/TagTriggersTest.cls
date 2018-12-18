@isTest(seeAllData = false)
public with sharing class TagTriggersTest {

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
}