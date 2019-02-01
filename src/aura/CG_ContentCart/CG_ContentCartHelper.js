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

		var myzip = new JSZip(); 
		var contentList = component.get("v.contentCartWrapper.cartItemList");
		for ( var ii = 0; ii < contentList.length; ii++ ) {
			var cw=contentList[ii];		
			if(cw.contentDocumentId === ""){
				var action = component.get("c.imageToBase64");
			    action.setParams({
			        urlImg: cw.fileDownloadLink
			    });
			    action.setCallback(this, function(f){
			    	if(f.getState() === "SUCCESS") {
			            var url = f.getReturnValue();
			            console.log(url);
			            //myzip.file(cw.name+".jpg", url, {base64: true});
			            //SE COMENTA PORQUE DESCARGA SIEMPRE CON EL ÚLTIMO NOMBRE DE LA LISTA
			            myzip.file("External Link.jpg", url, {base64: true});
				    }
				    helper.generateZIP(myzip);
			    });
				// EL LUNES PROBAR DESCARGANDO IMAGENES DE SALESFORCE COMO SI FUERAN LINKS EXTERNOS
				// UTILIZANDO LOS LINKS DEL PREVIWE, PASAR AL CONTROLADOR UNA LISTA PARA QUE PROCESE 
				// TODO JUNTO   
			}//else {
				//myzip.file(cw.name, cw.fileDownloadLink, {blob: true});
			//}
		}

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