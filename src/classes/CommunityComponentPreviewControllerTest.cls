@isTest
public class CommunityComponentPreviewControllerTest {
	@isTest static void getRecordTest(){
		/* Comment: Comprueba que dado un String correspondiente a un recordId de un componente, el método getRecord de la clase CommunityComponentPreview, retorne el
		componente representado por dado record Id. */

		//Given
		//MockupFactory.createRecords();
		Component__c testRecord = [SELECT Id, Name, ExternalId__c, RecordTypeId FROM Component__c LIMIT 1]; 
		System.debug('testRecord: ' + testRecord);
		
		//When
		Test.startTest();
			Component__c testComponent = CommunityComponentPreviewController.getRecord(String.valueOf(testRecord.Id));
		Test.stopTest();

		//Then
		System.assertEquals(testRecord.Id, testComponent.Id);
	}

}