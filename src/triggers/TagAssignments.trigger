trigger TagAssignments on TagAssignment__c (after insert, after update){
	new TagAssignmentTriggers(trigger.new, trigger.old).run();
}