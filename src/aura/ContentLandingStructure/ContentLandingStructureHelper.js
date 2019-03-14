({
	getSitemap : function(component) {
		var action = component.get('c.getMenus');
		action.setParams({});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var resultStr = JSON.stringify(response.getReturnValue());
				component.set('v.sitemap', JSON.parse(resultStr));
				component.set('v.sitemapBackup', JSON.parse(resultStr));
			}
		});
		$A.enqueueAction(action);
	},
	getOrgId : function(component) {
		var action = component.get('c.getOrgId');
		action.setParams({});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.orgId', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},
	getClusterLeafs : function(component) {
		var action = component.get('c.getClusterLeafs');
		action.setParams({});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.clusterLeafs', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})