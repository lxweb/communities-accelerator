({
	doInit : function(component, event, helper) {
		helper.getRecords(component, event, helper);
	},
	getMedElems : function(component, event, helper){
		window.scrollTo(0,window.innerHeight+document.body.scrollHeight);
		helper.getMedElemsButton(component, event, helper);
	},
	choseMediaElement : function(component, event, helper){ 
		helper.choseMediaElement(component, event, helper);
	},
	deleteMediaElement : function(component, event, helper){ 
		helper.deleteMediaElement(component, event, helper);
	},
	searchByText : function(component, event, helper){ 
		helper.searchByText(component, event, helper);
	}
})