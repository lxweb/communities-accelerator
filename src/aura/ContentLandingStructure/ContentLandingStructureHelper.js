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
	getGeneralData : function(component) {
		var action = component.get('c.getGeneralData');
		action.setParams({});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var getGeneralData = response.getReturnValue();
				component.set('v.clusterLeafs', getGeneralData.clusterLeafs);
				component.set('v.orgId', getGeneralData.orgId);
				component.set('v.communityName', getGeneralData.communityName);
			}
		});
		$A.enqueueAction(action);
	},
	setInstance : function(component) {
		var hostname = window.location.hostname;
		var arr = hostname.split(".");
		var instance = arr[0];
		component.set("v.instance", instance);
	}
})