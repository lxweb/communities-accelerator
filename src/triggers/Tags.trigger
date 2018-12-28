trigger Tags on Tag__c (before insert, before update, after insert, after update, after delete) {
	new TagTriggers(trigger.new, trigger.old).run();
}