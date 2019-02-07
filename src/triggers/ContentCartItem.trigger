trigger ContentCartItem on ContentCartItem__c (before insert, before update, after insert, after update) {
	new ContentCartItemTriggers(trigger.new, trigger.old).run();
}