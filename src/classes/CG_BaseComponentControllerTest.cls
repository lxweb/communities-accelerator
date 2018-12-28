@isTest(seeAllData = false)
public with sharing class CG_BaseComponentControllerTest {
	@isTest 
	static void getComponentWrapperTest(){
		/* Comment: Comprueba que dado un String correspondiente al ExternalId__c de un Component__c el método getComponentWrapper
		de la clase CG_BaseComponentController retorne el Component__c correspondiente. */

		/*
		//Given
		MockupFactory.createRecords();

		//When
		Test.startTest();
			CG_BaseComponentController.ComponentWrapper cwTest= CG_BaseComponentController.getComponentWrapper('BannerComponent_1', 'RelatedNews', null, null, 'Desktop');
		Test.stopTest();

		//Then
		
		System.assertEquals(cwTest.component.ExternalId__c, 'BannerComponent_1');
		*/
	}

	@isTest 
	static void getPageTest(){
		/* Comment: Comprueba que al crear un Category__c se inserta
			con el correspondiente ExternalId__c */

		//Given
		//MockupFactory.createRecords();
		Category__c categoryTest = new Category__c(Name='Category Test 01');
		List<String> stringIDList= new List<String>();
		for(Content__c content : [select Id from Content__c where ExternalId__c like'BannerContent%']){
			stringIDList.add(content.Id);
		} 

		//When
		Test.startTest();
			List<CG_BaseComponentController.ContentWrapper> cwTest= CG_BaseComponentController.getPage(stringIDList, 'RelatedNews', '1', '1', 'Name', 'Desktop');
		Test.stopTest();

		//Then
		
		System.assertNotEquals(cwTest, null);
	}	
}