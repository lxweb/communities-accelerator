public with sharing class ClusterUserTriggers {
	public ClusterUserTriggers() {
		
	}


	public static void createClusterUsers(List<ClusterUser__c> clusterUserList){

		for(ClusterUser__c clusterUser:clusterUserList){
			
			//tomar el usuario
			User userAssingned = clusterUser.User__r;
			


			//tomar el cluster asociado
			//tomar los grupos de los cluster RO RW
			//Asociar el usuario al grupo correspondiente
		}

	}
}