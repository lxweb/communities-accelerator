({
	onInit : function(component, event, helper) {
		helper.getSitemap(component);
		helper.getOrgId(component);
		helper.getClusterLeafs(component);
		//component.set("v.url", "https://cg-ca-dev-dt-dev-ed.preview.salesforce-communities.com/?orgId=00D1U000000tUY7&siteId=0DM1U000000Puum&language=en_US");
	}
})