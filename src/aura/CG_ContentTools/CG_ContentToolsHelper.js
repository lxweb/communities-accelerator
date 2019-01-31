({
	doInit : function(component, event, helper) {
		var contentIdVar = component.get("v.contentId");
		if(contentIdVar != null){
			var action = component.get("c.initData");
			action.setParams({
				contentId: contentIdVar
			});

		    action.setCallback(this, function(f) {
	            if(f.getState() === "SUCCESS") {
	            	component.set("v.contentWrapper", action.getReturnValue());
		        }
		    });
		    
		    $A.enqueueAction(action);			
		}
	},
	shareTo : function(component, socialNetwork) {
		var dirUrl = component.get("v.contentWrapper.urlPreview");
		var typeDialog;

		if (socialNetwork == 'Facebook'){
			dirUrl = 'https://www.facebook.com/sharer/sharer.php?u=' + dirUrl;
			typeDialog = 'facebook-share-dialog';
		} else if (socialNetwork == 'Twitter'){
			dirUrl = 'https://twitter.com/intent/tweet?url=' + dirUrl;
			typeDialog = 'twitter-share-dialog'
		} else if (socialNetwork == 'Google'){
			dirUrl = 'https://plus.google.com/share?url=' + dirUrl;
			typeDialog = 'google-share-dialog';
		} else if (socialNetwork == 'Pinterest'){
			dirUrl = 'https://www.pinterest.com/pin/create/button/?url=' + dirUrl;
			typeDialog = 'pinterest-share-dialog';	
		}
		window.open(dirUrl, typeDialog, 'width=626,height=436');
	},
	addToCart : function(component, event, helper) {
		
		var action = component.get("c.addToCarts");
		action.setParams({
			data: JSON.stringify(component.get("v.contentWrapper"))
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set("v.contentWrapper", action.getReturnValue());
            	var showToast = $A.get('e.force:showToast');
                showToast.setParams({
                    'title'   : 'Success',
                    'message' : $A.get("$Label.c.ItemWasAdded"),
                    'type'    : 'success'
                });
                showToast.fire();
              
	        }else if (f.getState() === "ERROR") {
	        	var errors = f.getError();
	        	if(errors && errors[0] && errors[0].message){
            		var showToast = $A.get('e.force:showToast');
                	showToast.setParams({
                    	'title'   : 'Error',
                    	'message' : errors[0].message,
                    	'type'    : 'Error'
                	});
                	showToast.fire();
                } 
	        }
	    });
		$A.enqueueAction(action);
    },
    

    download : function(component, helper){
    	if(component.get("v.contentWrapper.urlPreview") === component.get("v.contentWrapper.urlDownload")){
    		helper.saveAs(component);
		}else{
			window.open(component.get("v.contentWrapper.urlDownload"));
		}
	},

	saveAs : function(component){
		var action = component.get("c.imageToBase64");
	    action.setParams({
	        urlImg: component.get("v.contentWrapper.urlDownload")
	    });
	    action.setCallback(this, function(f){
	    	if(f.getState() === "SUCCESS") {
	            var url = f.getReturnValue();
	            var link = document.createElement('a');               
	            link.href = url;                
	            link.download = component.get("v.contentWrapper.name");
	            document.body.appendChild(link);
	            link.click();
	            document.body.removeChild(link);
	        }
	    });
		$A.enqueueAction(action);
	}

})
