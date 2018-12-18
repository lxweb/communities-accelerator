({
	getCluster: function (component, helper) {
       
        var action = component.get("c.getClusterRootForComponent");
        action.setParams({
            componentId: component.get("v.recordId")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.tree", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getOnclick: function(component, helper, clusterId, clusterLandingId, clustertype){
        
    	if(component.get("v.tree.leafOnly")){
            if(clustertype==="ClusterLeaf"){
                helper.setCookie("CG_clusterId",clusterId,99);
                helper.getRedirect(component, clusterLandingId);
            }
        }else{
            helper.setCookie("CG_clusterId",clusterId,99);
            helper.getRedirect(component, clusterLandingId);
        }   

    },

    getRedirect : function(component, clusterLandingId) {
        var action = component.get("c.getClusterRedirect");
        action.setParams({
            clusterLandingUrl: clusterLandingId
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                var url = action.getReturnValue();
                if(url !=null){
                    /*
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": url
                    });           
                    urlEvent.fire();
                    */
                    window.location.href = url;
                }
            }
        });
        $A.enqueueAction(action);
    },

    setCookie : function(cname, cvalue, exdays) {
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+ d.toUTCString();
	    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	},    
    
    getCookie : function(cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                console.log(c);
                console.log(c.substring(name.length, c.length));
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }
})