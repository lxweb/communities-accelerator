trigger Components on Component__c (before insert, before update){
	new ComponentTriggers(trigger.new, trigger.old).run();
}