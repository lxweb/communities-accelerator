public with sharing class NavigationTriggers extends TriggersHandler{
	public NavigationTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);

        //PA-177 CMA: Clustering: Apex Sharing
        allow_masterLoop_AfterUpdate = true;
        allow_masterLoop_AfterInsert = true;

        allow_dataPreparing = true;
        allow_executeDMLs = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;

	}

    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/

    //PA-177 CMA: Clustering: Apex Sharing
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Navigation__c) recNew, null, true);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Navigation__c) recNew, (Navigation__c) recOld, true);
    }
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Navigation__c) recNew,null, false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Navigation__c) recNew, (Navigation__c) recOld, false);
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<Navigation__Share> navigationShareList = new List<Navigation__Share>();
    Boolean excecuteTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
    
    public override void dataPreparing() {
        if(!recordList.isEmpty() && excecuteTrigger){
            List<SObject> listSO = new List<SObject>();

            //listSO = ObjectSharingUtil.generateSharingForRecordsOnCluster(recordList, 'Cluster__c');
            ObjectSharingUtil.SharingWrapper sharingWrapper = ObjectSharingUtil.generateSharingForRecordsOnCluster(recordList, 'Cluster__c', 'Navigation__Share', 'Clustering__c',false);
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
            	objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
            	excecuteTrigger = false;
                System.debug('NavigationTriggers dataPreparing have an exception: ');
            }else{
            	navigationShareList  = (List<Navigation__Share>) sharingWrapper.listOfSharesToInsert;
                System.debug('NavigationTriggers dataPreparing have not exception: ');
            }
        }

    }


    public override void executeDMLs() {
        
        if(!navigationShareList.isEmpty() && excecuteTrigger){
            try{
                insert navigationShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,'It must create a sharing reason for Navigation Sharing');
            }
        }
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Navigation__c recNew, Navigation__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}
        
        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey('Navigation__Share')) {
                
                if(recOld != null){
                    if(recNew.Cluster__c !=  recOld.Cluster__c){
                        if(recNew.Cluster__c == null){ 
                            excecuteTrigger = false;
                            //recNew.addError('The object must containg a loockup relation to Cluster');
                        }else{
                            System.debug('Update custom object is private or public read only');
                            recordList.add(recNew);
                        }
                    }

                }else{
                    
                    if(recNew.Cluster__c == null){ 
                        excecuteTrigger = false;
                        //recNew.addError('The object must containg a loockup relation to Cluster');
                    }else{
                        System.debug('Insdert custom object is private or public read only');
                        recordList.add(recNew);
                    }
                }
            }


        }else{
            if(objectIdToMessageErrosMap.containsKey(recNew.Id)){
                recNew.addError(objectIdToMessageErrosMap.get(recNew.Id));
            }
        }

    }

}