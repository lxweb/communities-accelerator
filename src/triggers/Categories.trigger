trigger Categories on Category__c (before insert, before update) {
	new CategoryTriggers(trigger.new, trigger.old).run();
}