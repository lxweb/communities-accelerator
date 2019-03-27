public with sharing class FE_AdvanceContentController extends FE_ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device){
        FE_AdvanceContentController ctrl = new FE_AdvanceContentController();
        ctrl.customPermissionEdit = 'AdvanceContent Edit Frame';
        ctrl.customPermissionView = 'AdvanceContent View Frame';
        ctrl.componentFieldSet = new Set<String>();        
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;

        return ctrl.getCW();
    }

    public override DataWrapper getData() {
        
        Set<String> contentSetFields = new Set<String>{
            'HTMLContent__c'
        };
        
        return FE_ContentManager.getCMSContent(clusterId, cw.meta.component, contentSetFields, device);
    }

}