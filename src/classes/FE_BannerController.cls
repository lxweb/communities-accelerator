public with sharing class FE_BannerController extends FE_ComponentManager{
    
    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device,String navigationUrl){
        FE_BannerController ctrl = new FE_BannerController();
        ctrl.customPermissionEdit = 'Banner Edit Frame';
        ctrl.customPermissionView = 'Banner View Frame';
        ctrl.componentFieldSet = new Set<String>{
            'BannerFrameType__c',
            'Orientation__c',
            'BannerType__c',
            'ShowBullets__c',
            'AutomaticTransition__c',
            'BannerTransitionTime__c',
            'Loop__c',
            'Direction__c'
        };
        
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;
        ctrl.navigationUrl = navigationUrl;

        return ctrl.getCW();
    }

    public override DataWrapper getData() {
        
        Set<String> contentSetFields = new Set<String>{
            'Id',
            'Name',
            'LinkDetail__r.URL__c',
            'OverlayQuadrant__c',
            'Title__c',
            'Extract__c',
            'ButtonLabel__c',
            'BannerFrameType__c'
        };
        
        return FE_ContentManager.getCMSContent(clusterId, cw.meta.component, contentSetFields, device);
    }

}