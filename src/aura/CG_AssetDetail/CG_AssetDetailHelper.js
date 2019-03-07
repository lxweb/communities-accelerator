({
	getAssetDetail : function(component,helper) {
        
        var asset = helper.getUrlParameter('asset');
        component.set("v.contentId", asset);
		var action = component.get("c.getRecord");
        action.setParams({
            contentId: component.get("v.contentId"),
            externalId: component.get("v.componentExternalId")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.contentWrapper", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},

    getAddToCart: function(component){
        var action = component.get("c.addToCart");
        action.setParams({
            contentId: component.get("v.contentId")
        });
        
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.contentWrapper.disableAdd", true);
                var showToast = $A.get('e.force:showToast');
                showToast.setParams({
                    'title'   : 'Success',
                    'message' : 'Your item was added Successfully!',
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

     // the function that reads the url parameters
    getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), sParameterName, i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },

    downloadAllItems : function(component, event, helper) { 

        var action = component.get("c.downloadAllItems");
        action.setParams({
            data: JSON.stringify(component.get("v.contentWrapper"))
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                var returnMap = f.getReturnValue();
                var myzip = new JSZip();
                Object.keys(returnMap).forEach(function(key) {
                    myzip.file(key, returnMap[key], {base64: true});
                });
                helper.generateZIP(myzip);

                //var itemList = component.get("v.contentCartWrapper.cartItemList");

            }
        });

        $A.enqueueAction(action);
        
    },

    generateZIP : function(myzip){
        myzip.generateAsync({type:"base64"}).then(function(base64){

            var url = "data:application/zip;base64," + base64;
            var link = document.createElement('a');               
            link.href = url;                
            link.download = "contetCart.zip";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);

        }) 

    },
      
})