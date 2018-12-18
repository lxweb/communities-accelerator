trigger Translations on Translation__c (before insert, before update) {
	new TranslationTriggers(trigger.new, trigger.old).run();
}