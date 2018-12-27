({
	doInit : function(component, event, helper) {
		helper.initData(component, event, helper);
	},
	// DELETE SELECTED
	prepareDeleteSelected : function(component, event, helper) {
		helper.deleteSelectedItem(component, event, helper);
	},
	//DELETE ALL
	prepareDeleteAll : function(component, event, helper) {
		helper.deleteAllItems(component, event, helper);
	},
	prepareDownloadAll : function(component, event, helper) {
		helper.downloadAllItems(component, event, helper);
	}
})