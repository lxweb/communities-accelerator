({
	setFilteredSitemap : function(component, searchedStr) {
		var sitemapBackupString = JSON.stringify(component.get("v.sitemapBackup"));
		var sitemapBackup = JSON.parse(sitemapBackupString).menus;
		var navigationBackup = JSON.parse(sitemapBackupString).navigations;
		if(searchedStr != null && searchedStr != ''){
			for(var i=0; i < sitemapBackup.length; i++){
				i += this.updateMenuWrapper(sitemapBackup[i], sitemapBackup, i, searchedStr);
			}
			for(var i=0; i < navigationBackup.length; i++){
				if(!navigationBackup[i].Name.toUpperCase().includes(searchedStr.toUpperCase())){
					navigationBackup.splice(i, 1);
					i--;
				}
			}
		}
		
		let sitemap = [...sitemapBackup];
		let navigation = [...navigationBackup];
		component.set("v.sitemap", sitemap);
		component.set("v.otherNavigations", navigation);
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
		console.log(component.get("v.url"));
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

				var instance = component.get("v.instance");
				if(oldSite != newSite){
					component.set("v.isLogin", true);
					component.set("v.url", "https://" + instance + ".preview.salesforce-communities.com/?orgId=" + 
								component.get("v.orgId") + "&siteId=" + newSite + "&language=en_US");
					component.set("v.isLoading", true);
				}
				console.log(component.get("v.url"));
			}
		});
		$A.enqueueAction(action);
	}
})