trigger MediaElements on MediaElement__c (before insert, before update) {
	new MediaElementTriggers(trigger.new, trigger.old).run();
}