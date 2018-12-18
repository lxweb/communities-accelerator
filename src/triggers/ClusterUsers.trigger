trigger ClusterUsers on ClusterUser__c (after insert){
		//before insert,before update,before delete, after update,after delete, after undelete
		if (Trigger.isInsert) {
	    	//call your handler.before method
	    	if (Trigger.isAfter){

	    		ClusterUserTriggers.createClusterUsers(Trigger.New);
	    	}

	    
		} /*else if (Trigger.isAfter) {
	    	//call handler.after method

	    
		}*/
}