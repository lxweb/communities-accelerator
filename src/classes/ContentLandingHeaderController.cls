public with sharing class ContentLandingHeaderController {

	@AuraEnabled
    public static String getObjectLabel(String sObjectType){
    	return Schema.getGlobalDescribe().get(sObjectType).getDescribe().getLabel();
    }

    @AuraEnabled
    public static List<Map<String,String>> getPicklistValues(String sObjectType, String fieldApiName){
    	List<Map<String,String>>	picklistValues 	= new List<Map<String,String>>();
		List<Schema.PicklistEntry> 	pleList 		= Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPicklistValues();

		for( Schema.PicklistEntry pickListVal : pleList){
			if(pickListVal.isActive()){
				Map<String,String> pv = new Map<String,String>();
				pv.put('defaultValue', 	pickListVal.isDefaultValue()+'');
				pv.put('label', 		pickListVal.getLabel());
				pv.put('value', 		pickListVal.getValue());
				picklistValues.add(pv);
			}
		}

		return picklistValues;
    }
}