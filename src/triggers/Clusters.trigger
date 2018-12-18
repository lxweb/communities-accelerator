trigger Clusters on Cluster__c (before insert, before update, after insert,after update, after delete){
	new ClusterTriggers(trigger.new, trigger.old).run();
}