@isTest
public with sharing class ContentLandingHeaderControllerTest {
	
	@isTest 
	static void getObjectLabel() {
		ContentLandingHeaderController.getObjectLabel('Content__c');
	}

	@isTest 
	static void getPicklistValues() {
		ContentLandingHeaderController.getPicklistValues('Content__c','Status__c');
	}
}