({
    getFilterOptions : function(component, helper){
    	if(component.get("v.objectWrapper")!= null){
    		var objectWrapper = component.get("v.objectWrapper");
    	}
    },
    onRadio: function(component, event) {
		var objectWrapper = component.get('v.objectWrapper');
        var index = event.getSource().get("v.name");
        if(!objectWrapper[index].isMultiPicklist){
            for(var i = 0 ; i< objectWrapper[index].values.length ; i++){
                objectWrapper[index].values[i].isSelected = false;
            }
            component.set('v.objectWrapper', objectWrapper);
            event.getSource().set("v.value", true);
        }
	},
    onCheck: function(component, event) {
		var objectWrapper = component.get('v.objectWrapper');
        var index = event.getSource().get("v.name");
        for(var i = 0 ; i< objectWrapper[index].values.length ; i++){
            objectWrapper[index].values[i].isSelected = false;
        }
        component.set('v.objectWrapper', objectWrapper);
        event.getSource().set("v.value", true);
    },
    setSelectedValue: function(component, apiName, value){
        var objectWrapper = component.get("v.objectWrapper");
        for(var i=0; i<objectWrapper.length; i++){
            if(objectWrapper[i].apiName === apiName){
                var values = objectWrapper[i].values;
                for(var h=0; h<values.length; h++){
                    if(values[h].value === value){
                        values[h].isSelected = true;
                    }
                    if(values[h].value != value && values[h].isSelected === true){
                        values[h].isSelected = false;
                    }
                }
            }
        }
        component.set("v.objectWrapper", objectWrapper);
    }
})