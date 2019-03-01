({
  

    handleImageClicked: function(component, event) {
      	component.find('mediaElement').initPopUp();

    },


    handleSaveEvent : function(component, event) {
        var message = event.getParam('messageTest');
        alert(message);
    },

    handleURLEvent : function(component, event) {
        var URL = event.getParam("URL");
        var ID = event.getParam("ID"); 
		component.find('customRich').handleReceiveUrl(URL);
        event.stopPropagation();
    },

  handleTextChange : function(component, event) {
      var body = event.getParam('contentBody');
      component.set('v.contentBody',body);
    },

	
         

});