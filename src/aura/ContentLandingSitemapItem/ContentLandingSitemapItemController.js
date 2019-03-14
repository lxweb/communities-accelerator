({
	onSectionToggle : function(component, event, helper) {
		component.set("v.isOpen", !component.get("v.isOpen"));
	},
	onMenuClick : function(component, event, helper) {
		component.set("v.navigation", component.get("v.menu").menu.Navigation__r.URL__c);
	}
})