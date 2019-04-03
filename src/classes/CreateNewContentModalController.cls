public with sharing class CreateNewContentModalController {

    //SAVE RESPONSE WRAPPER
    public class SaveResponseWrapper {
        @auraEnabled public Boolean isSuccess;
        @auraEnabled public String message;

        public SaveResponseWrapper(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(String recordTypeId){
        return Schema.SObjectType.Content__c.getRecordTypeInfosById().get(recordTypeId).getName();
    }

    @AuraEnabled
    public static SaveResponseWrapper createNewContent(String recordTypeId, Boolean isTemplate, String componentId, String navigationId, String recordName){
        Content__c newContent = new Content__c(
            Name = recordName.left(60),
            RecordTypeId = recordTypeId,
            IsTemplate__c = isTemplate,
            StructureComponent__c = componentId
            //StructureNavigation__c = navigationId
        );
        try{
            insert newContent;
            return new SaveResponseWrapper(true,newContent.Id);
        }catch(DMLException e){
            System.debug(e.getMessage() + ' Error during new content creation');
            System.debug(e.getStackTraceString());
            return new SaveResponseWrapper(false, e.getDMLMessage(0));
        }catch(Exception e){
            System.debug(e.getMessage() + ' Error during content upsert process, rolling back');
            System.debug(e.getStackTraceString());
            return new SaveResponseWrapper(false, 'error when creating new record');
        }
    }

}
