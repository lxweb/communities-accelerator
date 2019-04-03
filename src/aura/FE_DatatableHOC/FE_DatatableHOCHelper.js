({
    getRecord : function(component, event, helper) {
        var action = component.get("c.doInit");

        component.set("v.isLoading", true);
        var clusterCookie = helper.getCookie("CG_clusterId");
        var device = $A.get("$Browser.formFactor");

        action.setParams({externalId: component.get("v.componentExternalId")
                            , clusterId: clusterCookie
                            , device: device
                        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());

                component.set('v.componentWrapper', result);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    doGetPage : function(component, event, helper, actualPage) {
        var action = component.get("c.getPage");
        
        var componentWrapperData = component.get("v.componentWrapper.data");
        componentWrapperData.tableData = [];

        action.setParams({componentWrapper: JSON.stringify(componentWrapperData)
                            , actualPage: actualPage});

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);

            var state = response.getState();

            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                if(result.length > 0) {
                    var componentWrapper = component.get('v.componentWrapper');
                    componentWrapper.data.tableData = result;
                    component.set('v.componentWrapper', componentWrapper);
                }
            }
        });
        $A.enqueueAction(action);
        component.set('v.isLoading', true);
    },
    doHandleSort : function(component, event, helper, fieldName, direction) {
        var action = component.get("c.handleSort");

        var componentWrapperData = component.get("v.componentWrapper.data");
        componentWrapperData.tableData = [];

        action.setParams({componentWrapper: JSON.stringify(componentWrapperData)
                            , fieldName: fieldName
                            , direction: direction
                        });

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);

            var state = response.getState();

            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                if(result.length > 0) {
                    var componentWrapper = component.get('v.componentWrapper');
                    componentWrapper.data.tableData = result;
                    component.set('v.componentWrapper', componentWrapper);
                }
            }
        });
        $A.enqueueAction(action);
        component.set('v.isLoading', true);
    },
    dohandleFilter : function(component) {
        var action = component.get("c.handleFilter");

        var componentWrapperData = component.get("v.componentWrapper.data");
        componentWrapperData.tableData = [];

        action.setParams({ componentWrapper: (JSON.stringify(componentWrapperData)) });

        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                
                var componentWrapper = component.get('v.componentWrapper');
                componentWrapper.data.tableData = result;
                component.set('v.componentWrapper', componentWrapper);
            }
        });
        $A.enqueueAction(action);
        component.set('v.isLoading', true);
    },
    doHandleDelete : function(component, event, helper) {
        var action = component.get("c.getPage");

        action.setParams({componentWrapper: component.get("v.componentWrapper")
                            , actualPage: event.getParam('actualPage')});

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                
                var componentWrapper = component.get('v.componentWrapper');
                componentWrapper.data.tableData = result;
                component.set('v.componentWrapper', componentWrapper);
                
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
        component.set('v.isLoading', true);
    },
    doHandleSearch : function(component, event, helper) {
        var action = component.get("c.getPage");

        action.setParams({componentWrapper: component.get("v.componentWrapper")
                            , actualPage: event.getParam('actualPage')});

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                
                var componentWrapper = component.get('v.componentWrapper');
                componentWrapper.data.tableData = result;
                component.set('v.componentWrapper', componentWrapper);
                
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
        component.set('v.isLoading', true);
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