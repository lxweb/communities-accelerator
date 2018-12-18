({

    getLanguageMenu : function(component, event, helper) {

    	var action = component.get("c.getLanguageMenu");
    	var clusterId = helper.getCookie("CG_clusterId");

        action.setParams({
            clusterId: clusterId
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.MenuWrapper", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);

    },

    setCountryCodeCookie: function(component, event, helper){
    	_cookiesUtil.setCookie('DiageoCookiesCountryCode',component.get("v.currentCountryCode"),365);
	},
    setCountryCodeCookie: function(cookieValue){
    	_cookiesUtil.setCookie('DiageoCookiesCountryCode',cookieValue,365);
	},
	
    closeSelector: function (component, event, helper, arrowicon) {
        arrowicon.getElement().classList.remove("fa-angle-up");
        arrowicon.getElement().classList.add("fa-angle-down");
        component.set('v.renderLangMenu', false);
    },
    openSelector: function (component, event, helper, arrowicon) {
        arrowicon.getElement().classList.remove("fa-angle-down");
        arrowicon.getElement().classList.add("fa-angle-up");
        component.set('v.renderLangMenu', true);
        window.addEventListener('scroll', helper.bindedCloseSelector.bind({arrowicon: arrowicon, component: component}));
    },                                         
    bindedCloseSelector: function () {
        this.arrowicon.getElement().classList.remove("fa-angle-up");
        this.arrowicon.getElement().classList.add("fa-angle-down");
        this.component.set('v.renderLangMenu', false);
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
    }

})