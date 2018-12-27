public with sharing class ObjectSharingUtil {
	


	public ObjectSharingUtil() {
		
	}


  	
  	
	public static SharingWrapper generateSharingForRecordsOnCluster(List<SObject> records, String lookupField, String nameObjectShare, String sharingReason, Boolean isCluster){

		Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
		Boolean excecuteTrigger = true;
		Map<String,Id> groupNameToGroupIdMap = new Map<String,Id>();
        Map<Id,List<Id>> mapRecordsByCluster = new Map<Id,List<Id>>();
        List<String> groupNameList = new List<String>();
        List<SObject> listOfSharesToInsert = new List<SObject>();
        System.debug('ObjectSharingUtil dataPreparing records: ' + records);
        for(SObject record: records){
            Id clusterId = (Id) record.get(lookupField);
            Id recordId = (Id) record.get('Id');
            if(!mapRecordsByCluster.containsKey(clusterId)){
            	mapRecordsByCluster.put(clusterId, new List<Id>{recordId});
        	}else{
                mapRecordsByCluster.get(clusterId).add(recordId);
        	}
        }

        System.debug('ObjectSharingUtil dataPreparing mapRecordsByCluster: ' + mapRecordsByCluster);

        Map<Id,Cluster__c> mapClusters = new Map<Id,Cluster__c>([SELECT Id, PublicGroupRWName__c, PublicGroupROUpName__c, PublicGroupRODownName__c  FROM Cluster__c WHERE Id IN: mapRecordsByCluster.keyset()]); 
        System.debug('ObjectSharingUtil dataPreparing mapClusters: ' + mapClusters);
        for(Id clusterId: mapClusters.keySet()){
        	Cluster__c cluster = mapClusters.get(clusterId);

            groupNameList.add(cluster.PublicGroupRWName__c);
            groupNameList.add(cluster.PublicGroupRODownName__c);
            groupNameList.add(cluster.PublicGroupROUpName__c);
        }
        System.debug('ObjectSharingUtil dataPreparing groupNameList: ' + groupNameList);

        List<Group> groupList = [SELECT Id, Name FROM Group WHERE Name IN :groupNameList];

        System.debug('ObjectSharingUtil dataPreparing groupList: ' + groupList);


        for(Group groupItem: groupList){

            if(!groupNameToGroupIdMap.containsKey(groupItem.Name)){
                 groupNameToGroupIdMap.put(groupItem.Name, groupItem.Id);
            }
        }

        Map<String,String> fieldNamesAndSecLevel = new Map<String,String>{'PublicGroupRWName__c' => 'Edit', 'PublicGroupROUpName__c' => 'Read', 'PublicGroupRODownName__c' => 'Read'};
        
        
        for(Id clusterId : mapRecordsByCluster.keySet()){
            if(mapClusters.containsKey(clusterId)){
                for(Id recordId: mapRecordsByCluster.get(clusterId)){
                	for(String fieldName: fieldNamesAndSecLevel.keySet()){
                		if(String.isNotBlank((String) mapClusters.get(clusterId).get(fieldName))){
		                	String objectName = recordId.getSobjectType().getDescribe().getName();

		                	String shareObjectName = nameObjectShare;
		                	Schema.SObjectType shareType = Schema.getGlobalDescribe().get(shareObjectName);
		                    SObject shareRecord = shareType.newSObject();
		                    shareRecord.put('ParentId', recordId);
		                    //shareRecord.put('UserOrGroupId', mapClusters.get(clusterId).get(fieldName));
		                    if(groupNameToGroupIdMap.containsKey((String) mapClusters.get(clusterId).get(fieldName))){
								shareRecord.put('UserOrGroupId', groupNameToGroupIdMap.get( (String) mapClusters.get(clusterId).get(fieldName)) );
			                    
			                    //pasar por parametro
			                    shareRecord.put('RowCause', sharingReason);
			                    shareRecord.put('AccessLevel', fieldNamesAndSecLevel.get(fieldName));
			                    listOfSharesToInsert.add(shareRecord);
							}else{
								objectIdToMessageErrosMap.put(recordId,'The selected Cluster doesnt have required groups2! ');
							}
		                    

	                    }else{
	                    	objectIdToMessageErrosMap.put(recordId,'The selected Cluster have one or mor groups blanks! ');
	                    }
                    }
                }
            }
        }

        SharingWrapper sharingWrapper = new SharingWrapper(objectIdToMessageErrosMap, listOfSharesToInsert);
        return sharingWrapper;
    }

	public static SharingWrapper generateSharingForCluster(List<SObject> records, String lookupField, String nameObjectShare, String sharingReason, Boolean isCluster){

		Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
		Boolean excecuteTrigger = true;
		Map<String,Id> groupNameToGroupIdMap = new Map<String,Id>();
        Map<Id,List<Id>> mapRecordsByCluster = new Map<Id,List<Id>>();
        List<String> groupNameList = new List<String>();
        List<SObject> listOfSharesToInsert = new List<SObject>();

        System.debug('TagTriggers dataPreparing records: ' + records);
        for(Sobject recordItem: records){
            groupNameList.add( ((Cluster__c) recordItem).PublicGroupRWName__c);
            groupNameList.add( ((Cluster__c) recordItem).PublicGroupRODownName__c);
            groupNameList.add( ((Cluster__c) recordItem).PublicGroupROUpName__c);
        }


        System.debug('TagTriggers dataPreparing groupNameList: ' + groupNameList);



        List<Group> groupList = [SELECT Id, Name FROM Group WHERE Name IN :groupNameList];



        for(Group groupItem: groupList){

            if(!groupNameToGroupIdMap.containsKey(groupItem.Name)){
                 groupNameToGroupIdMap.put(groupItem.Name, groupItem.Id);
            }
        }

	    Map<String,String> fieldNamesAndSecLevel = new Map<String,String>{'PublicGroupRWName__c' => 'Edit', 'PublicGroupROUpName__c' => 'Read', 'PublicGroupRODownName__c' => 'Read'};
	    
        System.debug('TagTriggers dataPreparing fieldNamesAndSecLevel: ' + fieldNamesAndSecLevel);
		                

        for(SObject record: records){
        	for(String fieldName: fieldNamesAndSecLevel.keySet()){
        		System.debug('record.get(fieldName)'+record.get(fieldName));
                	String shareObjectName = nameObjectShare;
                	Schema.SObjectType shareType = Schema.getGlobalDescribe().get(shareObjectName);
                    SObject shareRecord = shareType.newSObject();
                    shareRecord.put('ParentId', record.Id);
					shareRecord.put('UserOrGroupId', groupNameToGroupIdMap.get( (String) record.get(fieldName)) );
                    shareRecord.put('RowCause', sharingReason);
                    shareRecord.put('AccessLevel', fieldNamesAndSecLevel.get(fieldName));
                    listOfSharesToInsert.add(shareRecord);
            }
        }



        SharingWrapper sharingWrapper = new SharingWrapper(objectIdToMessageErrosMap, listOfSharesToInsert);
        return sharingWrapper;
    }


   /*public static sObject createManualShareGenericObject(Id recordId, Id userOrGroupId, String accessLevel, String sObjectType){
      
   	if(sObjectType == 'Tag__c'){
		Tag__Share tagShare  = new Tag__Share();
		tagShare.ParentId = recordId;
		tagShare.UserOrGroupId = userOrGroupId;
		tagShare.AccessLevel = accessLevel;
		tagShare.RowCause = Schema.Tag__Share.RowCause.Manual;
		return tagShare;
   	}

   	if(sObjectType == 'Content__c'){
		Content__Share contentShrare  = new Content__Share();
		contentShrare.ParentId = recordId;
		contentShrare.UserOrGroupId = userOrGroupId;
		contentShrare.AccessLevel = accessLevel;
		contentShrare.RowCause = Schema.Tag__Share.RowCause.Manual;
		return contentShrare;
   	}

   	if(sObjectType == 'Navigation__c'){
		Navigation__Share navigationShrare  = new Navigation__Share();
		navigationShrare.ParentId = recordId;
		navigationShrare.UserOrGroupId = userOrGroupId;
		navigationShrare.AccessLevel = accessLevel;
		navigationShrare.RowCause = Schema.Tag__Share.RowCause.Manual;
		return navigationShrare;
   	}

	return null;
  }*/

  public class SharingWrapper{

  	public Map<Id,String> objectIdToMessageErrosMap{get;set;}

  	public List<SObject> listOfSharesToInsert{get;set;}

  	public SharingWrapper(){

  	}

  	public SharingWrapper(Map<Id,String> objectIdToMessageErrosMap, List<SObject> listOfSharesToInsert){
  		this.objectIdToMessageErrosMap = objectIdToMessageErrosMap;
  		this.listOfSharesToInsert = listOfSharesToInsert;
  	}

  }

}