({
	doInit : function (component, event, helper) {
		helper.doInit(component, event, helper);        
    },
    instagramTabAction : function(component, event, helper) {
        var tab1 = component.find('instagram');
        var TabOnedata = component.find('tab-scoped-1');
 		var liTab1 = component.find('liTab1');

        var tab2 = component.find('twitter');
        var TabTwoData = component.find('tab-scoped-2');
        var liTab2 = component.find('liTab2');

 	    //show and Active first tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(liTab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');        
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(liTab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');        
    },
    twitterTabAction : function(component, event, helper) {
        var tab1 = component.find('twitter');
        var TabOnedata = component.find('tab-scoped-2');
        var liTab1 = component.find('liTab2');

        var tab2 = component.find('instagram');
        var TabTwoData = component.find('tab-scoped-1');
        var liTab2 = component.find('liTab1');
 
 	    //show and Active first tab
        $A.util.addClass(tab1, 'slds-active');
        $A.util.addClass(liTab1, 'slds-active');
        $A.util.addClass(TabOnedata, 'slds-show');
        $A.util.removeClass(TabOnedata, 'slds-hide');
        // Hide and deactivate others tab
        $A.util.removeClass(tab2, 'slds-active');
        $A.util.removeClass(liTab2, 'slds-active');
        $A.util.removeClass(TabTwoData, 'slds-show');
        $A.util.addClass(TabTwoData, 'slds-hide');        
    }
})