trigger Components on Component__c (before insert, before update, after insert, after update,  before delete){
	new ComponentTriggers(trigger.new, trigger.old).run();
}