trigger Components on Component__c (before insert, before update, after insert, after update){
	new ComponentTriggers(trigger.new, trigger.old).run();
}