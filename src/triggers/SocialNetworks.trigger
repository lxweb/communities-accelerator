trigger SocialNetworks on SocialNetwork__c (before insert, before update, after insert, after update) {
    new SocialNetworkTriggers(trigger.new, trigger.old).run();
}