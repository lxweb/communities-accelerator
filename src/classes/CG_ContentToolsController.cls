public with sharing class CG_ContentToolsController {
    public class ContentWrapper{    
        @auraEnabled public String contentId;
        @auraEnabled public String urlPreview;
        @auraEnabled public String urlDownload;
        
        public ContentWrapper(){
        }
    }

    @auraEnabled
    public static ContentWrapper initData(String contentId){
        ContentWrapper contentWr = new ContentWrapper();
        String contentDocId;

        List<MediaElementAssignment__c> contentAssignmentList = [SELECT Content__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignment__c WHERE Content__c =: contentId AND isDeleted = false];
        if(contentAssignmentList.size() > 0){
        	List<String> stringSplit = contentAssignmentList[0].MediaElement__r.FileURLDesktop__c.split('/');
            String str = stringSplit[stringSplit.size() - 1];
            if (Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(str).matches()){
            	contentDocId = str;
            }
        
	        if(!String.isBlank(contentDocId)){
	        	ContentDocument file = [SELECT id, Title FROM ContentDocument WHERE id =: contentDocId];
		        List<ContentDistribution> listContentDist = [SELECT id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId =: contentDocId];
		        
		        ContentDistribution contentDist;
		        if (listContentDist.size() > 0){
		        	contentDist = listContentDist[0];
		        } else {
		        	ContentVersion contentVers = [SELECT id FROM ContentVersion WHERE contentdocumentid =: contentDocId ORDER BY createdDate Desc LIMIT 1];
		        
		            contentDist = new ContentDistribution();
		            contentDist.Name = file.Title;
		            contentDist.ContentVersionId = contentVers.Id;
		            contentDist.PreferencesAllowOriginalDownload = true;
		            contentDist.PreferencesAllowPDFDownload = false;
		            contentDist.PreferencesAllowViewInBrowser = true;
		            contentDist.PreferencesExpires = false;
		            contentDist.PreferencesLinkLatestVersion = true;
		            insert contentDist;
		        }
		        contentDist = [SELECT id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId =: contentDocId];
		        contentWr.urlPreview = contentDist.DistributionPublicUrl.trim();
		        contentWr.urlDownload = contentDist.ContentDownloadUrl.trim();
	        } else {
	        	contentWr.urlPreview = contentAssignmentList[0].MediaElement__r.FileURLDesktop__c.trim();
		        contentWr.urlDownload = contentAssignmentList[0].MediaElement__r.FileURLDesktop__c.trim();
	        }
	        
	    }

        contentWr.contentId = contentId;
        return contentWr;
    }
    
    @auraEnabled
    public static ContentWrapper addToCarts(String data){
        
        ContentWrapper contentWr = (ContentWrapper)JSON.deserialize(data, ContentWrapper.class);
        Boolean isInserted = CG_ContentCartController.addContentToCart(contentWr.contentId);
        if (!isInserted){
        	throw new AuraHandledException(System.Label.DuplicateItem);
        }
        
        return contentWr;
    }

}