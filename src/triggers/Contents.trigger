trigger Contents on Content__c (before insert, before update, after insert, after update) {
    new ContentTriggers(trigger.new, trigger.old).run();
}