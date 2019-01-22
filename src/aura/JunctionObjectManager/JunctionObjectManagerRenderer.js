({
	afterRender: function (component, helper) {
		//Extend the default afterRender method
		var afterRend = this.superAfterRender();
		/*helper.addListeners(component);
		
		alert(document.getElementsByClassName("dropZone").length);
		component.set('v.dragCallback', $A.getCallback( function() {
			for(var i = 0; i < document.getElementsByClassName("dropZone").length; i++){
			    document.getElementsByClassName("dropZone")[i].addEventListener("dropinit", function(e) {
				    this.style.backgroundColor = "red";
				    alert('doble g');
				}, false);
				document.getElementsByClassName("dropZone")[i].addEventListener("dragend", function(e) {
				    this.style.backgroundColor = "";
				}, false);
			}
		}));
		*/
		return afterRend;
	}
})