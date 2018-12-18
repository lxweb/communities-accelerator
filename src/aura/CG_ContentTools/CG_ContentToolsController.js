({
	doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);
	},
    shareToFacebook : function (component, event, helper) {
		helper.shareTo(component, 'Facebook');        
    },
	shareToTwitter : function (component, event, helper) {
		helper.shareTo(component, 'Twitter');   
    },
	shareToGoogle : function (component, event, helper) {
		helper.shareTo(component, 'Google');  
    },
	shareToPinterest : function (component, event, helper) {
		helper.shareTo(component, 'Pinterest'); 
    },
    addToCart : function (component, event, helper) {
		helper.addToCart(component, event, helper);        
    }
})