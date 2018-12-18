trigger Contents on Content__c (before insert, before update) {
    new ContentTriggers(trigger.new, trigger.old).run();
}