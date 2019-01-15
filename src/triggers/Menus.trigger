trigger Menus on Menu__c (before insert, before update, after insert, after update) {
    new MenuTriggers(trigger.new, trigger.old).run();
}