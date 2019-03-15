trigger RecordListLayout on RecordListLayout__c (before insert, before update) {
	new RecordListLayoutTriggers(trigger.new, trigger.old).run();
}