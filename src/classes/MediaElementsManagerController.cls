public class MediaElementsManagerController {
	public class RecordsWrapper{
			@auraEnabled public String place;
			@auraEnabled public SObject junctionObject;
		}

	@auraEnabled
	public static list<RecordsWrapper> getRecord(String recordId, String places, String parentLookup, String junctionObject){
		list<RecordsWrapper> rwList = new list<RecordsWrapper>();

		list<String> placesList= new list<String> (); 
		for (String place: places.split(',')){
			RecordsWrapper rw = new RecordsWrapper ();
			rw.place = place.trim();
			rwList.add(rw);

			placesList.add(place.trim());
		}
		// busco y me fijo si existe un registro del Objeto junctionObject que se relacione a las places e ids
		String joQuery = 'SELECT Id, Place__c, MediaElement__r.FileURLDesktop__c, ' + parentLookup + ' FROM ' + junctionObject + ' WHERE Place__c IN :placesList AND '+ parentLookup + '= \'' + recordId + '\'';
		for(SObject rec: Database.query(joQuery)){
			for(RecordsWrapper rw :rwList){
				system.debug(rw);
				if(rw.place == rec.get('Place__c')){
					system.debug('entre');
					rw.junctionObject = rec;
				}
			}
		}
		return rwList;
	}
	@auraEnabled
	public static list<MediaElement__c> getMediaElements (String stringOffset, String searchText, String stringElementPerPage){
		
		Integer intOffset =Integer.valueOf(stringOffset);
		Integer intElementPerPage =Integer.valueOf(stringElementPerPage);

		list<MediaElement__c> mediaElementsList = new list<MediaElement__c>();
		// TODO  pasar a database.query(String)
		if (searchText == '' || searchText == null){
			if(intOffset < 1){
				mediaElementsList = [SELECT Id, Name, FileURLDesktop__c FROM MediaElement__c ORDER BY LastModifiedDate DESC LIMIT :intElementPerPage];	
			}else{
				mediaElementsList = [SELECT Id, Name, FileURLDesktop__c FROM MediaElement__c ORDER BY LastModifiedDate DESC LIMIT :intElementPerPage OFFSET :intOffset];
			}
		} else {
			String likeValue = '%' + searchText + '%';
			
			if(intOffset < 1){
				mediaElementsList = [SELECT Id, Name, FileURLDesktop__c FROM MediaElement__c WHERE Name LIKE :likeValue ORDER BY LastModifiedDate DESC LIMIT :intElementPerPage];	
			}else{
				mediaElementsList = [SELECT Id, Name, FileURLDesktop__c FROM MediaElement__c WHERE Name LIKE :likeValue ORDER BY LastModifiedDate DESC LIMIT :intElementPerPage OFFSET :intOffset];
			}
		}

		if(!mediaElementsList.isEmpty()){
			return mediaElementsList;
		}
		return new list<MediaElement__c> ();
	}
	@auraEnabled
	public static void assignMediaElementToId (String recordId, String place, String parentLookup, String junctionObject, String mediaElementId){

		sObject sObj = Schema.getGlobalDescribe().get(junctionObject).newSObject();

		sObj.put(parentLookup, recordId);
		sObj.put('MediaElement__c', mediaElementId);
		sObj.put('Place__c', place);
		
		list<sObject> listToDelete = new list<sObject> ();
		for(SObject rec: Database.query('SELECT Id, Place__c, MediaElement__r.FileURLDesktop__c, ' + parentLookup + ' FROM ' + junctionObject + ' WHERE Place__c = \'' + place + '\' AND '+ parentLookup + '= \'' + recordId + '\'')){
			listToDelete.add(rec);
		}

		Savepoint sp = Database.setSavepoint();
		try{
			delete listToDelete;
			insert sObj;
		}catch(Exception e){
			Database.rollback(sp);
			system.debug(e.getMessage());
		}
	}
	@auraEnabled
	public static void deleteJunctionObject(String junctionObjectId, String junctionObjectApiName){

		sObject sObj = Schema.getGlobalDescribe().get(junctionObjectApiName).newSObject();
		sObj.put('Id', junctionObjectId);
		
		Savepoint sp = Database.setSavepoint();
		try{
			delete sObj;
		}catch(Exception e){
			Database.rollback(sp);
			system.debug(e.getMessage());
		}
	}
}