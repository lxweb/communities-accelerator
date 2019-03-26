public with sharing class ContentDetailHeaderController {
	//DATA WRAPPER
    public class DataWrapper{
        @AuraEnabled public Content__c      content;
        @AuraEnabled public String          timeZone;
        @AuraEnabled public SecurityWrapper  security;
        
        public DataWrapper(Content__c content, String timeZone, SecurityWrapper security){
            this.content    = content;
            this.timeZone   = timeZone;
            this.security   = security;
        }
    }

    public class SecurityWrapper{
        @AuraEnabled public Boolean     hasEditAccess;
        @AuraEnabled public Boolean     hasCreateContentPermission;
        @AuraEnabled public Boolean     hasRecordTypeAvailable;

        public SecurityWrapper(Boolean hasEditAccess, Boolean hasCreateContentPermission, Boolean hasRecordTypeAvailable){
            this.hasEditAccess              = hasEditAccess;
            this.hasCreateContentPermission = hasCreateContentPermission;
            this.hasRecordTypeAvailable     = hasRecordTypeAvailable;
        }
    }

    @AuraEnabled(cacheable=true)
    public static DataWrapper getData(String recordId){
        Content__c content = getContentData(recordId);
        SecurityWrapper sw = new SecurityWrapper(hasEditAccess(recordId), hasCreateContentPermission(), hasRecordTypeAvailable(content.RecordType.DeveloperName));
    	return new DataWrapper(getContentData(recordId), UserInfo.getTimeZone().getID(), sw);
    }

    @AuraEnabled
    public static String setName(String recordId, String name){
        Content__c c = new Content__c(Id=recordId, Name=name);
    	update c;
        return c.Name;
    }

    private static Content__c getContentData(String recordId){
        Content__c content = [SELECT Id, Name, Cluster__r.Name, Status__c, LastModifiedDate, CreatedBy.Name, RecordType.Name, RecordType.DeveloperName FROM Content__c WHERE id = :recordId];
        return content;
    }

    private static String setContentStatus(String recordId, String status){
        Content__c c = new Content__c(Id=recordId, Status__c=status);
        update c;
        return c.Status__c;
    }

    private static Boolean hasCreateContentPermission(){
        return Schema.sObjectType.Content__c.isCreateable();
    }

    private static Boolean hasEditAccess(String recordId){
        UserRecordAccess ura = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        return ura.HasEditAccess;
    }

    private static Boolean hasRecordTypeAvailable(String recordTypeDeveloperName){
        return Schema.SObjectType.Content__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).isAvailable();
    }
}