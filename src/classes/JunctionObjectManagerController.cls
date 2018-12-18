public with sharing class JunctionObjectManagerController {

	public class RecordsWrapper{
		@auraEnabled public String fieldNameLabel;
		@auraEnabled public String secondaryObjectLabelPlural;
		@auraEnabled public List<SObject> recordsSelected;
		@auraEnabled public List<SObject> recordsToSelect;
		public RecordsWrapper(){
			this.recordsSelected = new List<SObject>();
			this.recordsToSelect = new List<SObject>();
		}
	}
	
	@auraEnabled
	public static RecordsWrapper getRecords(String recordId, String junctionObjectAPIName, String parentLookup, String secondaryLookup, String whereCondition){
		RecordsWrapper rw = new RecordsWrapper();
		String primaryObjectName = Schema.getGlobalDescribe().get(junctionObjectAPIName).getDescribe().fields.getMap().get(parentLookup).getDescribe().getReferenceTo()[0].getDescribe().getName();
		String secondaryObjectName = Schema.getGlobalDescribe().get(junctionObjectAPIName).getDescribe().fields.getMap().get(secondaryLookup).getDescribe().getReferenceTo()[0].getDescribe().getName();

		rw.fieldNameLabel = Schema.getGlobalDescribe().get(secondaryObjectName).getDescribe().fields.getMap().get('name').getDescribe().getLabel();
		rw.secondaryObjectLabelPlural = Schema.getGlobalDescribe().get(secondaryObjectName).getDescribe().getLabelPlural();

		//Query to Junction Object
		String joQuery = 'SELECT Id, ' + secondaryLookup + ' FROM ' + junctionObjectAPIName + ' WHERE ' + parentLookup + ' =: recordId';
		set<Id> setSelectedRecords = new set<Id>();

		for(SObject rec: Database.query(joQuery)){
			setSelectedRecords.add(String.valueOf(rec.get(secondaryLookup)));
		}
		
		//Query to selected records
		String secordaryObjectSelectedQuery = 'SELECT Id, Name FROM ' + secondaryObjectName + ' WHERE Id IN: setSelectedRecords';

		for(SObject rec: Database.query(secordaryObjectSelectedQuery)){
			rw.recordsSelected.add(rec);
		}

		//Query to NOT selected or available records
		if(whereCondition != null && whereCondition != ''){
			whereCondition = whereCondition.replace('[!rec', '[!' + primaryObjectName.toLowerCase());
			whereCondition = GeneralUtils.replaceDynamicFields(whereCondition, primaryObjectName, recordId, true);

			if(whereCondition.startsWith('WHERE')){
				whereCondition = whereCondition.replace('WHERE', ' WHERE (Id NOT IN: setSelectedRecords) AND ');
			}else{
				whereCondition = ' WHERE (Id NOT IN: setSelectedRecords) ' + whereCondition;
			}
		}else{
			whereCondition = ' WHERE (Id NOT IN: setSelectedRecords)';
		}

		String relatedRecQuery = 'SELECT Id, Name FROM ' + secondaryObjectName + whereCondition;

		for(SObject rec: Database.query(relatedRecQuery)){
			rw.recordsToSelect.add(rec);
		}
		return rw;
	}

	@auraEnabled
	public static String saveRelationships(String recordId, String junctionObjectAPIName, String parentLookup, String secondaryLookup, List<String> listSelectedIds){
		set<String> selectedIds = new set<String>();
		selectedIds.addAll(listSelectedIds);

		List<SObject> recToDelete = new List<SObject>();
		List<SObject> recToInsert = new List<SObject>();

		for(SObject rec: Database.query('SELECT Id, ' + secondaryLookup + ' FROM ' + junctionObjectAPIName + ' WHERE ' + parentLookup + ' =: recordId')){
			if(!selectedIds.contains(String.valueOf(rec.get(secondaryLookup)))){
				recToDelete.add(rec);
			}else{
				selectedIds.remove(String.valueOf(rec.get(secondaryLookup)));
			}
		}

		for(String idsNotInDB: selectedIds){
			sObject sObj = Schema.getGlobalDescribe().get(junctionObjectAPIName).newSObject();
			sObj.put(parentLookup, recordId);
			sObj.put(secondaryLookup, idsNotInDB);
			recToInsert.add(sObj);
		}

		String response = 'OK';
		Savepoint sp = Database.setSavepoint();
		try{
			delete recToDelete;
			insert recToInsert;
		}catch(Exception e){
			Database.rollback(sp);
			response = e.getMessage();
			system.debug(e.getMessage());
		}
		
		return response;
	}

}