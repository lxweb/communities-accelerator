@isTest(seeAllData = false)
public class CategoryAssignmentTriggersTest {
	
	@isTest 
	static void insertCategoryAssignmentTest(){
		/* Comment: Comprueba que al crear un CategoryAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Category__c categoryTest = new Category__c(Name='Test');
		insert categoryTest;

		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];

		CategoryAssignment__c catAssigmentTest = new CategoryAssignment__c(Component__c = compTest.id, Category__c=categoryTest.id );

		//When
		Test.startTest();
			insert(catAssigmentTest);
		Test.stopTest();

		//Then
		CategoryAssignment__c catAssigmentTestResult =[select id, ExternalId__c from CategoryAssignment__c where id =: catAssigmentTest.id];
		System.assertNotEquals(catAssigmentTestResult.ExternalId__c, null);

	}

	@isTest 
	static void updateCategoryAssignmentTest(){
		/* Comment: Comprueba que al actualizar un CategoryAssignment__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Category__c categoryTest = new Category__c(Name='Test');
		insert categoryTest;

		Component__c compTest = [select id, Name, ExternalId__c from Component__c limit 1];

		CategoryAssignment__c catAssigmentTest = new CategoryAssignment__c(Component__c = compTest.id, Category__c=categoryTest.id );
		insert(catAssigmentTest);
		catAssigmentTest.ExternalId__c = null;

		//When
		Test.startTest();
			update(catAssigmentTest);
		Test.stopTest();

		//Then
		CategoryAssignment__c catTestResult2 =[select id, ExternalId__c from CategoryAssignment__c where id =: catAssigmentTest.id];
		System.assertNotEquals(catTestResult2.ExternalId__c, null);
	}
}