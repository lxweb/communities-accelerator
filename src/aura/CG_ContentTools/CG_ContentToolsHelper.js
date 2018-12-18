({
	doInit : function(component, event, helper) {
		
		var action = component.get("c.initData");
		action.setParams({
			imageUrl: component.get("v.imageUrl"),
			assetId: component.get("v.assetId")
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.imagesWrapper", action.getReturnValue());
	        }
	    });
	    
	    $A.enqueueAction(action);
	},
	shareTo : function(component, socialNetwork) {
		var dirUrl;
		var typeDialog;

		if (socialNetwork == 'Facebook'){
			dirUrl = 'https://www.facebook.com/sharer/sharer.php?u=' + component.get("v.imagesWrapper.url");
			typeDialog = 'facebook-share-dialog';
		} else if (socialNetwork == 'Twitter'){
			dirUrl = 'https://twitter.com/intent/tweet?url=' + component.get("v.imagesWrapper.url");
			typeDialog = 'twitter-share-dialog'
		} else if (socialNetwork == 'Google'){
			dirUrl = 'https://plus.google.com/share?url=' + component.get("v.imagesWrapper.url");
			typeDialog = 'google-share-dialog';
		} else if (socialNetwork == 'Pinterest'){
			dirUrl = 'https://www.pinterest.com/pin/create/button/?url=' + component.get("v.imagesWrapper.url");
			typeDialog = 'pinterest-share-dialog';	
		}
		window.open(dirUrl, typeDialog, 'width=626,height=436');
	},
	shareToFacebook : function(component) {		
		var dirUrl = 'https://www.facebook.com/sharer/sharer.php?u=' + component.get("v.imagesWrapper.url");
		window.open(dirUrl, 'facebook-share-dialog', 'width=626,height=436');
	},

	shareToTwitter : function(component) {
		var dirUrl = 'https://twitter.com/intent/tweet?url=' + component.get("v.imagesWrapper.url");
		//&text=
		window.open(dirUrl, 'twitter-share-dialog', 'width=626,height=436');
	},

	shareToGoogle : function(component) {
		var dirUrl = 'https://plus.google.com/share?url=' + component.get("v.imagesWrapper.url");
		window.open(dirUrl, 'google-share-dialog', 'width=626,height=436');
	},
	shareToPinterest : function(component) {
		var dirUrl = 'https://www.pinterest.com/pin/create/button/?url=' + component.get("v.imagesWrapper.url");
		window.open(dirUrl, 'pinterest-share-dialog', 'width=626,height=436');	
	},
	addToCart : function(component, event, helper) {
		
		var action = component.get("c.addToCarts");
		action.setParams({
			data: JSON.stringify(component.get("v.imagesWrapper"))
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.imagesWrapper", action.getReturnValue());
            	var showToast = $A.get('e.force:showToast');
                showToast.setParams({
                    'title'   : 'Success',
                    'message' : 'Your item was added Successfully!',
                    'type'    : 'success'
                });
                showToast.fire();
	        }
	    });
		$A.enqueueAction(action);
    }
})