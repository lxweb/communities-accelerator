trigger Menus on Menu__c (after insert, after update) {
    new MenuTriggers(trigger.new, trigger.old).run();
}