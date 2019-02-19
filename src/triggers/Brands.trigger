trigger Brands on Brand__c (before insert, before update, after insert, after update) {
    new BrandTriggers(trigger.new, trigger.old).run();
}