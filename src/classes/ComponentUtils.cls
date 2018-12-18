public with sharing class ComponentUtils {

	public static Component__c getComponent(String componentExternalId, set<String> fieldSet, String device){
        List<Component__c> queryResult = Database.query('SELECT ' + GeneralUtils.joinFields(fieldSet) + ' FROM Component__c WHERE Id =: componentExternalId OR ExternalId__c = \'' + componentExternalId + '\' LIMIT 1');
        
        Component__c component;
        if(!queryResult.isEmpty()){
        	component = queryResult[0];
        }

        return component;
    }

}