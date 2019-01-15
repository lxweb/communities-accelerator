trigger MenuAssignments on MenuAssignment__c (after insert, after update){
	new MenuAssignmentTriggers(trigger.new, trigger.old).run();
}