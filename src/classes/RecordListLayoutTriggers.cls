public with sharing class RecordListLayoutTriggers extends TriggersHandler{
	private Boolean hasError = false;

	public RecordListLayoutTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true; 
    }


    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
    	checkSobjectAPIName((RecordListLayout__c)recNew);
    	checkFieldsAPIName((RecordListLayout__c)recNew);
    	checkRecordTypeDevName((RecordListLayout__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	checkSobjectAPIName((RecordListLayout__c)recNew);
    	checkFieldsAPIName((RecordListLayout__c)recNew);
    	checkRecordTypeDevName((RecordListLayout__c)recNew);
    }

    private void checkSobjectAPIName(RecordListLayout__c recNew){
    	Boolean exist = false;
        for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
	        String sobjName = String.valueOf(sObjectType);
	        if (sobjName.equalsIgnoreCase(recNew.ObjectAPIName__c) ) {
	            exist = true;
	        }
	    }
	    if(!exist){
	    	hasError = true;
	    	recNew.addError('The inserted SObject API Name does not exist');
	    }
    }

    private void checkFieldsAPIName(RecordListLayout__c recNew){
    	if(!hasError){

	    	List<String> 						fieldsToShow 	= recNew.FieldsToShow__c.split(',');
	    	List<String> 						fieldsToSearch 	= recNew.FieldsToSearch__c.split(',');
	    	Map<String, Schema.SObjectType> 	schemaMap 		= Schema.getGlobalDescribe();
			Schema.SObjectType 					objectSchema 	= schemaMap.get(recNew.ObjectAPIName__c);
			Map<String, Schema.SObjectField>	objectFieldsMap = objectSchema.getDescribe().fields.getMap();
			Set<String> 						objectFields 	= objectFieldsMap.keySet();

			for(String field : fieldsToShow){
				if(!objectFields.contains(field.toLowerCase())) {
					recNew.addError('The field "' + field + '" for the Sobject "' + recNew.ObjectAPIName__c + '" does not exist');
					return;
				}
			}
			for(String field : fieldsToSearch){
				if(!objectFields.contains(field.toLowerCase())) {
					recNew.addError('The field "' + field + '" for the Sobject "' + recNew.ObjectAPIName__c + '" does not exist');
					return;
				}
				if(!objectFieldsMap.get(field).getDescribe().isFilterable()){
					recNew.addError('The field "' + field + '" for the Sobject "' + recNew.ObjectAPIName__c + '" is not filterable');
					return;
				}
			}
		}
    }

    private void checkRecordTypeDevName(RecordListLayout__c recNew){
    	if(!String.isBlank(recNew.RecordTypeDevName__c) && !hasError){
	        Map<String, Schema.SObjectType> 	schemaMap 	= Schema.getGlobalDescribe();
			Map<String,Schema.RecordTypeInfo> 	recordTypes	= schemaMap.get(recNew.ObjectAPIName__c).getDescribe().getRecordTypeInfosByDeveloperName();
			if(!recordTypes.containsKey(recNew.RecordTypeDevName__c)){
				recNew.addError('The record type "' + recNew.RecordTypeDevName__c + '" for the Sobject "' + recNew.ObjectAPIName__c + '" does not exist');
			}
		}
    }
}