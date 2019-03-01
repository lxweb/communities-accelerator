@isTest
public with sharing class ModalRecordTypeControllerTest {
	
	@isTest 
	static void getObjectLabel() {
		ModalRecordTypeController.getObjectLabel('Content__c');
	}

	@isTest 
	static void getRecordTypes() {
		ModalRecordTypeController.getRecordTypes('Content__c', new List<String>());
		ModalRecordTypeController.getRecordTypes('Content__c', new List<String>{'Event','News'});
	}
}