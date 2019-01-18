({
	doInit : function(component, event, helper) {
		component.set("v.isEdit", false);
		component.set("v.isReorder", false);
        helper.getRecords(component);
	},
	doSave : function(component, event, helper) {
        helper.save(component, event, helper);
	},
	doSelectAll : function(component, event, helper) {
        helper.selectAll(component, event);
	},
	doEdit : function(component, event, helper) {
        component.set("v.isEdit", true);
		component.set("v.isReorder", false);
	},
	doReorder : function(component, event, helper) {
        component.set("v.isReorder", true);
		component.set("v.isEdit", false);
	},
	doCancel : function(component, event, helper) {
        component.set("v.isEdit", false);
		component.set("v.isReorder", false);
        helper.getRecords(component);
	},
	doSearch : function(component, event, helper) {
        helper.search(component);
	},
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    drag: function (component, event, helper) {
        event.dataTransfer.setData("text", event.target.id);
    },
    drop: function (component, event, helper) {
        var data = event.dataTransfer.getData("text");
        //Se busca el record Id desde el arbol de herencias del DOM
        var tar = event.target.closest('[id]');
        var contactData = component.get("v.recordsWrapper");
        var index1, index2, temp;
        //Se localiza el indice de cada item a reordenar
        for(var i = 0; i < contactData.recordsSelected.length; i++){
            if(contactData.recordsSelected[i].idRecord === data) index1 = i; 
            if(contactData.recordsSelected[i].idRecord === tar.id) index2 = i;
        }
        if(index1 < index2){
            //Se reordenan de abajo hacia arriba
            contactData.recordsSelected.splice(index2 + 1, 0, contactData.recordsSelected[index1]);
            contactData.recordsSelected.splice(index1, 1);
        } else {
            //Se reordenan de arriba hacia abajo
            temp = contactData.recordsSelected.splice(index1, 1)[0];
            contactData.recordsSelected.splice(index2, 0, temp);
        }
        for(var i = 0; i < contactData.recordsSelected.length; i++){
            contactData.recordsSelected[i].order = i + 1;
        }        
        component.set("v.recordsWrapper", contactData);
        event.preventDefault();
	}
})