({
    doInit: function (component, event, helper) {
        helper.getAssetDetail(component, helper);
    },
    
    doAddToCart : function (component, event, helper) {
    	helper.getAddToCart(component);
    },

    downloadAll : function(component, event, helper) { 
    	helper.downloadAllItems(component, event, helper);
    }
})