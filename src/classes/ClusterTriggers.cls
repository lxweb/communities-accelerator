public with sharing class ClusterTriggers extends TriggersHandler {

    private final static String readAndWrite = 'RW';
    private final static String readAndOnlyViewDown = 'ROViewDown';
    private final static String readAndOnlyViewUp = 'ROViewUp';
    private final static String separatorGroupName = '_';




    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public ClusterTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true;
        allow_masterLoop_AfterInsert = true;
        allow_masterLoop_AfterDelete = true;
        allow_masterLoop_AfterUpdate = true;
        allow_executeDMLs = true;
        allow_dataPreparing = true;
        
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
    	setExternalId((Cluster__c)recNew);
    }
    public override void masterLoop_AfterInsert(SObject recNew) {
        createGroups((Cluster__c)recNew);
        addLanguages((Cluster__c) recNew, null);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	setExternalId((Cluster__c)recNew);
    }
    public override void masterLoop_AfterDelete(SObject recOld) {
        deleteGroups((Cluster__c)recOld);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addLanguages((Cluster__c) recNew, (Cluster__c) recOld);
    }

    List<Cluster__c> clusterToUpdateLanguageList = new List<Cluster__c>();
    Map<Id,Cluster__c> clusterToUpdateLanguageMap = new Map<Id,Cluster__c>();
    public override void dataPreparing() {
        System.debug('dataPreparing: ');
        if(!clusterIdChildWithParentListLang.isEmpty() && !haveDefaultLanguage){
           List<Cluster__c> clusterList = [SELECT Id, Name, ParentCluster__c, 
                PublicGroupRWName__c, 
                PublicGroupRODownName__c, 
                PublicGroupROUpName__c,
                ParentCluster__r.ParentCluster__c, 
                ParentCluster__r.PublicGroupRWName__c, 
                ParentCluster__r.PublicGroupRODownName__c, 
                ParentCluster__r.PublicGroupROUpName__c,
                ParentCluster__r.DefaultLanguage__c,
                ParentCluster__r.OtherLanguages__c,
                ParentCluster__r.Name,
                ParentCluster__r.ParentCluster__r.ParentCluster__c,
                ParentCluster__r.ParentCluster__r.PublicGroupRWName__c,
                ParentCluster__r.ParentCluster__r.PublicGroupRODownName__c,
                ParentCluster__r.ParentCluster__r.PublicGroupROUpName__c,
                ParentCluster__r.ParentCluster__r.DefaultLanguage__c,
                ParentCluster__r.ParentCluster__r.OtherLanguages__c,
                ParentCluster__r.ParentCluster__r.Name,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.ParentCluster__c,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.PublicGroupRWName__c,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.PublicGroupRODownName__c,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.PublicGroupROUpName__c,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.DefaultLanguage__c,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.OtherLanguages__c,
                ParentCluster__r.ParentCluster__r.ParentCluster__r.Name
            FROM Cluster__c 
            WHERE Id IN: clusterIdChildWithParentListLang];

           
            System.debug('dataPreparing clusterList: ' + clusterList);
            for(Cluster__c cluster: clusterList){


                /*if(cluster.ParentCluster__c != null){
                    mergeOtherLanguage(cluster);
                }

                if(cluster.ParentCluster__r.ParentCluster__c != null){
                    mergeOtherLanguage(cluster.ParentCluster__r);
                }

                if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c != null){
                    mergeOtherLanguage(cluster.ParentCluster__r.ParentCluster__r);
                }*/
                //start
                
                if(cluster.ParentCluster__c != null){
                    if(cluster.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
                        Cluster__c c = new Cluster__c(name=cluster.ParentCluster__r.Name,Id=cluster.ParentCluster__c);
                        c.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.DefaultLanguage__c);
                        clusterToUpdateLanguageList.add(c);

                        if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__c)){
                            String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c;
                            if(otherLanguage != null && otherLanguage != ''){
                                if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){
                                    

                                    //otherLanguage = otherLanguage + ';' + c.OtherLanguages__c;
                                    otherLanguage = writeOtherLanguage(c.OtherLanguages__c,otherLanguage, null);

                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }else{
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }
                                
                                
                            }else{

                                if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = c.OtherLanguages__c;
                                }
                            }
                        }else{
                            clusterToUpdateLanguageMap.put(cluster.ParentCluster__c,c);
                        }

                    }
                }

                if(cluster.ParentCluster__r.ParentCluster__c != null){
                    if(cluster.ParentCluster__r.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
                        Cluster__c c2 = new Cluster__c(name=cluster.ParentCluster__r.ParentCluster__r.Name,Id=cluster.ParentCluster__r.ParentCluster__c);
                        c2.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.ParentCluster__r.DefaultLanguage__c);
                        clusterToUpdateLanguageList.add(c2);




                        if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__r.ParentCluster__c)){
                            String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c;
                            if(otherLanguage != null && otherLanguage != ''){
                                if(c2.OtherLanguages__c != null && c2.OtherLanguages__c != ''){

                                    //otherLanguage = otherLanguage + ';' + c2.OtherLanguages__c;
                                    otherLanguage = writeOtherLanguage(c2.OtherLanguages__c,otherLanguage, null);
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }else{
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }
                                
                                
                            }else{

                                if(c2.OtherLanguages__c != null && c2.OtherLanguages__c != ''){
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c = c2.OtherLanguages__c;
                                }
                            }
                        }else{
                            clusterToUpdateLanguageMap.put(cluster.ParentCluster__r.ParentCluster__c,c2);
                        }




                    }
                }
                
                if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c != null){
                    if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
                        Cluster__c c3 = new Cluster__c(Name=cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.Name,Id=cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c);
                        c3.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.DefaultLanguage__c) ;
                        clusterToUpdateLanguageList.add(c3);




                        if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c)){
                            String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c;
                            if(otherLanguage != null && otherLanguage != ''){
                                if(c3.OtherLanguages__c != null && c3.OtherLanguages__c != ''){
                                    //otherLanguage = otherLanguage + ';' + c3.OtherLanguages__c;
                                    otherLanguage = writeOtherLanguage(c3.OtherLanguages__c,otherLanguage, null);
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }else{
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }
                                
                                
                            }else{

                                if(c3.OtherLanguages__c != null && c3.OtherLanguages__c != ''){
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c = c3.OtherLanguages__c;
                                }
                            }
                        }else{
                            clusterToUpdateLanguageMap.put(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c,c3);
                        }


                    }
                }
            
            //fin
            

            }
            List<Cluster__c> clusterToUpdateLanguageList2 = new List<Cluster__c>();
            for(Id clusterId: clusterToUpdateLanguageMap.keySet()){
                Cluster__c clusterItem = clusterToUpdateLanguageMap.get(clusterId);
                clusterToUpdateLanguageList2.add(clusterItem);

            }
            clusterToUpdateLanguageList = clusterToUpdateLanguageList2;
            
            System.debug('dataPreparing clusterToUpdateLanguageMap: ' + clusterToUpdateLanguageMap);
            System.debug('dataPreparing clusterToUpdateLanguageList: ' + clusterToUpdateLanguageList);
            System.debug('dataPreparing clusterToUpdateLanguageList: ' + clusterToUpdateLanguageList.size());
        }
    }

    public void mergeOtherLanguage(Cluster__c cluster){

        if(cluster.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
            Cluster__c c = new Cluster__c(name=cluster.ParentCluster__r.Name,Id=cluster.ParentCluster__c);
            c.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.DefaultLanguage__c);
            clusterToUpdateLanguageList.add(c);

            


            if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__c)){
                String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c;
                if(otherLanguage != null && otherLanguage != ''){
                    if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){

                        otherLanguage = otherLanguage + ';' + c.OtherLanguages__c;
                        clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                    }else{
                        clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                    }
                    
                    
                }else{

                    if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){
                        clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = c.OtherLanguages__c;
                    }
                }
            }else{
                clusterToUpdateLanguageMap.put(cluster.ParentCluster__c,c);
            }

        }

    }

    public String writeOtherLanguage(String parentOtherlanguage, String otherLanguage, String parentDefaultLanguage){
        Map<String,String> returnOtherLanguage= new Map<String,String>();
        System.debug('ClusterTriggers parentOtherlanguage: ' + parentOtherlanguage);
        System.debug('ClusterTriggers otherLanguage: ' + otherLanguage);
        System.debug('ClusterTriggers parentDefaultLanguage: ' + parentDefaultLanguage);

        if(parentOtherlanguage != null){
            List<String> parentOtherlanguageList = parentOtherlanguage.split(';');
            
            System.debug('ClusterTriggers parentOtherlanguageList: ' + parentOtherlanguageList);
            for(String pOtherL: parentOtherlanguageList){
                returnOtherLanguage.put(pOtherL,pOtherL);
                
            }
        }

        if(otherLanguage!=null){
            List<String> otherlanguageList = otherLanguage.split(';');
            System.debug('ClusterTriggers returnOtherLanguage: ' + returnOtherLanguage);
            for(String otherL: otherlanguageList){
                if(parentDefaultLanguage!=null){
                    if(parentDefaultLanguage != otherL){
                        returnOtherLanguage.put(otherL,otherL);
                    }
                }else{
                    returnOtherLanguage.put(otherL,otherL);
                }

                
            }            
        }

        List<String> otherlanguageList2 = new List<String>(returnOtherLanguage.keySet());
        System.debug('ClusterTriggers otherlanguageList2: ' + otherlanguageList2);
        String returnLanguage = '';
        if(!otherlanguageList2.isEmpty()){
            integer i = 1;
            
            for(String otherL: otherlanguageList2){
                if(returnLanguage != ''){
                    if(i == otherlanguageList2.size()){
                        returnLanguage =+ returnLanguage;
                    }else{
                        returnLanguage = returnLanguage + ';' + otherL;
                    }
                }else{
                    returnLanguage = otherL;
                }
                
            }
        }

        System.debug('ClusterTriggers returnLanguage: ' + returnLanguage);
        return returnLanguage;

    }

    //DMLs Execution
    public override void executeDMLs() {

        if(!clusterToUpdateLanguageList.isEmpty()){
            update clusterToUpdateLanguageList;
        }


        if(!groupsList.isEmpty() && !haveException){
            System.debug('ClusterTriggers executeDMLs groupsList: '+groupsList);

            


            insert groupsList;
            System.debug('ClusterTriggers executeDMLs groupsList: '+groupsList);
            List<Cluster__c> clustersToUpdate = new List<Cluster__c>();
            for(Group groupItem : groupsList){

                List<String> GroupKeyAndGroupType = groupItem.Name.split(separatorGroupName);
                String groupKey;
                String groupType;
                //VERIFICAR EL _ EN EL EXTERNALD ID DEL OTRO TRIGGER
                if(GroupKeyAndGroupType.size()==3){
                    groupKey = groupKeyAndGroupType[0]+'_'+groupKeyAndGroupType[1];
                    groupType = groupKeyAndGroupType[2];
                }else{
                    groupKey = groupKeyAndGroupType[0];
                    groupType = groupKeyAndGroupType[1];
                }

                System.debug('ClusterTriggers groupKey: '+groupKey);
                System.debug('ClusterTriggers groupType: '+groupType);

                System.debug('ClusterTriggers mapGroupDevNameToClusterId: '+mapGroupDevNameToClusterId);
                if(groupType.equals(readAndWrite) && mapGroupDevNameToClusterId.containsKey(groupKey)){
                    Cluster__c clusterToUpdate = new Cluster__c(
                        Id = mapGroupDevNameToClusterId.get(groupKey),
                        PublicGroupRWName__c = groupKey + separatorGroupName + readAndWrite,
                        PublicGroupRODownName__c = groupKey + separatorGroupName + readAndOnlyViewDown,
                        PublicGroupROUpName__c = groupkey + separatorGroupName + readAndOnlyViewUp
                        //PublicGroupROName__c = groupKey + separatorGroupName + readAndOnlyViewUp
                    );
                    clustersToUpdate.add(clusterToUpdate);
                }

                // groupNameToParentId.put(groupItem.name,groupItem.Id)
            }
            System.debug('ClusterTriggers clustersToUpdate: '+clustersToUpdate);
            update clustersToUpdate;
        }

        if(!clusterIdChildWithParentList.isEmpty() && !haveException){

            Map<String, Id> parentGroupNameToGroupIdMap = new Map<String,Id>();
            Map<String, Id> childGroupNameToGroupIdMap = new Map<String,Id>();

            Map<String,String> mapParentGrupNames = new Map<String,String>();

            System.debug('ClusterTriggers clusterIdChildWithParentList: '+clusterIdChildWithParentList);

            List<Cluster__c> clusterIdList = [SELECT Id, Name, ParentCluster__c, PublicGroupRWName__c, PublicGroupRODownName__c, PublicGroupROUpName__c, ParentCluster__r.PublicGroupRWName__c, ParentCluster__r.PublicGroupRODownName__c, ParentCluster__r.PublicGroupROUpName__c, ParentCluster__r.Name 
            FROM Cluster__c 
            WHERE Id IN: clusterIdChildWithParentList];

 

            for(Cluster__c cluster: clusterIdList){

                if(cluster.ParentCluster__c != null){
                    
                    //cluster.OtherLanguages__c = clusterIdToOtherLanguageMap.get(cluster.Id);
                    mapParentGrupNames.put(cluster.ParentCluster__r.PublicGroupRWName__c,cluster.ParentCluster__r.PublicGroupRWName__c);
                    mapParentGrupNames.put(cluster.ParentCluster__r.PublicGroupRODownName__c,cluster.ParentCluster__r.PublicGroupRODownName__c);
                    //FOR VIEW UP
                    mapParentGrupNames.put(cluster.ParentCluster__r.PublicGroupROUpName__c,cluster.ParentCluster__r.PublicGroupROUpName__c);
                    
                }

            }

            System.debug('ClusterTriggers mapParentGrupNames: '+mapParentGrupNames);

            List<Group> listTempGroup = [SELECT Id, Name FROM Group WHERE Name IN: mapParentGrupNames.keyset()];

            System.debug('ClusterTriggers listTempGroup: '+listTempGroup);
            // POPULATE THE PARENT MAP
            for(Group grupItemParent: listTempGroup){
                parentGroupNameToGroupIdMap.put(grupItemParent.name, grupItemParent.Id);
            }

            System.debug('ClusterTriggers parentGroupNameToGroupIdMap: ' + parentGroupNameToGroupIdMap);


            // POPULATE THE CHILD MAP
            List<Group> groupListTemp2 = [SELECT Id, Name FROM Group WHERE Name IN: grupNamesList];
            System.debug('ClusterTriggers groupListTemp2: '+groupListTemp2);
            for(Group grupItem: groupListTemp2){
                childGroupNameToGroupIdMap.put(grupItem.name, grupItem.Id);
            }
            System.debug('ClusterTriggers childGroupNameToGroupIdMap: '+childGroupNameToGroupIdMap);
            
            Map<Id,Map<String,Id>> parentIdToAccessModeToGroupParentIdsMap = new Map<Id,Map<String,Id>>();
            Map<Id,Map<String,List<Id>>> parentIdToAccessModeToGroupClildIdsMap = new Map<Id,Map<String,List<Id>>>();
            System.debug('ClusterTriggers clusterIdList: ' + clusterIdList);
            for(Cluster__c clusterItem: clusterIdList){
                
                
                //For populate information for groups childs cluster map
                Id idRWChild = childGroupNameToGroupIdMap.get(clusterItem.PublicGroupRWName__c);
                Id idROVDownChild = childGroupNameToGroupIdMap.get(clusterItem.PublicGroupRODownName__c);
                //FOR VIEW UP
                Id idROVUpChild = childGroupNameToGroupIdMap.get(clusterItem.PublicGroupROUpName__c);

                if(!parentIdToAccessModeToGroupClildIdsMap.containsKey(clusterItem.ParentCluster__c)){
                    parentIdToAccessModeToGroupClildIdsMap.put(clusterItem.ParentCluster__c,new Map<String,List<Id>>());
                }

                if(!parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).containsKey(readAndWrite)){
                    parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).put(readAndWrite, new List<Id>());   
                }

                if(!parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).containsKey(readAndOnlyViewDown)){
                    parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewDown, new List<Id>());
                }
                //FOR VIEW UP
                if(!parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).containsKey(readAndOnlyViewUp)){
                    parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewUp, new List<Id>());
                }

                parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).get(readAndWrite).add(idRWChild);
                parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).get(readAndOnlyViewDown).add(idROVDownChild);
                //FOR VIEW UP
                parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).get(readAndOnlyViewUp).add(idROVUpChild);
                

                System.debug('ClusterTriggers parentIdToAccessModeToGroupClildIdsMap: ' + parentIdToAccessModeToGroupClildIdsMap);
                System.debug('ClusterTriggers parentIdToAccessModeToGroupClildIdsMap: ' + parentIdToAccessModeToGroupClildIdsMap.size());



                //For populate information for groups parents cluster map
                Id idRWParent = parentGroupNameToGroupIdMap.get(clusterItem.ParentCluster__r.PublicGroupRWName__c);
                Id idROVDownParent = parentGroupNameToGroupIdMap.get(clusterItem.ParentCluster__r.PublicGroupRODownName__c);
                //FOR VIEW UP
                Id idROVUpParent = parentGroupNameToGroupIdMap.get(clusterItem.ParentCluster__r.PublicGroupROUpName__c);

                if(!parentIdToAccessModeToGroupParentIdsMap.containsKey(clusterItem.ParentCluster__c)){
                    parentIdToAccessModeToGroupParentIdsMap.put(clusterItem.ParentCluster__c,new Map<String,Id>());
                }

                parentIdToAccessModeToGroupParentIdsMap.get(clusterItem.ParentCluster__c).put(readAndWrite,idRWParent);
                parentIdToAccessModeToGroupParentIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewDown,idROVDownParent);
                //FOR VIEW UP
                parentIdToAccessModeToGroupParentIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewUp,idROVUpParent);
                
                System.debug('ClusterTriggers parentIdToAccessModeToGroupParentIdsMap: ' + parentIdToAccessModeToGroupParentIdsMap);
                System.debug('ClusterTriggers parentIdToAccessModeToGroupParentIdsMap: ' + parentIdToAccessModeToGroupParentIdsMap.size());


            }

                
                List <String> groupChildIdToParentIdsList = new List<String>();
                for(Id parentClusterId: parentIdToAccessModeToGroupParentIdsMap.keySet()){

                    String parentGroupIdRW = (String) parentIdToAccessModeToGroupParentIdsMap.get(parentClusterId).get(readAndWrite);
                    String parentGroupIdRO = (String) parentIdToAccessModeToGroupParentIdsMap.get(parentClusterId).get(readAndOnlyViewDown);
                    String parentGroupIdROVUp = (String) parentIdToAccessModeToGroupParentIdsMap.get(parentClusterId).get(readAndOnlyViewUp);

                    for(Id childGroupIdRW: parentIdToAccessModeToGroupClildIdsMap.get(parentClusterId).get(readAndWrite)){
                        //(userOrGroup_target)
                        groupChildIdToParentIdsList.add(parentGroupIdRW+'_'+childGroupIdRW);
                    }

                    for(Id childGroupIdRO: parentIdToAccessModeToGroupClildIdsMap.get(parentClusterId).get(readAndOnlyViewDown)){

                        groupChildIdToParentIdsList.add(parentGroupIdRO+'_'+childGroupIdRO);
                    }

                    //FOR VIEW UP
                    for(Id childGroupIdROVUp: parentIdToAccessModeToGroupClildIdsMap.get(parentClusterId).get(readAndOnlyViewUp)){
                        
                        groupChildIdToParentIdsList.add(childGroupIdROVUp+'_'+parentGroupIdROVUp);
                    }

                }
                matchGroupsWithParentCLusterGroups(groupChildIdToParentIdsList);

        }

        if(!groupNameToDeleteList.isEmpty()){
            List<Id> groupIdToDeleteList = new List<Id>();
            for(Group g: [SELECT Id, Developername, Name FROM Group Where Developername IN: groupNameToDeleteList]){
                groupIdToDeleteList.add(g.Id);
            }
            callFutureDeleteOfGroups(groupIdToDeleteList);
        }
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
	private void setExternalId(Cluster__c recNew){
        if(!canMethod('setExternalId')){return;}
        //System.debug('recNew.ParentCluster__c');
        if(recNew.ExternalID__c == null){
            //recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.ParentCluster__c);
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name);
        }
    }

    /* CREATION OF GROUPS FOR SECURITY */
    
    //eliminar si no se le da uso

    Boolean haveException = false;
    List<String> grupNamesList = new List<String>();

    List<Id> clusterIdChildWithParentList = new List<Id>();
    Map<String, Id> mapGroupDevNameToClusterId = new Map<String, Id>();
    List<Group> groupsList = new List<Group>();
    private void createGroups(Cluster__c recNew){
        if(!canMethod('createGroups')){return;}
        AcceleratorSettings__c acceleratorSettings = AcceleratorSettings__c.getOrgDefaults();
        
        //TODO
        //Tipo campo tiene que ser texto

        String groupName = '';
        
        Map<String,Schema.SObjectField> sobjectDescribeMap = Schema.getGlobalDescribe().get('Cluster__c').getDescribe().fields.getMap();
        try{        
            String fieldName = acceleratorSettings.ClusterFieldForPublicGroups__c;
            Schema.DescribeFieldResult fieldDescribe = sobjectDescribeMap.get(fieldName).getDescribe();

            if(fieldName != null && fieldDescribe.getType() == Schema.DisplayType.STRING){

                groupName = (String) recNew.get(fieldName);

                //groupName = (String) recNew.get('ExternalId__c1');//(ExternalId__c by default)
                //System.debug('ClusterTrigger createGroups groupName1: ' + groupName);

            }else{
                //Verificar que el campo no sea null
                //System.Label.nameLabel
                //recNew.AddError('Se debe configurar la custom settings "Accelerator Settings" con un campo de tipo texto');
                recNew.AddError(System.Label.SetUpAcceleratorSetting);
                haveException = true;
            }
            

        }catch(Exception ex){
            //Veirificar antes que el campo exista
            //System.Label.nameLabel
            //recNew.AddError('El campo seleccionado en custom settings "Accelerator Settings" es incorrecto');
            recNew.AddError(System.Label.AcceleratorSettingWrongField);
            haveException = true;

        }
        
        System.debug('ClusterTriggers createGroups groupName: ' + groupName);

        groupName = groupName.replaceAll('[^a-zA-Z0-9]','');

        groupName = GeneralUtils.getSubstring(groupName, 29);
        mapGroupDevNameToClusterId.put(groupName, recNew.Id);
        if(recNew.ParentCluster__c != null){
            clusterIdChildWithParentList.add(recNew.Id);
        }

        //readAndOnlyViewDown
        String groupNameRW = groupName + separatorGroupName + readAndWrite;
        String groupNameROViewUp = groupName + separatorGroupName + readAndOnlyViewUp;
        String groupNameROViewDown = groupName + separatorGroupName + readAndOnlyViewDown;
        System.debug('ClusterTrigger createGroups groupNameRW: ' + groupNameRW);
        System.debug('ClusterTrigger createGroups groupNameROViewUp: ' + groupNameROViewUp);
        System.debug('ClusterTrigger createGroups groupNameROViewDown: ' + groupNameROViewDown);

        Group publicGroupRW = new Group(Name = groupNameRW, Developername = groupNameRW, DoesIncludeBosses = false);
        groupsList.add(publicGroupRW);

        Group publicGroupROViewUp = new Group(Name = groupNameROViewUp, Developername = groupNameROViewUp, DoesIncludeBosses = false);
        groupsList.add(publicGroupROViewUp);

        Group publicGroupROViewDown = new Group(Name = groupNameROViewDown, Developername = groupNameROViewDown, DoesIncludeBosses = false);
        groupsList.add(publicGroupROViewDown);
        System.debug('ClusterTrigger createGroups publicGroupRW: ' + publicGroupRW);
        System.debug('ClusterTrigger createGroups publicGroupROViewUp: ' + publicGroupROViewUp);
        System.debug('ClusterTrigger createGroups publicGroupROViewDown: ' + publicGroupROViewDown);

        System.debug('ClusterTrigger createGroups groupsList: ' + groupsList);
        grupNamesList.add(publicGroupRW.name);
        grupNamesList.add(publicGroupROViewUp.name);
        grupNamesList.add(publicGroupROViewDown.name);
    }
    



    List<Id> clusterIdChildWithParentListLang = new List<Id>();
    Map<Id,String> clusterIdToOtherLanguageMap = new Map<Id,String>();
    Boolean haveDefaultLanguage = false;
    private void addLanguages(Cluster__c recNew, Cluster__c recOld){

        System.debug('recNew.id: '+recNew.Id);
        if(!canMethod('addLanguages')){return;}
        
        System.debug('recOld.OtherLanguages__c: ' + recNew.DefaultLanguage__c);
        System.debug('recNew.OtherLanguages__c: ' + recNew.OtherLanguages__c);

        String developerName = recNew.name;
        string recordtypename = Schema.SObjectType.Cluster__c.getRecordTypeInfosById().get(recNew.recordtypeid).getname();
        System.debug('recordtypename: ' + recordtypename);
        if(recordtypename == 'Cluster Leaf'){
            System.debug('addLanguages recNew.OtherLanguages__c: '+recNew.OtherLanguages__c);
            if(recNew.OtherLanguages__c != null){
                List<String> otherLanguagesList = recNew.OtherLanguages__c.split(';');
                for(String lang: otherLanguagesList){
                    if(lang == recNew.DefaultLanguage__c){
                        recNew.AddError(System.Label.ExistByDefaultLanguage);
                        haveDefaultLanguage = true;
                        haveException = true;
                    }
                }
            }
            if(recOld!=null){
                clusterIdChildWithParentListLang.add(recNew.Id);
                System.debug('update recNew.OtherLanguages__c: ' + recNew.OtherLanguages__c);
                if(recNew.OtherLanguages__c != recOld.OtherLanguages__c){
                    System.debug('update have1  recNew.OtherLanguages__c: ' + recNew.OtherLanguages__c);
                    clusterIdToOtherLanguageMap.put(recNew.Id,recNew.OtherLanguages__c);
                    
                }

                System.debug('update recNew.DefaultLanguage__c: ' + recNew.DefaultLanguage__c);
                if(recNew.DefaultLanguage__c != recOld.DefaultLanguage__c){
                    
                    String newOtherLanguagesPlusDefault = '';
                    System.debug('update have2 recNew.OtherLanguages__c: ' + recNew.OtherLanguages__c);
                    
                    if(recNew.OtherLanguages__c != null && recNew.OtherLanguages__c != ''){
                        
                        System.debug('update have3 recNew.newOtherLanguagesPlusDefault: ' + newOtherLanguagesPlusDefault);
                        newOtherLanguagesPlusDefault = recNew.OtherLanguages__c + ';' + recNew.DefaultLanguage__c;       
                        System.debug('update have3 recNew.newOtherLanguagesPlusDefault: ' + newOtherLanguagesPlusDefault);
                    }else{
                        
                        System.debug('update have4 newOtherLanguagesPlusDefault: ' + newOtherLanguagesPlusDefault);
                        newOtherLanguagesPlusDefault =  recNew.DefaultLanguage__c;
                        System.debug('update have4 newOtherLanguagesPlusDefault: ' + newOtherLanguagesPlusDefault);
                    }
                    System.debug('update have5 newOtherLanguagesPlusDefault: ' + newOtherLanguagesPlusDefault);
                    clusterIdToOtherLanguageMap.put(recNew.Id,newOtherLanguagesPlusDefault);
                }

            }else{

                clusterIdChildWithParentListLang.add(recNew.Id);
                String newOtherLanguagesPlusDefault = '';
                System.debug('insert recNew.OtherLanguages__c: ' + recNew.OtherLanguages__c);
                if(recNew.OtherLanguages__c != null && recNew.OtherLanguages__c != ''){
                    clusterIdToOtherLanguageMap.put(recNew.Id,recNew.OtherLanguages__c);
                    if(recNew.DefaultLanguage__c != null && recNew.DefaultLanguage__c != null){
                        newOtherLanguagesPlusDefault = recNew.OtherLanguages__c + ';' + recNew.DefaultLanguage__c;
                        clusterIdToOtherLanguageMap.put(recNew.Id,newOtherLanguagesPlusDefault);
                    }

                }else{
                    System.debug('recNew.DefaultLanguage__c: ' + recNew.DefaultLanguage__c);
                    if(recNew.DefaultLanguage__c != null && recNew.DefaultLanguage__c != ''){
                        newOtherLanguagesPlusDefault = recNew.DefaultLanguage__c;
                        clusterIdToOtherLanguageMap.put(recNew.Id,newOtherLanguagesPlusDefault);
                    }

                }
                
            }
                System.debug('push clusterIdToOtherLanguageMap: ' + clusterIdToOtherLanguageMap.get(recNew.Id));
        }
        System.debug('clusterIdToOtherLanguageMap: ' + clusterIdToOtherLanguageMap);
        System.debug('clusterIdChildWithParentListLang: ' + clusterIdChildWithParentListLang);
    }

    /* DELETION GROUPS FOR SECURITY */
    List<String> groupNameToDeleteList = new List<String>();
    private void deleteGroups(Cluster__c recOld){
        if(!canMethod('deleteGroups')){return;}

        if(recOld.PublicGroupRWName__c != null){
            groupNameToDeleteList.add(recOld.PublicGroupRWName__c);
        }

        if(recOld.PublicGroupRODownName__c != null){
            groupNameToDeleteList.add(recOld.PublicGroupRODownName__c);
        }

        if(recOld.PublicGroupROUpName__c != null){
            groupNameToDeleteList.add(recOld.PublicGroupROUpName__c);
        }
    }

    /* UTILITY METHODS */
    @future
    public static void matchGroupsWithParentCLusterGroups(List<String> groupChaildIdToParentIdList){
        List<GroupMember> gropupMemberList = new List<GroupMember>();
        for(String groupChaildIdToParentId: groupChaildIdToParentIdList){
            GroupMember groupMemberItem = new GroupMember(
                UserOrGroupId = groupChaildIdToParentId.split('_')[0],
                GroupId = groupChaildIdToParentId.split('_')[1]
            );
            gropupMemberList.add(groupMemberItem);
        }
        insert gropupMemberList;
    }

    @future
    public static void callFutureDeleteOfGroups(List<Id> groupIds){
        delete [SELECT Id FROM Group WHERE Id IN: groupIds];
    }


}