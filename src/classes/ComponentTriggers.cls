public with sharing class ComponentTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public ComponentTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
    	setExternalId((Component__c)recNew);
    	customSort((Component__c)recNew, null);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	setExternalId((Component__c)recNew);
        customSort((Component__c)recNew, (Component__c)recOld);
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
	private void setExternalId(Component__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name);
        }
    }
    private void customSort(Component__c recNew, Component__c recOld){
        if(!canMethod('customSort')){return;}
        
    	if(recNew.OrderBy__c == 'Custom Sorting' && recNew.OrderByAdvance__c != null && Limits.getQueries() < 50){
			if(trigger.isInsert || (trigger.isUpdate && (recNew.OrderByAdvance__c != recOld.OrderByAdvance__c) || recNew.OrderBy__c != recOld.OrderBy__c)){
				try{
					Database.query('SELECT Id FROM Content__c ORDER BY ' + recNew.OrderByAdvance__c + ' LIMIT 1');
				}catch(Exception e){
					recNew.OrderByAdvance__c.AddError(Label.OrderByInvalidFormat + ' ' + e.getMessage());
				}
    		}
		}
        
	}
}