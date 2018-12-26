trigger ClusterUsers on ClusterUser__c (before insert, before update, after insert,after update, after delete){
    new ClusterUserTriggers(trigger.new, trigger.old).run();
}