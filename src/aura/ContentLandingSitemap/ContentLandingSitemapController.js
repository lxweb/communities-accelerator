({
	onSearchChange : function(component, event, helper){
		console.log("[ContentLandingSitemapHelper.js][setFilteredSitemap] searchStr: " + component.get("v.searchStr"));
		helper.setFilteredSitemap(component, component.get("v.searchStr"));
	},
	onClusterChange : function(component, event, helper){
		helper.getSiteId(component);
	}
})