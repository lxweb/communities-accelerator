public class ModalRecordTypeController {

    @AuraEnabled(cacheable=true)
    public static String getObjectLabel(String sObjectType){
        return Schema.getGlobalDescribe().get(sObjectType).getDescribe().getLabel();
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes(String sObjectType, List<String> recordTypes){
        List<Map<String,String>>            rtValues    = new List<Map<String,String>>();
        Map<String,Schema.RecordTypeInfo>   recordTypeInfos = Schema.getGlobalDescribe().get(sObjectType).getDescribe().getRecordTypeInfosByDeveloperName();
        if(recordTypes.isEmpty()){
            return getSortedRecordTypes(sObjectType, recordTypes);
//            return [SELECT Id, Name, Description FROM RecordType WHERE SobjectType =: sObjectType];
        } else {
            return [SELECT Id, Name, Description FROM RecordType WHERE SobjectType =: sObjectType AND DeveloperName IN :recordTypes];
        }
    }

    static List<RecordType> getSortedRecordTypes(String sObjectType, List<String> recordTypes){
        AcceleratorSettings__c acceleratorSettings = [SELECT Id, ContentLandingRecordTypes__c FROM AcceleratorSettings__c];
        recordTypes = acceleratorSettings.ContentLandingRecordTypes__c.split(',');
        List<RecordType> recordTypesTemp = [SELECT Id, DeveloperName, Name, Description FROM RecordType WHERE SobjectType =: sObjectType AND DeveloperName IN :recordTypes];
        RecordType [] recordTypesFinal = new RecordType [recordTypes.size()];
        for(RecordType recordType : recordTypesTemp){
            recordTypesFinal[recordTypes.indexOf(recordType.DeveloperName)] = recordType;
        }
        return recordTypesFinal;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getNoRedirectRecordTypes(){
        List<String> names = new List<String>{'Recipe','BrandDetail'};
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Content__c' AND DeveloperName IN :names];
        List<String> toRet = new List<String>();
        for(RecordType recordType : recordTypes){
            toRet.add(recordType.Id);
        }
        system.debug(toRet);
        return toRet;
    }
}