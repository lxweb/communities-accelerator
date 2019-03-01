public class ModalRecordTypeController {

	@AuraEnabled
    public static String getObjectLabel(String sObjectType){
    	return Schema.getGlobalDescribe().get(sObjectType).getDescribe().getLabel();
    }

    @AuraEnabled
    public static List<RecordType> getRecordTypes(String sObjectType, List<String> recordTypes){
    	List<Map<String,String>>			rtValues 	= new List<Map<String,String>>();
        Map<String,Schema.RecordTypeInfo>   recordTypeInfos = Schema.getGlobalDescribe().get(sObjectType).getDescribe().getRecordTypeInfosByDeveloperName();
        if(recordTypes.isEmpty())
            return [SELECT Id,  Name, Description FROM RecordType WHERE SobjectType =: sObjectType];
        else
            return [SELECT Id,  Name, Description FROM RecordType WHERE SobjectType =: sObjectType AND DeveloperName IN :recordTypes];
    }
}