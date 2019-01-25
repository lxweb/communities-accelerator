public with sharing class GlobalSearchController {

    //WRAPPER
    public class SearchResultWrapper {
        @AuraEnabled public List<Sobject> 				records;
        @AuraEnabled public String 							sectionName;
        @AuraEnabled public String 							sectionApiName;
        @AuraEnabled public String 							iconName;
        @AuraEnabled public String 							objectAPIName;
        @AuraEnabled public String 							sortedBy;
        @AuraEnabled public List<Map<String,String>> 	fieldsToShow;

    	public SearchResultWrapper(List<Sobject> records, String sectionName, String sectionApiName, String iconName, String objectAPIName, List<Map<String,String>> fieldsToShow){
    		this.records 			= records;
    		this.sectionName 		= sectionName;
    		this.sectionApiName 	= sectionApiName;
    		this.iconName 			= iconName;
    		this.fieldsToShow 	= fieldsToShow;
    		this.sortedBy			= fieldsToShow.get(0).get('fieldName');
        }
    }

    @AuraEnabled
    public static List<SearchResultWrapper> getSearchResults(String searchedString){
    	List<SearchResultWrapper> 	searchResults = new List<SearchResultWrapper>();
    	List<RecordListLayout__c> recordLayouts = [SELECT Name, SectionAPIName__c, FieldsToSearch__c, FieldsToShow__c, IconName__c, ObjectAPIName__c, RecordTypeDevName__c 
    												FROM RecordListLayout__c WHERE Active__c = true];
    	for(RecordListLayout__c rll : recordLayouts){
    		searchResults.add( new SearchResultWrapper( Database.query(buildQuery(rll, searchedString)),
    													rll.Name,
    													rll.SectionAPIName__c,
    													rll.IconName__c,
    													rll.ObjectAPIName__c,
    													getLabelsByFields(rll.FieldsToShow__c.split(','), rll.ObjectAPIName__c)
    													));
    	}

    	return searchResults;
    }

    private static String buildQuery(RecordListLayout__c rll, String searchedString){
    	List<String> 	fields 	= rll.FieldsToSearch__c.split(',');
    	String 			query 	= 'SELECT ' + rll.FieldsToShow__c + 
    								' FROM ' + rll.ObjectAPIName__c +
    								' WHERE ' + ((!String.isBlank(rll.RecordTypeDevName__c)) ? 
    												'RecordType.DeveloperName = \'' + rll.RecordTypeDevName__c + '\' AND (' : '');

    	for(Integer i = 0; i < fields.size(); i++){
    		String field = fields.get(i);
    		query += (i == fields.size() - 1) ? 
    					field + ' LIKE \'%' + searchedString + '%\')' : field + ' LIKE \'%' + searchedString + '%\' OR ';
    	}

    	return query;
    }

    private static List<Map<String,String>> getLabelsByFields(List<String> fields, String sobjectName){
    	List<Map<String,String>>			fieldsMaps 	= new List<Map<String,String>>();
    	Map<String, Schema.SObjectType> 	schemaMap 	= Schema.getGlobalDescribe();
		Schema.SObjectType 					leadSchema 	= schemaMap.get(sobjectName);
		Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

    	for(String fApiName : fields){
    		Map<String,String> fieldMetaData = new Map<String,String>();
    		fieldMetaData.put('label', fieldMap.get(fApiName).getDescribe().getLabel());
    		fieldMetaData.put('fieldName',fApiName);
    		fieldMetaData.put('type', (fieldMap.get(fApiName).getDescribe().getType() + '').toLowerCase());
    		fieldMetaData.put('sortable', 'true');

    		fieldsMaps.add(fieldMetaData);
    	}

    	return fieldsMaps;
    }
}