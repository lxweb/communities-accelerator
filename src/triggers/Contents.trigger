trigger Contents on Content__c (before insert, before update, after insert, after update, before delete) {
    new ContentTriggers(trigger.new, trigger.old).run();
}