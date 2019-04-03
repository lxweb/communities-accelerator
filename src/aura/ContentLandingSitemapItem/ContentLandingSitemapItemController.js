({
	onSectionToggle : function(component, event, helper) {
		component.set("v.isOpen", !component.get("v.isOpen"));
	},
	onMenuClick : function(component, event, helper) {
		component.set("v.navigation", component.get("v.menu").menu.Navigation__r.URL__c);
		if(component.get("v.navigation") == "/s/"){
			component.set("v.url", component.get("v.homeUrl"));
		} else {
			component.set("v.url", component.get("v.homeUrl") + component.get("v.navigation"));
		}
	},
	onNavClick : function(component, event, helper) {
		component.set("v.navigation", component.get("v.navObj").URL__c);
		if(component.get("v.navigation") == "/s/"){
			component.set("v.url", component.get("v.homeUrl"));
		} else {
			component.set("v.url", component.get("v.homeUrl") + component.get("v.navigation"));
		}
	}
})