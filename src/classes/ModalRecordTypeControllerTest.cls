@isTest
public with sharing class ModalRecordTypeControllerTest {
	
	@isTest 
	static void getObjectLabel() {
		ModalRecordTypeController.getObjectLabel('Content__c');
	}

	@isTest 
	static void getRecordTypes() {
        MockupFactory.generateAcceleratorSetting();
		ModalRecordTypeController.getContentRecordTypes('Content__c');
		ModalRecordTypeController.getTemplateRecordTypes('Content__c');
	}
}