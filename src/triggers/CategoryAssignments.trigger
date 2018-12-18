trigger CategoryAssignments on CategoryAssignment__c (after insert, after update){
	new CategoryAssignmentTriggers(trigger.new, trigger.old).run();
}