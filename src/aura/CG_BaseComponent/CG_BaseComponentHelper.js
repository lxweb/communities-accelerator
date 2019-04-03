({
	getComponentWrapper : function(component, helper) {
		var cw = component.get("v.componentWrapper");
		var componentType = component.get("v.componentType");
		var componentExternalId = component.get("v.componentExternalId");
        var device = $A.get("$Browser.formFactor");
        var parentComponentId = helper.getUrlParameter('parentComponentId');
        parentComponentId = parentComponentId === undefined ? '' : parentComponentId;

        var parentContentId = '';
        var newsId = helper.getUrlParameter('newsId');
        var eventId = helper.getUrlParameter('eventId');
        if( !(newsId === undefined) ){parentContentId = newsId;}
        if( !(eventId === undefined) ){parentContentId = eventId;}

        component.set("v.parentComponentId", parentComponentId);
       	component.set("v.parentContentId", parentContentId);

		if(cw == null){
	        component.set("v.isLoading", true);

	        if(component.get("v.isLivePreview")){
	    		component.set("v.showComponentEmpty", true);
	    	}

	    	var clusterCookie = helper.getCookie("CG_clusterId");

	        if( !(componentExternalId === '') && !(componentType === '') ){
				var action = component.get("c.getComponentWrapper");
				action.setParams({
					componentExternalId: componentExternalId,
		            componentType: componentType,
		            parentComponentId: parentComponentId,
		            parentContentId: parentContentId,
		            clusterId: clusterCookie,
					device: device
				});

			    action.setCallback(this, function(f) {
		            if(f.getState() === "SUCCESS") {
						var cWrapper = action.getReturnValue();
						//mobile cast
	                    if($A.get("$Browser.isPhone")){
							var recordType = cWrapper.component.RecordType.DeveloperName;
							if(recordType === 'EventDetail' || recordType === 'NewsDetail'){
		                        var details = {};
		                        details.type = recordType === 'EventDetail' ? 'Event' : 'News';
								if(cWrapper.contentWrapper.length > 0){
			                        var content = cWrapper.contentWrapper[0].content;
			                        details.date = content.EventStartDate__c;
									details.location = {};
			                        details.location.name = content.Location__c;
			                        details.location.href = 'https://www.google.com/maps/place/' + content.Location__c;
			                        details.title = content.Title__c;
			                        details.imgSrc = cWrapper.contentWrapper[0].mediaElements[0].FileURLDesktop__c;
			                        details.body = content.Body__c;
								}
								cWrapper.details = details;
							}
	                    }
	               		//end mobile cast
		            	component.set("v.componentWrapper", cWrapper);
		                
		                if( !(cWrapper.component == null) ){
		                	component.set("v.showComponentEmpty", false);
		                }

		                if(clusterCookie == undefined || clusterCookie == ''){
		                	helper.setCookie('CG_clusterId', cWrapper.clusterId, 100);
		                }
		                
		                //Loading
		                component.set("v.isLoading", false);
			        }
			    });
			    $A.enqueueAction(action);
		    }
	    }else{
	    	component.set("v.isLoading", false);
	    }
	},
	goPage : function(component, pageNumber){
		var quantPages = component.get("v.componentWrapper.pagesNumbers")[component.get("v.componentWrapper.pagesNumbers").length-1];
        if(quantPages >= pageNumber && pageNumber > 0 && component.get('v.currentPageNumber') != pageNumber){
			component.set("v.isLoading", true);

			var componentWrapper = component.get("v.componentWrapper");
			var device = $A.get("$Browser.formFactor");
			var orderBy = componentWrapper.component.OrderBy__c == 'Custom Sorting' ? componentWrapper.component.OrderByAdvance__c : componentWrapper.component.OrderBy__c;

			var action = component.get("c.getPage");
			action.setParams({
				listAllContentIds: componentWrapper.listAllContentIds,
				componentType: componentWrapper.component.RecordType.DeveloperName,
				pageSize: String(componentWrapper.component.PageSize__c),
				pageNumber: String(pageNumber),
				orderBy: orderBy,
				device: device
			});

		    action.setCallback(this, function(f) {
				if(f.getState() === "SUCCESS") {
					component.set("v.componentWrapper.contentWrapper", action.getReturnValue());
	            	component.set('v.currentPageNumber', pageNumber);
	                component.set("v.isLoading", false);
		        }
		    });
		    $A.enqueueAction(action);
		}
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
    getCookie : function(cname){
    	var name = cname + "=";
	    var decodedCookie = decodeURIComponent(document.cookie);
	    var ca = decodedCookie.split(';');
	    for(var i = 0; i <ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
    },
    setCookie : function(cname, cvalue, exdays) {
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+ d.toUTCString();
	    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	}
})