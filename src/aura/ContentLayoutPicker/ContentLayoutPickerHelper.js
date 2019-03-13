({
	setSelectedLayout : function(component, value) {
		var content = component.set('v.selectedValue', value);
		this.setSelectedLayoutStyle(value);

	},

	setSelectedLayoutStyle : function(value){
		var layouts = document.getElementsByClassName('selectedLayout');
		for(var i = 0 ; i < layouts.length ; i++){
			layouts[i].classList.remove('selectedLayout');
		}
		document.getElementById(value).classList.add('selectedLayout');
	}
})