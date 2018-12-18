trigger Tags on Tag__c (before insert, before update) {
	new TagTriggers(trigger.new, trigger.old).run();
}