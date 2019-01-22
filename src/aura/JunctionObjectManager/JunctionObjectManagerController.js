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
        var records = component.get("v.recordsWrapper");
        var index1, index2, temp;
        //Se localiza el indice de cada item a reordenar
        for(var i = 0; i < records.recordsSelected.length; i++){
            if(records.recordsSelected[i].idRecord === data) index1 = i; 
            if(records.recordsSelected[i].idRecord === tar.id) index2 = i;
        }
        if(index1 < index2){
            //Se reordenan de abajo hacia arriba
            records.recordsSelected.splice(index2 + 1, 0, records.recordsSelected[index1]);
            records.recordsSelected.splice(index1, 1);
        } else {
            //Se reordenan de arriba hacia abajo
            temp = records.recordsSelected.splice(index1, 1)[0];
            records.recordsSelected.splice(index2, 0, temp);
        }
        for(var i = 0; i < records.recordsSelected.length; i++){
            records.recordsSelected[i].order = i + 1;
        }        
        component.set("v.recordsWrapper", records);
        event.preventDefault();
	}
})