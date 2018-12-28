trigger Categories on Category__c (before insert, before update,after insert, after update) {
	new CategoryTriggers(trigger.new, trigger.old).run();
}