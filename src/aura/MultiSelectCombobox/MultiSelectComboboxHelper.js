({
    selectOptionHelper : function(component,value,isCheck) {
        var selectedOptions=[];
		var allOptions = component.get('v.options');
        for(var i=0;i<allOptions.length;i++){ 
            if(allOptions[i].value==value) { 
                if(isCheck=='true'){ 
                    allOptions[i].isSelected = false; 
                } else {
                    allOptions[i].isSelected = true;
                }
            }
            if(allOptions[i].isSelected){
                selectedOptions.push(allOptions[i]);
            }
        }
        component.set("v.selectedOptions",selectedOptions);
        component.set('v.options',allOptions);
        this.setValueText(component, selectedOptions.length);
    },
    setValueText : function(component, number){
        var text = '';
        if(number > 1){
            text = this.stringFormat(component.get('v.moreItemsSelectedText'), number);
        } else if(number === 0) {
            text = '';
        } else {
            text = this.stringFormat(component.get('v.oneItemSelectedText'), number);
        }
        component.set("v.value", text);
    },
	stringFormat: function(string) {
	    var outerArguments = arguments;
	    return string.replace(/\{(\d+)\}/g, function() {
	        return outerArguments[parseInt(arguments[1]) + 1];
	    });
	}
})