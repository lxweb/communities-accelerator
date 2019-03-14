({
	setFilteredSitemap : function(component, searchedStr) {
		var sitemapBackupString = JSON.stringify(component.get("v.sitemapBackup"));
		var sitemapBackup = JSON.parse(sitemapBackupString);
		if(searchedStr != null && searchedStr != ''){
			for(var i=0; i < sitemapBackup.length; i++){
				i += this.updateMenuWrapper(sitemapBackup[i], sitemapBackup, i, searchedStr);
			}
		} 
		
		let sitemap = [...sitemapBackup];
		component.set("v.sitemap", sitemap);
	},
	updateMenuWrapper : function(menuWrapper, array, index, searchedStr){
		var returnValue;
		if(menuWrapper.childsMenu && menuWrapper.childsMenu.length > 0){
			for(var i=0; i < menuWrapper.childsMenu.length; i++){
				i += this.updateMenuWrapper(menuWrapper.childsMenu[i], menuWrapper.childsMenu, i, searchedStr);
			}
			if(menuWrapper.childsMenu.length == 0 && !menuWrapper.menu.Name.toUpperCase().includes(searchedStr.toUpperCase())){
				array.splice(index, 1);
				returnValue = -1
			} else {
				returnValue = 0;
			}
		} else if(!menuWrapper.menu.Name.toUpperCase().includes(searchedStr.toUpperCase())){
			array.splice(index, 1);
			returnValue = -1;
		} else {
			returnValue = 0;
		}
		
		return returnValue;
	},
	getSiteId : function(component) {
		var action = component.get('c.getSiteId');
		action.setParams({
			clusterId : component.get("v.clusterId")
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var oldSite = component.get("v.siteId");
				var newSite = response.getReturnValue()
				component.set('v.siteId', newSite);

				var hostname = window.location.hostname;
				var arr = hostname.split(".");
				var instance = arr[0];
				if(oldSite != newSite){
					component.set("v.url", "http://" + instance + ".preview.salesforce-communities.com/?orgId=" + 
								component.get("v.orgId") + "&siteId=" + newSite + "&language=en_US");
				}
				console.log(component.get("v.url"));
			}
		});
		$A.enqueueAction(action);
	}
})