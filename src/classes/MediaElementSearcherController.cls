public with sharing class MediaElementSearcherController {
	public class ContentWrapper{
		@auraEnabled public String idME;
		@auraEnabled public String name;
		@auraEnabled public String fileURLDesktop;
		@auraEnabled public String ext;
		@auraEnabled public String lastModified;
		@auraEnabled public String size;
	}

	@auraEnabled
    public static List<ContentWrapper> getData(String stringOffset, String searchText, String stringElementPerPage){
        Map<String, ContentWrapper> contentWrMap = new Map<String, ContentWrapper>();
        String contentDocId;
		Integer intOffset = Integer.valueOf(stringOffset);
		Integer elementPerPages = Integer.valueOf(stringElementPerPage);

		list<MediaElement__c> mediaElementsList = new list<MediaElement__c>();
		String queryMediaElement = 'SELECT Id, Name, FileURLDesktop__c, LastModifiedDate FROM MediaElement__c ';
		if (String.isNotBlank(searchText)){
			String likeValue = '%' + searchText + '%';
			queryMediaElement += ' WHERE Name LIKE \'' + likeValue + '\'';
		}

		queryMediaElement += ' ORDER BY LastModifiedDate DESC LIMIT ' + elementPerPages;
		if(intOffset > 0){
			queryMediaElement += ' OFFSET ' + intOffset;
		}
		
		Set<String> contentSet = new Set<String>();
		for(MediaElement__c me : Database.query(queryMediaElement)){
			ContentWrapper cw = new ContentWrapper();
			cw.idME = me.Id;
			cw.name = me.Name;
			cw.fileURLDesktop = me.FileURLDesktop__c;
			cw.lastModified = String.valueOf(me.LastModifiedDate);

            String str = me.FileURLDesktop__c.substringAfterLast('/');
            if (Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(str).matches()){
            	contentSet.add(str);
            } else {
            	cw.size = 'Web';
            	cw.ext = str.substringAfter('.');
            }
			contentWrMap.put(str, cw);
		}

		if(contentSet.size() > 0){
			for(ContentDocument file : [SELECT id, Title, ContentSize, FileExtension FROM ContentDocument WHERE id IN: contentSet]){
				ContentWrapper cw = contentWrMap.get(file.id);
				if(file.ContentSize != null)				cw.size = String.valueOf(Integer.valueOf(file.ContentSize * 0.001));
				if(String.isNotBlank(file.FileExtension))	cw.ext = file.FileExtension;
				contentWrMap.put(file.id, cw);
			}
		}      

        return contentWrMap.values();
    }
}