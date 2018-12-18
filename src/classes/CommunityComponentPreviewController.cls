public with sharing class CommunityComponentPreviewController {
	
	@AuraEnabled
    public static Component__c getRecord(String recordId){
        Component__c comp = [SELECT Id, Name, ExternalId__c, RecordType.DeveloperName FROM Component__c WHERE Id =: recordId];
        return comp;
    }

}