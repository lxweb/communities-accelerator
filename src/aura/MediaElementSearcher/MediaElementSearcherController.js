({
	initSearch : function(component, event, helper){
        component.set("v.searchValue", '');
        component.find("searchField").getElement().value = '';
        component.set("v.offset", '0');
        component.set("v.mediaElementList", '');
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
        helper.searchByText(component, event, helper);
    },
    closeNewModal : function(component, event, helper){
        helper.closeModal(component,event,helper);
    },
	searchByText : function(component, event, helper){ 
		helper.searchByText(component, event, helper);
	},

    selectMediaElement : function(component, event, helper) {
        var mElementUrl = event.target.getAttribute('src');
        var mElementId = event.target.getAttribute('id');
        helper.closeModal(component, event, helper);
    }
})