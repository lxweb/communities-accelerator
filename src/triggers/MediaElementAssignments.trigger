trigger MediaElementAssignments on MediaElementAssignment__c (after insert, after update){
	new MediaElementAssignmentTriggers(trigger.new, trigger.old).run();
}