({
	getSearchResults: function (component, searchedString) {
       
        var action = component.get("c.getSearchResults");
        action.setParams({
            searchedString  : searchedString//,
            //clusterId       : this.getCookie("CG_clusterId");
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
            	var results 	= action.getReturnValue();
                var appEvent 	= $A.get("e.c:SetSearchResults");
		        appEvent.setParams({
		            "results" 		: results,
		            "selectedItem" 	: (results && results.length > 0) ? results[0].sectionApiName : null
		        });
		        appEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    getClusterName: function (component) {
        var clusterId = this.getCookie("CG_clusterId");
        component.set("v.clusterCookie", clusterId);
        var action = component.get("c.getClusterName");
        action.setParams({
            recordId: clusterId
        });        
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.clusterName", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);
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
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }
})