public with sharing class CG_BaseComponentController {
    
    //WRAPPERS
    public class ComponentWrapper{
		@auraEnabled public AcceleratorSettings__c acceleratorSettings;
		@auraEnabled public Boolean isEnabledCommunityEditFrame;
		@auraEnabled public Boolean isEnabledCommunityViewFrame;
        @auraEnabled public Component__c component;
		@auraEnabled public List<String> listAllContentIds;
		@auraEnabled public List<ContentWrapper> contentWrapper;
		@auraEnabled public List<Integer> pagesNumbers;
        @auraEnabled public List<Category__c> categories;
		@auraEnabled public List<Tag__c> tags;
		@auraEnabled public String clusterId;
		public ComponentWrapper(){
			this.acceleratorSettings = AcceleratorSettings__c.getInstance();
            this.isEnabledCommunityEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
            this.isEnabledCommunityViewFrame = FeatureManagement.checkPermission('CommunityViewFrame');
		}
	}
    
    public class ContentWrapper{
        @auraEnabled public Content__c content;
        @auraEnabled public List<MediaElement__c> mediaElements;
    }

    @auraEnabled
	public static ComponentWrapper getComponentWrapper(String componentExternalId, String componentType, String parentComponentId, String parentContentId, String clusterId, String device){

		Component__c component;
		Component__c parentComponent;
		set<String> setContentDirect;
		set<String> setContentToExclude;

		//Si no se parametrizan Clusters busco los default
		if(clusterId == null || clusterId.trim() == ''){
			clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
		}
		set<String> setClusterIds = ClusterUtils.getClustersParents(clusterId);
		//Busqueda de componente
		component = ComponentUtils.getComponent(componentExternalId, getComponentFieldSetByComponentType(componentType, device), device);
		
		if(componentType == 'RelatedNews' || componentType == 'RelatedEvents'){
			//Busqueda del componente padre
			String parentComponentType;
			if(componentType == 'RelatedNews'){parentComponentType = 'News';}
			if(componentType == 'RelatedEvents'){parentComponentType = 'Event';}

			parentComponent = ComponentUtils.getComponent(parentComponentId, getComponentFieldSetByComponentType(parentComponentType, device), device);

			if(parentContentId != null && parentContentId != ''){
				setContentToExclude = new set<String>{parentContentId};
			}
		}else{
			if(componentType.contains('Detail') && parentContentId != null && parentContentId != ''){
				setContentDirect = new set<String>{parentContentId};
			}
		}

		//Busqueda de contenido
		ContentUtils.ContentWrapper contentWrapper;
		if(component != null)
		{
			if (component.Datasource__c == 'ParentComponentBehaviour'){
				contentWrapper = ContentUtils.getContentFromComponent(parentComponent, getContentFieldSetByComponentType(parentComponent.Recordtype.Developername, device), setContentDirect, setContentToExclude, setClusterIds, device);
				for (String fieldApiName: getComponentFieldSetByComponentType(component.RecordType.DeveloperName, device)){
					if (fieldApiName != 'Id' && fieldApiName != 'ExternalId__c' && fieldApiName != 'Recordtype.Developername'){
						if (fieldApiName == 'PageSize__c'){
							component.PageSize__c = parentComponent.PageSize__c;
                        }else if(fieldApiName == 'LinkDetail__r.URL__c'){
                            component.LinkDetail__r = parentComponent.LinkDetail__r;
                        } else {
							component.put(fieldApiName, (String)GeneralUtils.getFieldValue(parentComponent, fieldApiName));
						}
					}
				}
			}else{
				if(componentType == 'Banner' || componentType == 'News' || componentType == 'Event' || 
				componentType == 'AdvanceContent' || componentType == 'FAQ' || 
				componentType == 'NewsDetail' || componentType == 'EventDetail' || componentType == 'RelatedNews' ||
				componentType == 'RelatedEvents'){
					contentWrapper = ContentUtils.getContentFromComponent(component, getContentFieldSetByComponentType(component.Recordtype.Developername, device), setContentDirect, setContentToExclude, setClusterIds, device);
				}
			}
		}

		//Armado del Component Wrapper
		ComponentWrapper cw = new ComponentWrapper();
		
		//Verificar los custom permisions
		if(FeatureManagement.checkPermission(componentType + 'EditFrame') || FeatureManagement.checkPermission('CommunityEditFrame')){
			cw.isEnabledCommunityEditFrame = true;
		}else{
			cw.isEnabledCommunityEditFrame = false;
		}

		if(FeatureManagement.checkPermission(componentType + 'ViewFrame') || FeatureManagement.checkPermission('CommunityViewFrame')){
			cw.isEnabledCommunityViewFrame = true;
		}else{
			cw.isEnabledCommunityViewFrame = false;
		}



		cw.component = component;
		cw.clusterId = clusterId;

		cw.listAllContentIds = new List<String>();
		cw.contentWrapper = new List<ContentWrapper>();
		cw.pagesNumbers = new List<Integer>();
		

		if(contentWrapper != null){
			if(contentWrapper.setAllContentIds != null){
				cw.listAllContentIds.addAll(contentWrapper.setAllContentIds);
			}
			if(contentWrapper.contentDataPage != null){
				cw.contentWrapper = convertDataToWrapper(contentWrapper.contentDataPage);
			}
			if(contentWrapper.totalPages != null){
				for(Integer i = 1; i <= contentWrapper.totalPages; i++){
					cw.pagesNumbers.add(i);
				}
			}
		}
		
		return cw;
	}

	@auraEnabled
	public static List<ContentWrapper> getPage(List<String> listAllContentIds, String componentType, String pageSize, String pageNumber, String orderBy, String device){
		set<String> setAllContentIds = new set<String>();
		setAllContentIds.addAll(listAllContentIds);

		List<ContentUtils.ContentDataWrapper> contentDataWrapper = ContentUtils.getContentPage(
			setAllContentIds,
			getContentFieldSetByComponentType(componentType, device),
			Integer.valueOf(pageNumber),
			Integer.valueOf(pageSize),
			orderBy,
			device,
			componentType
		);

		List<ContentWrapper> contentWrapper = convertDataToWrapper(contentDataWrapper);
        return contentWrapper;
    }

    private static List<ContentWrapper> convertDataToWrapper(List<ContentUtils.ContentDataWrapper> contentDataWrapper){
    	List<ContentWrapper> contentWrapper = new List<ContentWrapper>();
    	for(ContentUtils.ContentDataWrapper cdw: contentDataWrapper){
    		ContentWrapper cw = new ContentWrapper();
    		cw.content = cdw.content;
    		cw.mediaElements = cdw.mediaElements;
    		contentWrapper.add(cw);
    	}
    	return contentWrapper;
    }

    private static set<String> getComponentFieldSetByComponentType(String componentType, String device){
        set<String> setFields;
        if(componentType == 'Banner'){			setFields = new set<String>{'BannerFrameType__c','Orientation__c','BannerType__c','ShowBullets__c','AutomaticTransition__c','BannerTransitionTime__c','Loop__c','Direction__c'};}
        if(componentType == 'News'){			setFields = new set<String>{'NewsType__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'Event'){			setFields = new set<String>{'EventsType__c', 'ExcludePastEvents__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'AdvanceContent'){	setFields = new set<String>{};}
        if(componentType == 'FAQ'){				setFields = new set<String>{};}
        if(componentType == 'NewsDetail'){		setFields = new set<String>{};}
        if(componentType == 'EventDetail'){		setFields = new set<String>{};}
        if(componentType == 'RelatedNews'){		setFields = new set<String>{'NewsType__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'RelatedEvents'){	setFields = new set<String>{'EventsType__c', 'ExcludePastEvents__c', 'PagingType__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'Brand_Detail'){   	setFields = new set<String>{};}
		if(componentType == 'Cluster_Selector'){	setFields = new set<String>{};}
        if(componentType == 'Language_Selector'){	setFields = new set<String>{};}
        if(componentType == 'Content_Cart'){	setFields = new set<String>{};}
        if(componentType == 'Navigation'){	setFields = new set<String>{};}
        
        //Default fields
        setFields.add('Id');
        setFields.add('Name');
        setFields.add('Recordtype.Developername');
        setFields.add('Datasource__c');
        setFields.add('OrderBy__c');
        setFields.add('OrderByAdvance__c');
        setFields.add('PageSize__c');
        setFields.add('HierarchicalOrderBy__c');
        setFields.add('TagCriteria__c');

        return setFields;
    }

    private static set<String> getContentFieldSetByComponentType(String componentType, String device){
    	if(componentType == 'RelatedEvents'){componentType = 'Event';}
    	if(componentType == 'RelatedNews'){componentType = 'News';}
    	
        set<String> setFields;
        if(componentType == 'Banner'){			setFields = new set<String>{'LinkDetail__r.URL__c','OverlayQuadrant__c', 'Title__c', 'Extract__c', 'ButtonLabel__c','BannerFrameType__c'};}
        if(componentType == 'News'){			setFields = new set<String>{'Title__c','Body__c', 'Extract__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'Event'){			setFields = new set<String>{'Title__c','Body__c', 'Extract__c', 'EventStartDate__c', 'EventEndDate__c', 'Location__c', 'LinkDetail__r.URL__c', 'ExternalId__c'};}
        if(componentType == 'AdvanceContent'){	setFields = new set<String>{'HTMLContent__c'};}
        if(componentType == 'FAQ'){				setFields = new set<String>{'Title__c', 'Body__c'};}
        if(componentType == 'NewsDetail'){		setFields = new set<String>{'Title__c', 'Extract__c','Body__c','Layout__c'};}
        if(componentType == 'EventDetail'){		setFields = new set<String>{'Title__c', 'Extract__c','Body__c', 'EventStartDate__c', 'EventEndDate__c', 'Location__c','Layout__c'};}
        if(componentType == 'Cluster_Selector'){	setFields = new set<String>{};}
		if(componentType == 'Brand_Detail'){   	setFields = new set<String>{};}
        if(componentType == 'Language_Selector'){	setFields = new set<String>{};}
        if(componentType == 'Content_Cart'){	setFields = new set<String>{};}
        if(componentType == 'Navigation'){	setFields = new set<String>{};}
        setFields.add('Id');
        setFields.add('Name');

        return setFields;
    }
}