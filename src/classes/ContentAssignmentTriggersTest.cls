@isTest(seeAllData = false)
public class ContentAssignmentTriggersTest {
	
	@isTest 
	static void insertContentAssignmentTest(){
		/* Comment: Comprueba que al crear un ContentAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Content__c contentTest = new Content__c(Name='Test');
		insert contentTest;

		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];
		Content__c contTest = [select id, Name, ExternalId__c from Content__c limit 1];								

		ContentAssignment__c contentAssigmentTest = new ContentAssignment__c(Component__c = compTest.id, Content__c=contTest.id );

		//When
		Test.startTest();
			insert(contentAssigmentTest);
		Test.stopTest();

		//Then
		ContentAssignment__c contentAssigmentTestResult =[select id, ExternalId__c from ContentAssignment__c where id =: contentAssigmentTest.id];
		System.assertNotEquals(contentAssigmentTestResult.ExternalId__c, null);

	}

	@isTest
	static void updateContentAssignment(){
		/*Comment: Comprueba que al actualizar un ContentAssignment__c se actualiza
		con correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];
		Content__c contTest = [select id, Name, ExternalId__c from Content__c limit 1];	
		ContentAssignment__c contentAssigmentTest = new ContentAssignment__c(Component__c = compTest.id, Content__c=contTest.id );
		insert contentAssigmentTest;
		ContentAssigmenttest.ExternalId__c = null;


		//When
		Test.startTest();
		update(contentAssigmenttest);
		Test.stopTest();

		//Then
		ContentAssignment__c contentAssigmentTestResult =[select id, ExternalId__c from ContentAssignment__c where id =: contentAssigmentTest.id];
		System.assertNotEquals(contentAssigmentTestResult.ExternalId__c, null);

	}
}