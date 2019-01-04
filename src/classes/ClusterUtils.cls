public with sharing class ClusterUtils {

	public class ClusterWrapper {
		public Cluster__c cluster;
		public List<ClusterWrapper> relatedClusters;
		public ClusterWrapper(Cluster__c p_cluster){
			this.cluster = p_cluster;
			this.relatedClusters = new List<ClusterWrapper>();
		}
		//Esto es una modificacion para probar una historia
	}

	public static map<String, set<String>> mapClustersParents;
	public static set<String> getClustersParents(String clusterId) {
		if(mapClustersParents == null){
			mapClustersParents = new map<String, set<String>>();
		}

		if(!mapClustersParents.containsKey(clusterId)){
			mapClustersParents.put(clusterId, new set<String>{clusterId});
			
			List<Cluster__c> queryResult = [SELECT Id, ParentCluster__c, ParentCluster__r.ParentCluster__c, ParentCluster__r.ParentCluster__r.ParentCluster__c FROM Cluster__c WHERE Id =: clusterId];
			if(!queryResult.isEmpty()){
				Cluster__c cluster = queryResult[0];
				//The accelerator allows only 4 levels of depth of Clusters
				if(cluster.ParentCluster__c != null){
					mapClustersParents.get(clusterId).add(cluster.ParentCluster__c);
					if(cluster.ParentCluster__r.ParentCluster__c != null){
						mapClustersParents.get(clusterId).add(cluster.ParentCluster__r.ParentCluster__c);
						if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c != null){
							mapClustersParents.get(clusterId).add(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c);
						}
					}
				}
			}
		}

		return mapClustersParents.get(clusterId);
	}
	
	public static map<String, ClusterWrapper> mapClustersBelow;
	public static ClusterWrapper getClustersBelow(String clusterId) {
		if(mapClustersBelow == null){
			mapClustersBelow = new map<String, ClusterWrapper>();
		}

		if(!mapClustersBelow.containsKey(clusterId)){
			Cluster__c cluster = [SELECT Id, Name, ParentCluster__c, ClusterLandingUrl__c, RecordType.DeveloperName FROM Cluster__c WHERE Id =: clusterId];
			
			mapClustersBelow.put(cluster.Id, new ClusterWrapper(cluster));
			
			//The accelerator allows only 4 levels of depth of Clusters
			set<Id> setClusterRelated = new set<Id>{cluster.Id};
			while(!setClusterRelated.isEmpty()){
				List<Cluster__c> clustersRelated = [SELECT Id, Name, ParentCluster__c, ClusterLandingUrl__c, RecordType.DeveloperName FROM Cluster__c WHERE ParentCluster__c IN: setClusterRelated];
				setClusterRelated.clear();
				for(Cluster__c rc: clustersRelated){
					setClusterRelated.add(rc.Id);
					ClusterWrapper crr = new ClusterWrapper(rc);
					mapClustersBelow.put(rc.Id, crr);
					mapClustersBelow.get(rc.ParentCluster__c).relatedClusters.add(crr);
				}
			}
		}

		return mapClustersBelow.get(clusterId);
	}

	public static map<String, String> mapMappingKeyCluster;
	public static String getClusterIdFromMappingObject(String recordId, String networkId){
		if(mapMappingKeyCluster == null){
			mapMappingKeyCluster = new map<String, String>();
		}
		
		String mappingKey = recordId + '-' + networkId;
		if(!mapMappingKeyCluster.containsKey(mappingKey)){
			try{
				List<Cluster__c> clusterRoot = [SELECT Id, MappingObject__c, MappingObjectField__c, MappingClusterField__c FROM Cluster__c WHERE RecordType.DeveloperName = 'ClusterRoot' AND CommunityName__c =: GeneralUtils.getNetwork(networkId).Name];
				if(!clusterRoot.isEmpty()){
					List<SObject> rec = Database.query('SELECT Id, ' + clusterRoot[0].MappingObjectField__c + ' FROM ' + clusterRoot[0].MappingObject__c + ' WHERE Id =: recordId');
					if(!rec.isEmpty()){
						List<Cluster__c> clusterRet = Database.query('SELECT Id FROM Cluster__c WHERE RecordType.DeveloperName = \'ClusterLeaf\' AND ' + clusterRoot[0].MappingClusterField__c + ' = \'' + GeneralUtils.getFieldValue(rec[0], clusterRoot[0].MappingObjectField__c) + '\' LIMIT 1');
						if(!clusterRet.isEmpty()){
							mapMappingKeyCluster.put(mappingKey, clusterRet[0].Id);
						}
					}
				}
			}catch(Exception e){}
		}

		return mapMappingKeyCluster.get(mappingKey);
	}

	public static Cluster__c getClusterRootFromNetwork(){
		Cluster__c clusterRoot;
		if (Network.getNetworkId() != null ){
			List<Cluster__c> queryResult = [SELECT Id, MappingObject__c, MappingObjectField__c, MappingClusterField__c, ClusterLandingUrl__c, RecordType.DeveloperName FROM Cluster__c WHERE RecordType.DeveloperName = 'ClusterRoot' AND CommunityName__c =: GeneralUtils.getNetwork(Network.getNetworkId()).Name];
			if(!queryResult.isEmpty()){
				clusterRoot = queryResult[0];
			}
			return clusterRoot;
		}
		return null;
	}
}