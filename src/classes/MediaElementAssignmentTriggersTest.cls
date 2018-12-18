@isTest(seeAllData = false)
public class MediaElementAssignmentTriggersTest {
	
	@isTest 
	static void insertMediaElementAssignmentTest(){
		/* Comment: Comprueba que al crear un MediaElementAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		MediaElement__c mediaElementTest = new MediaElement__c(Name='Test');
		insert mediaElementTest;

		Content__c contTest = [select id, Name, ExternalId__c from Content__c limit 1];								

		MediaElementAssignment__c MediaElementAssigmentTest = new MediaElementAssignment__c(Content__c=contTest.id );

		//When
		Test.startTest();
			insert(mediaElementAssigmentTest);
		Test.stopTest();

		//Then
		MediaElementAssignment__c mediaElementAssigmentTestResult =[select id, ExternalId__c from MediaElementAssignment__c where id =: mediaElementAssigmentTest.id];
		System.assertNotEquals(mediaElementAssigmentTestResult.ExternalId__c, null);

	}

	@isTest
	static void updateMediaElementAssignment(){
		/*Comment: Comprueba que al actualizar un MediaElementAssignment__c se actualiza
		con correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Content__c contTest = [select id, Name, ExternalId__c from Content__c limit 1];	
		MediaElementAssignment__c mediaElementAssigmentTest = new MediaElementAssignment__c(Content__c=contTest.id );
		insert mediaElementAssigmentTest;
		mediaElementAssigmenttest.ExternalId__c = null;


		//When
		Test.startTest();
		update(mediaElementAssigmenttest);
		Test.stopTest();

		//Then
		MediaElementAssignment__c mediaElementAssigmentTestResult =[select id, ExternalId__c from MediaElementAssignment__c where id =: MediaElementAssigmentTest.id];
		System.assertNotEquals(mediaElementAssigmentTestResult.ExternalId__c, null);

	}
}