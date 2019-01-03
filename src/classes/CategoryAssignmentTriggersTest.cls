@isTest(seeAllData = false)
public class CategoryAssignmentTriggersTest {
	
	@isTest 
	static void insertCategoryAssignmentTest(){
		/* Comment: Comprueba que al crear un CategoryAssignment__c se inserta
		con el correspondiente ExternalId__c */

		//Given
		Category__c categoryTest = new Category__c(Name = 'Test');
		insert categoryTest;
		List<Component__c> compTest = MockupFactory.createComponent('FAQ',1);
		CategoryAssignment__c catAssigmentTest = new CategoryAssignment__c(Component__c = compTest[0].Id, Category__c=categoryTest.Id);

		//When
		Test.startTest();
		insert(catAssigmentTest);
		Test.stopTest();

		//Then
		CategoryAssignment__c catAssigmentTestResult =[SELECT ExternalId__c FROM CategoryAssignment__c WHERE Id =: catAssigmentTest.Id];
		System.assertNotEquals(catAssigmentTestResult.ExternalId__c, null);
	}

	@isTest 
	static void updateCategoryAssignmentTest(){
		/* Comment: Comprueba que al actualizar un CategoryAssignment__c se inserta
		con el correspondiente ExternalId__c */

		//Given
		Category__c categoryTest = new Category__c(Name='Test');
		insert categoryTest;
		List<Component__c> compTest = MockupFactory.createComponent('Banner',1);
		CategoryAssignment__c catAssigmentTest = new CategoryAssignment__c(Component__c = compTest[0].Id, Category__c=categoryTest.Id);
		insert(catAssigmentTest);
		catAssigmentTest.ExternalId__c = null;

		//When
		Test.startTest();
		update(catAssigmentTest);
		Test.stopTest();

		//Then
		CategoryAssignment__c catTestResult2 =[SELECT Id, ExternalId__c FROM CategoryAssignment__c WHERE Id =: catAssigmentTest.Id];
		System.assertNotEquals(catTestResult2.ExternalId__c, null);
	}
}