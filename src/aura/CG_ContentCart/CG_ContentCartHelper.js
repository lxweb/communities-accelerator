({
	initData : function(component, event, helper) {
		helper.loadMore(component,helper);
	},
	//LOAD ITEMS
	loadMore : function(component, helper) {
		var elementPerPage = component.get("v.elementPerPage");
		var action = component.get("c.initData");
		action.setParams({
			stringOffset: component.get("v.offset").toString(),
			stringElementPerPage: elementPerPage.toString()
		});
		action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
				if(component.get("v.contentCartWrapper") != null){
		        	var contentList = component.get("v.contentCartWrapper.cartItemList");
	            	var returnList = action.getReturnValue().cartItemList;
	            	returnList.forEach(function(ACC) {
						contentList.push(ACC);
					});
					component.set("v.contentCartWrapper.cartItemList", contentList);
					var contentMap = component.get("v.contentCartWrapper.cartItemMap");
	            	var returnMap = action.getReturnValue().cartItemMap;

	            	Object.keys(returnMap).forEach(function(key) {
    					contentMap[key] = returnMap[key];
					});

					component.set("v.contentCartWrapper.cartItemMap", contentMap);
	        	}else {
	        		component.set("v.contentCartWrapper", action.getReturnValue());
	        	}
				component.set("v.offset", component.get("v.offset")+elementPerPage);
				component.set('v.scrollCalled', false);
	        }
	    });
	    $A.enqueueAction(action);
	},

	//DELETE SELECTED ITEM
	deleteSelectedItem: function(component, event, helper) {
		var idSelected = event.getSource().get("v.name");
		var isDeteleAll = false;
		
		helper.doDeleteAction(component, event, helper, idSelected, isDeteleAll);
	},
	//DELETE ALL
	deleteAllItems : function(component, event, helper) {
		var idSelected = "";
		var isDeteleAll = true;

		helper.doDeleteAction(component, event, helper, idSelected, isDeteleAll);
	},
	// DELETE ACTION
	doDeleteAction : function(component, event, helper, itemToDelete, isDeleteAll){
		
		var action = component.get("c.deleteCartItems");
		action.setParams({
			contentCartId: itemToDelete,
			data: JSON.stringify(component.get("v.contentCartWrapper")),
			isDeleteAll: isDeleteAll
		});

		action.setCallback(this, function(f){
			if(f.getState() === "SUCCESS"){
				component.set("v.contentCartWrapper", action.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},
	downloadAllItems : function(component, event, helper) { 

		var action = component.get("c.downloadAllItems");
		action.setParams({
			data: JSON.stringify(component.get("v.contentCartWrapper"))
		});
		action.setCallback(this, function(f){
			if(f.getState() === "SUCCESS") {
				var returnMap = f.getReturnValue();
				var myzip = new JSZip();
			    Object.keys(returnMap).forEach(function(key) {
	   				myzip.file(key, returnMap[key], {base64: true});
				});
				helper.generateZIP(myzip);

				var itemList = component.get("v.contentCartWrapper.cartItemList");

			}
		});
				// TODO JUNTO   AGREGAR EN LA DOCUMENTACIÓN LOS REMOTE SITES PARA DESCARGAR LINKS

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

	}

})