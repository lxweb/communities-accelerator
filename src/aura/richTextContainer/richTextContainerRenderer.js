({
	afterRender: function(component){
		this.superAfterRender();
       	var body = component.get('v.contentBody');
        component.find('customRich').setText(body);
	}
})