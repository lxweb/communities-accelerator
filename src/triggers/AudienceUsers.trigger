trigger AudienceUsers on AudienceUser__c (before insert, before update, after insert, after update) {
    new AudienceUserTriggers(trigger.new, trigger.old).run();
}