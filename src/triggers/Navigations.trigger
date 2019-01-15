trigger Navigations on Navigation__c (before insert, before update, after insert, after update) {
    new NavigationTriggers(trigger.new, trigger.old).run();
}