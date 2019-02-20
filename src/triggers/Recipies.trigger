trigger Recipies on Recipe__c (before insert, before update, after insert, after update) {
		new RecipeTriggers(trigger.new, trigger.old).run();
}