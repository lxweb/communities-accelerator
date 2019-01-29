@isTest
public with sharing class GlobalSearchControllerTest {
    @testSetup
    static void setup(){
		createListLayout('Banner','banner','Content__c','Name','Name,Description__c','Banner');
    }

    @isTest
    static void getSearchResults(){
    	List<GlobalSearchController.SearchResultWrapper> listResult = GlobalSearchController.getSearchResults('Test');
    	System.debug('listResult ' + JSON.serialize(listResult));
    }

    static RecordListLayout__c createListLayout(String name, String sectionApiName, String objectApiName, String fieldsToSearch, String fieldsToShow, String recordTypeDevName){
    	RecordListLayout__c rll = new RecordListLayout__c(
												    		Name 					= name,
												    		ExternalId__c      		= sectionApiName,
												    		ObjectAPIName__c 		= objectApiName,
												    		FieldsToSearch__c 		= fieldsToSearch,
												    		FieldsToShow__c			= fieldsToShow,
												    		RecordTypeDevName__c	= recordTypeDevName
    	);
    	insert rll;
    	return rll;
    }
}