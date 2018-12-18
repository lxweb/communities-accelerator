trigger ContentAssignments on ContentAssignment__c (after insert, after update){
	new ContentAssignmentTriggers(trigger.new, trigger.old).run();
}