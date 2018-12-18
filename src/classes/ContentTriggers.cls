public with sharing class ContentTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public ContentTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
    	setExternalId((Content__c)recNew);
        checkAdvanceContentBinding((Content__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	setExternalId((Content__c)recNew);
        checkAdvanceContentBinding((Content__c)recNew);
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
	private void setExternalId(Content__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name);
        }
    }

    private void checkAdvanceContentBinding(Content__c recNew){
        if(!canMethod('checkAdvanceContentBinding')){return;}

        if(recNew.HTMLContent__c != null && recNew.HTMLContent__c.substringBetween('[!', ']') != null){

            //Replace binding by lower case
            List<String> bindingsList = new List<String>();
            String auxTextToReplace = recNew.HTMLContent__c;
            while(auxTextToReplace.substringBetween('[!', ']') != null) {
                String bind = auxTextToReplace.substringBetween('[!', ']');
                bindingsList.add('[!' + bind + ']');
                auxTextToReplace = auxTextToReplace.replace('[!' + bind + ']', '');
            }
            for(String binding: bindingsList){
                recNew.HTMLContent__c = recNew.HTMLContent__c.replace(binding, binding.toLowerCase());
            }

            //Check consistency
            if(Limits.getQueries() < 50){
                String replacedValue = GeneralUtils.replaceDynamicFields(recNew.HTMLContent__c, 'User', UserInfo.getUserId(), false);
                if(replacedValue.substringBetween('[!', ']') != null){
                    String fieldApiName = replacedValue.substringBetween('[!', ']');
                    recNew.HTMLContent__c.addError('Dynamic user fields error. Some relationship or field doesn\'t exists: ' + bindingsList);
                }
            }
        }
    }

}