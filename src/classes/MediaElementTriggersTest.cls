@isTest(seeAllData = false)
public with sharing class MediaElementTriggersTest {

	@isTest 
	static void insertMediaElementTest(){
		/* Comment: Comprueba que al crear un MediaElement__c se inserta
		con el correspondiente ExternalId__c */

		//Given
		MediaElement__c mediaElementTest = new MediaElement__c(Name='MediaElement Test 01');

		//When
		Test.startTest();
		insert(mediaElementTest);
		Test.stopTest();

		//Then
		MediaElement__c mediaElementTestResult =[SELECT Id, ExternalId__c FROM MediaElement__c WHERE Id =: mediaElementTest.Id];
		System.assertNotEquals(mediaElementTestResult.ExternalId__c, null);
	}

	@isTest
	static void updateMediaElementTest(){
		/* Comment: Comprueba que al actualizar un mediaElement__c se actualiza
		con el correspondiente ExternalId__c */
		
		//Given
		MediaElement__c mediaElementTest = new MediaElement__c(Name='MediaElement Test 01');
		insert(mediaElementTest);
		mediaElementTest.ExternalId__c = null;
		mediaElementTest.Name = 'MediaElementl Test 02';
		//When
		Test.startTest();
		update(mediaElementTest);
		Test.stopTest();

		//Then
		MediaElement__c mediaElementTestResult2 =[SELECT Id, ExternalId__c FROM MediaElement__c WHERE Id =: mediaElementTest.Id];
		System.assertNotEquals(mediaElementTestResult2.ExternalId__c, null);
	}
}