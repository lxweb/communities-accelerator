public without sharing virtual class FE_ComponentManager {
    
    //Parameters
    public String componentExternalId;
    public String clusterId;
    public String device;
    public String componentId;

    //Base atributes
    public Set<String> defaultComponentFieldSet;
    public Set<String> componentFieldSet;
    public String customPermissionEdit;
    public String customPermissionView;

    //Component Wrapper
    public ComponentWrapper cw;

    //WRAPPERS
    public class ComponentWrapper{
		@auraEnabled public AcceleratorSettings__c acceleratorSettings;
        @auraEnabled public String clusterId;
        @auraEnabled public PermissionsWrapper permissions;
        @auraEnabled public MetaWrapper meta;
        @auraEnabled public DataWrapper data;
	}

    public class PermissionsWrapper{
        @auraEnabled public Boolean isEnabledEditFrame; 
		@auraEnabled public Boolean isEnabledViewFrame;
    }

    public virtual class MetaWrapper{
        @auraEnabled public Component__c component;
        @auraEnabled public String objectId;
        @auraEnabled public String name;
    }
    
    public virtual class DataWrapper{}

    //Get general component wrapper
    public ComponentWrapper getCW(){
        cw = new ComponentWrapper();
        //Looking for default cluster
        if(clusterId == null || clusterId.trim() == ''){
            clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
        }

        cw.acceleratorSettings = AcceleratorSettings__c.getInstance();
        cw.clusterId = clusterId;
        cw.permissions = getPermissionWrapper();
        cw.meta = getMeta();
        cw.data = getData();

        return cw;
    }

    public virtual PermissionsWrapper getPermissionWrapper() {
        PermissionsWrapper pw = new PermissionsWrapper();
        pw.isEnabledEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
        pw.isEnabledViewFrame = FeatureManagement.checkPermission('CommunityViewFrame');
        
		if(!pw.isEnabledEditFrame){
			pw.isEnabledEditFrame = FeatureManagement.checkPermission(customPermissionEdit.deleteWhitespace());
		}

		if (!pw.isEnabledViewFrame){
			pw.isEnabledViewFrame = FeatureManagement.checkPermission(customPermissionView.deleteWhitespace());
		}

        return pw; 
    }

    public virtual MetaWrapper getMeta() {
        MetaWrapper mw = new MetaWrapper();
        //Default fields
        defaultComponentFieldSet = new Set<String>();
        defaultComponentFieldSet.add('Id');
        defaultComponentFieldSet.add('Name');
        defaultComponentFieldSet.add('Recordtype.DeveloperName');        
        defaultComponentFieldSet.add('Recordtype.Id');
        defaultComponentFieldSet.add('Datasource__c');
        defaultComponentFieldSet.add('OrderBy__c');        
        defaultComponentFieldSet.add('OrderByAdvance__c');
        defaultComponentFieldSet.add('HierarchicalOrderBy__c');
        defaultComponentFieldSet.add('TagCriteria__c');
        defaultComponentFieldSet.add('PageSize__c');
        defaultComponentFieldSet.addAll(componentFieldSet);
        mw.component = ComponentUtils.getComponent(componentExternalId, defaultComponentFieldSet, device);

        return mw;
    }

    public virtual DataWrapper getData() {
        DataWrapper cw = new DataWrapper();
        return cw;
    }

}