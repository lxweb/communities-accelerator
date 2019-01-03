public class NavigationController {
	//WRAPPERS
    public class ComponentWrapper{
		@auraEnabled public AcceleratorSettings__c acceleratorSettings;
        @auraEnabled public Component__c component;
		@auraEnabled public String clusterId;
		@auraEnabled public List<NavWrapper> navWrapper;
		@auraEnabled public String device;
		@auraEnabled public Boolean isEnabledCommunityEditFrame;

		public ComponentWrapper (){
			this.acceleratorSettings = AcceleratorSettings__c.getInstance();
			this.isEnabledCommunityEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
			this.navWrapper = new List<NavWrapper>();
		}
	}

	public class NavWrapper {
        @auraEnabled public String label {get;set;}
        @auraEnabled public List<NavWrapper> subMenus{get;set;}       

        public NavWrapper( String label) {
            this.label = label;
            this.subMenus = new List<NavWrapper>();
    	}
	}
	@auraEnabled
	public static ComponentWrapper getNavWrapper(String componentExternalId, String clusterId, String device) {
		// List of fields
  		set<String> setFields = new set<String>{'Id','Name', 'ExternalId__c','Recordtype.Developername','NavigationMode__c','HasDelay__c', 'DelayTime__c'};

  		if(clusterId == null || clusterId.trim() == ''){
			clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
		}

		set<String> setClusterIds = ClusterUtils.getClustersParents(clusterId);

		//Busqueda de componente
		Component__c component = ComponentUtils.getComponent(componentExternalId, setFields, device);
		
		// TODO buscar los navigation Items

		//Armado del Component Wrapper
		ComponentWrapper cw = new ComponentWrapper();
		cw.component = component;
		cw.clusterId = clusterId;
		cw.device = device;

		cw.navWrapper = getTest();
		return cw;
	}

	@auraEnabled
	public static List<NavWrapper> getTest(){
		List<NavWrapper> navList = new List<NavWrapper>();
		navList.add(new NavWrapper('SHOP'));
		navList.add(new NavWrapper('DISCOVER'));
		navList.add(new NavWrapper('SERVICE'));
		navList.add(new NavWrapper('TROUBLESHOOTING'));
		navList.add(new NavWrapper('BRANDS'));

		navList[4].subMenus.add(new NavWrapper('SMIRNOFF'));
		navList[4].subMenus.add(new NavWrapper('GUINNESS'));
		navList[4].subMenus.add(new NavWrapper('BAILEYS'));
		navList[1].subMenus.add(new NavWrapper('FUTURE'));
		navList[1].subMenus.add(new NavWrapper('PAST'));

		navList[4].subMenus[0].subMenus.add(new NavWrapper('RED LABEL'));
		navList[4].subMenus[0].subMenus.add(new NavWrapper('SILVER LABEL'));
		navList[4].subMenus[0].subMenus.add(new NavWrapper('BLACK'));
		navList[4].subMenus[1].subMenus.add(new NavWrapper('EXTRA STOUT'));
		navList[4].subMenus[1].subMenus.add(new NavWrapper('DRAUGHT BITTER'));

		navList[4].subMenus[1].subMenus[1].subMenus.add(new NavWrapper('MORE BITTER'));
		navList[4].subMenus[1].subMenus[1].subMenus.add(new NavWrapper('MORE BITTER'));
		navList[4].subMenus[1].subMenus[1].subMenus.add(new NavWrapper('MORE BITTER'));
		navList[4].subMenus[1].subMenus[0].subMenus.add(new NavWrapper('other'));
		navList[4].subMenus[1].subMenus[0].subMenus.add(new NavWrapper('other'));
		navList[4].subMenus[1].subMenus[0].subMenus.add(new NavWrapper('other'));

		/* examples 
		navList.add(new NavWrapper('1'));
		navList[0].subMenus.add(new NavWrapper('2'));
		navList[0].subMenus[0].subMenus.add(new NavWrapper('3'));
		navList[0].subMenus[0].subMenus[0].subMenus.add(new NavWrapper('4'));*/
		return navList;
	}
}