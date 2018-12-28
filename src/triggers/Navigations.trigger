trigger Navigations on Navigation__c ( after insert, after update) {
    new NavigationTriggers(trigger.new, trigger.old).run();
}