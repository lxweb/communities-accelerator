({
    doInit: function (component, event, helper) {
        helper.getCluster(component, helper);
    },
    
    doOnclick: function (component, event, helper) {
        var clusterId = event.currentTarget.getAttribute('data-clusterId');
        var clusterLandingId = event.currentTarget.getAttribute('data-clusterLanding');
        var clustertype = event.currentTarget.getAttribute('data-clustertype');
        var isBackend = component.get("v.isBackend");
        helper.getOnclick(component, helper, clusterId, clusterLandingId, clustertype);
        if(!isBackend){           	
            window.location.reload();
        }
    }
    
})