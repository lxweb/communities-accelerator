public class CG_NavigationController {

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
        @auraEnabled public Menu__c menu {get;set;}
        @auraEnabled public List<NavWrapper> subMenus {get;set;}
        @auraEnabled public String behaviour {get;set;}
        @auraEnabled public String iconName {get;set;}

        public NavWrapper(Menu__c menu) {
            this.menu = menu;
            this.subMenus = new List<NavWrapper>();
            this.behaviour = menu.Behaviour__c == 'New Tab' ? '_blank' : '_self';
            this.iconName = menu.MenuIcon__c;
    	}
	}
	@auraEnabled
	public static ComponentWrapper getNavWrapper(String componentExternalId, String clusterId, String device) {
		// List of fields
  		set<String> setFields = new set<String>{'Id','Name', 'ExternalId__c','Recordtype.Developername','NavigationMode__c','HasDelay__c', 'DelayTime__c', 'Cluster__c'};

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

		cw.navWrapper = getWrapperFromComponent(component, cw.clusterId);
		return cw;
	}

	@auraEnabled
	public static List<NavWrapper> getWrapperFromComponent(Component__c component, String clusterId){
		// Busqueda de Menus con Assignments al Component
		List<MenuAssignment__c> menuAssignments = [SELECT Id, Component__c, Component__r.Cluster__c, Menu__c, Menu__r.Cluster__c FROM MenuAssignment__c WHERE Component__c =: component.Id];
        List<String> menuIds = new List<String>();
		for(MenuAssignment__c ma : menuAssignments){
			if(ma.Component__r.Cluster__c == ma.Menu__r.Cluster__c){
				menuIds.add(ma.Menu__c);
			}
		}
		List<String> allClusterIds = getAllClusterIds(clusterId);
		List<NavWrapper> menuWrappers = new List<NavWrapper>();
		List<Menu__c> allMenus = getAllMenus(menuIds);
		for(String menuId : MenuIds){
            NavWrapper newWrapper = getMenuWrapper(menuId, allMenus, allClusterIds);
            if(newWrapper != null){
                menuWrappers.add(newWrapper);
            }                
		}
		return menuWrappers;
	}

	// Traemos todos los Clusters relacionados a los SubMenus	
	public static List<String> getAllClusterIds(String clusterId){
		Cluster__c userCluster = [SELECT Id, ParentCluster__c, ParentCluster__r.ParentCluster__c,
		ParentCluster__r.ParentCluster__r.ParentCluster__c FROM Cluster__c WHERE Id =: clusterId];

		List<String> allClusterIds = new List<String>();
		
		allClusterIds.add(userCluster.Id);
		if(userCluster.ParentCluster__c != null){
			allClusterIds.add(userCluster.ParentCluster__c);
		}
		if(userCluster.ParentCluster__r.ParentCluster__c != null){
			allClusterIds.add(userCluster.ParentCluster__r.ParentCluster__c);
		}
		if(userCluster.ParentCluster__r.ParentCluster__r.ParentCluster__c != null){
			allClusterIds.add(userCluster.ParentCluster__r.ParentCluster__r.ParentCluster__c);
		}

		List<Cluster__c> clustersBelow = [SELECT Id FROM Cluster__c WHERE Id =: userCluster.Id 
					OR ParentCluster__c =: userCluster.Id 
    				OR ParentCluster__r.ParentCluster__c =: userCluster.Id 
    				OR ParentCluster__r.ParentCluster__r.ParentCluster__c =: userCluster.Id];

		System.debug(allClusterIds); 
		System.debug(clustersBelow);

    	for(Cluster__c cluster : clustersBelow){
    		if(cluster != null){
    			allClusterIds.add(cluster.Id);
    		}
    	}

		return allClusterIds;
	}

	// Traemos todos los SubMenus relacionados a los Menus del Component	
	public static List<Menu__c> getAllMenus(List<String> menuIds){
		return [SELECT Id, MenuLabel__c, ParentMenu__c, Cluster__c, Behaviour__c, Navigation__r.URL__c, MenuIcon__c FROM Menu__c WHERE Id =: menuIds 
					OR ParentMenu__c =: menuIds 
    				OR ParentMenu__r.ParentMenu__c =: menuIds 
    				OR ParentMenu__r.ParentMenu__r.ParentMenu__c =: menuIds];
	}

	// Armamos los Wrappers
	public static NavWrapper getMenuWrapper(Id currentMenuId, List<Menu__c> allMenus, List<String> allClusterIds){
		Menu__c currentMenu = [SELECT Id, MenuLabel__c, Cluster__c FROM Menu__c WHERE Id =: currentMenuId]; 
		// Armamos un mapa con el Wrapper dde cada Menu
    	map<Menu__c, NavWrapper> menuWrapperMap = new map<Menu__c, NavWrapper>(); 
    	for(Menu__c menu : allMenus){
    		menuWrapperMap.put(menu, new NavWrapper(menu));
    	}
    	// Si el Cluster de child esta en la lista de Clusters
		// Para cada parent padre de child, agregamos child a los hijos de parent
		// El MenuWrapperMap toma forma de arbol
    	for(Menu__c parent : menuWrapperMap.keySet()){
    		for(Menu__c child : menuWrapperMap.keySet()){
    			if(child.ParentMenu__c == parent.Id && allClusterIds.contains(child.Cluster__c)){
    				menuWrapperMap.get(parent).subMenus.add(menuWrapperMap.get(child));
    			}
    		}
    	}
    	//Devolvemos el nodo raiz del arbol creado
    	return menuWrapperMap.get(currentMenu);
	}

}