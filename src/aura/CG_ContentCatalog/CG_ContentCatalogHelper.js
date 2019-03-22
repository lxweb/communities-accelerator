({
	/* *************************************** */
    /* PUBLIC METHODS */
    /* *************************************** */
    initialization : function(component, event, helper) {
		var componentExternalId = component.get("v.componentUniqueName");

		if(componentExternalId){
	        var asset = helper.getUrlParameter('asset');
	        var search = helper.getUrlParameter('search');
	        var brand = helper.getUrlParameter('brand');
	        var tag = helper.getUrlParameter('tag');
	        var category = helper.getUrlParameter('category');

            if(brand){component.set("v.selectedBrands", new Array(brand));}
            if(tag){component.set("v.selectedTags", new Array(tag));}
            if(category){component.set("v.selectedCategories", new Array(category));}
            helper.getInitContent(component, event, helper, asset, search, brand, tag, category);
	    }
	},	

    getNextPage : function (component, event, helper){
        //Infinite Scroll
        var allContentIdsFiltered = component.get("v.allContentIdsFiltered");
        var allContentIdsShown = component.get("v.allContentIdsShown");

        if(allContentIdsFiltered.length > allContentIdsShown.length){

            var restOfContent = allContentIdsFiltered.length - allContentIdsShown.length;
            var pageSize = component.get("v.catalogWrapper.component.PageSize__c");
            var qContentToGet = restOfContent > pageSize ? pageSize : restOfContent;

            var qShown = allContentIdsShown.length;
            var allContentIdsFiltered_page = new Array();
            for(var i=0; i < qContentToGet; i++){
                allContentIdsFiltered_page.push(allContentIdsFiltered[qShown+i]);
            }

            //Query content
            var action = component.get("c.getNextContent");
            action.setParams({
                contentIds: allContentIdsFiltered_page,
                orderBy: component.get("v.orderBy")
            });

            action.setCallback(this, function(f) {
                if(f.getState() === "SUCCESS") {
                    //Agregos los nuevos al wrapper de datos
                    var catalogWrapperContent = component.get("v.catalogWrapper.contentWrapper");
                    Array.prototype.push.apply(catalogWrapperContent, action.getReturnValue());
                    component.set("v.catalogWrapper.contentWrapper", catalogWrapperContent);

                    //Agrego los nuevos a la lista de mostrados
                    action.getReturnValue().forEach(function(element) {
                        allContentIdsShown.push(element.content.Id);
                    });
                }
                component.set("v.loadingScroll", false);
                component.set("v.scrollPlace", "0");
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.loadingScroll", false);
            component.set("v.scrollPlace", "0");
        }
    },

    orderBy : function (component, event, helper){
        //Change Order By
        var value = event.getSource().get("v.value");
        component.set("v.orderBy", value);
        helper.refreshFilters(component, event, helper);
    },

    viewList : function (component, event, helper){
        //Change layout to List
        component.set("v.layout", "List");
    },

    viewCards : function (component, event, helper){
        //Change layout to Cards
        component.set("v.layout", "Cards");
    },

    search : function (component, event, helper){
    	//search
        var searchWord = component.find("input_search").getElement().value;

        component.set("v.searchWord", searchWord);
        helper.refreshFilters(component, event, helper);
    },

    selectFilter : function (component, event, helper){
    	//Select filter
        var value = event.getSource().get("v.name");
        var type = value.split('-')[0];
        var option = value.split('-')[1];

        if(type == 'brand'){
        	var selectedBrands = component.get("v.selectedBrands");
        	var listItems = component.get("v.catalogWrapper.brands");

        	selectedBrands.push(option);
        	listItems.splice(listItems.indexOf(option), 1 );

        	component.set("v.selectedBrands", selectedBrands);
        	component.set("v.catalogWrapper.brands", listItems);
        }
        if(type == 'tag'){
        	var selectedTags = component.get("v.selectedTags");
        	var listItems = component.get("v.catalogWrapper.tags");

        	selectedTags.push(option);
        	listItems.splice(listItems.indexOf(option), 1 );

        	component.set("v.selectedTags", selectedTags);
        	component.set("v.catalogWrapper.tags", listItems);
        }
        if(type == 'category'){
        	var selectedCategories = component.get("v.selectedCategories");
        	var listItems = component.get("v.catalogWrapper.categories");

        	selectedCategories.push(option);
        	listItems.splice(listItems.indexOf(option), 1 );
        	
        	component.set("v.selectedCategories", selectedCategories);
        	component.set("v.catalogWrapper.categories", listItems);
        }

        component.set("v.showClearFilters", true);
        helper.refreshFilters(component, event, helper);
    },

    removeFilter : function (component, event, helper){
    	//Remove filter
        var value = event.getSource().get("v.name");
        var type = value.split('-')[0];
        var option = value.split('-')[1];

        if(type == 'search'){
        	component.set("v.searchWord", "");
        }

        if(type == 'brand'){
        	var selectedBrands = component.get("v.selectedBrands");
        	var listItems = component.get("v.catalogWrapper.brands");

        	listItems.push(option);
        	selectedBrands.splice(selectedBrands.indexOf(option), 1 );

        	component.set("v.selectedBrands", selectedBrands);
        	component.set("v.catalogWrapper.brands", listItems);
        }
        if(type == 'tag'){
        	var selectedTags = component.get("v.selectedTags");
        	var listItems = component.get("v.catalogWrapper.tags");

        	listItems.push(option);
        	selectedTags.splice(selectedTags.indexOf(option), 1 );

        	component.set("v.selectedTags", selectedTags);
        	component.set("v.catalogWrapper.tags", listItems);
        }
        if(type == 'category'){
        	var selectedCategories = component.get("v.selectedCategories");
        	var listItems = component.get("v.catalogWrapper.categories");

        	listItems.push(option);
        	selectedCategories.splice(selectedCategories.indexOf(option), 1 );

        	component.set("v.selectedCategories", selectedCategories);
        	component.set("v.catalogWrapper.categories", listItems);
        }
        helper.refreshFilters(component, event, helper);
    },

    removeAllFilters : function (component, event, helper){
    	//Remove all filters
        var asset = helper.getUrlParameter('asset');
        var brand = helper.getUrlParameter('brand');
        helper.getInitContent(component, event, helper, asset, '', brand, '', '');
    },

    /* *************************************** */
    /* UTILITY METHODS */
    /* *************************************** */
    getInitContent : function(component, event, helper, asset, search, brand, tag, category){
        component.set("v.searchWord", search);
        component.set("v.selectedBrands", new Array());
        component.set("v.selectedTags", new Array());
        component.set("v.selectedCategories", new Array());
        component.set("v.showClearFilters", false);

        var allContentIdsFiltered = new Array();
        var allContentIdsShown = new Array();

        var action = component.get("c.getCatalogWrapper");
        action.setParams({
            componentExternalId: component.get("v.componentUniqueName"),
            asset: asset,
            search: search,
            brand: brand,
            tag: tag,
            category: category,
            orderBy: component.get("v.orderBy")
        });

        action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
                var cWrapper = action.getReturnValue();
                component.set("v.catalogWrapper", cWrapper);

                //Set all contents filtered
                cWrapper.allContentSearchWrapper.forEach(function(element) {
                    allContentIdsFiltered.push(element.contentId);
                });
                component.set("v.allContentIdsFiltered", allContentIdsFiltered);

                //Set all contents shown
                cWrapper.contentWrapper.forEach(function(element) {
                    allContentIdsShown.push(element.content.Id);
                });
                component.set("v.allContentIdsShown", allContentIdsShown);
                
                //Loading
                component.set("v.loadingScroll", false);
                component.set("v.scrollPlace", "0");
            }
        });

        $A.enqueueAction(action);
    },

    getContent : function(component, event, helper){
        //Refresh de "allContentIdsFiltered" and initialize the paginator
        var allContentIdsFiltered = new Array();
        var allContentIdsShown = new Array();

        var searchWord = component.get("v.searchWord");
        var selectedBrands = component.get("v.selectedBrands");
        var selectedTags = component.get("v.selectedTags");
        var selectedCategories = component.get("v.selectedCategories");
        
        //Search on content search wrapper
        var allContentSearchWrapper = component.get("v.catalogWrapper.allContentSearchWrapper")
        allContentSearchWrapper.forEach(function(element) {
            //Agregar filtros
            var added = false;

            if(element.searchWords && searchWord){
                if(element.searchWords.toUpperCase().includes(searchWord.toUpperCase())){
                    allContentIdsFiltered.push(element.contentId);
                    added = true;
                }
            }
            if(!added && element.brand){
                selectedBrands.forEach(function(b) {
                    if(element.brand.toUpperCase().includes(b.toUpperCase())){
                        allContentIdsFiltered.push(element.contentId);
                        return;
                    }
                });
            }
            if(!added && element.tags){
                selectedTags.forEach(function(t) {
                    element.tags.split(';').forEach(function(tag) {
                        if(tag.toUpperCase() == t.toUpperCase()){
                            allContentIdsFiltered.push(element.contentId);
                            return;
                        }
                    });
                });
            }
            if(!added && element.category){
                selectedCategories.forEach(function(c) {
                    if(element.category.toUpperCase().includes(c.toUpperCase())){
                        allContentIdsFiltered.push(element.contentId);
                        return;
                    }
                });
            }
        });

        //Get content ids for the first page
        var allContentIdsFiltered_page = new Array();
        var pageSize = component.get("v.catalogWrapper.component.PageSize__c");
        var totalContentIds = allContentIdsFiltered.length;
        var totalItems = totalContentIds > pageSize ? pageSize : totalContentIds;
        for(var i=0; i <= totalContentIds; i++){
            allContentIdsFiltered_page.push(allContentIdsFiltered[i]);
        }

        //Query content
        var action = component.get("c.getNextContent");
        action.setParams({
            contentIds: allContentIdsFiltered_page,
            orderBy: component.get("v.orderBy")
        });
        action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
                component.set("v.catalogWrapper.contentWrapper", action.getReturnValue());

                //Set all contents shown
                action.getReturnValue().forEach(function(element) {
                    allContentIdsShown.push(element.content.Id);
                });

                component.set("v.allContentIdsShown", allContentIdsShown);
                component.set("v.allContentIdsFiltered", allContentIdsFiltered);

                component.set("v.loadingScroll", false);
                component.set("v.scrollPlace", "0");
            }
        });
        $A.enqueueAction(action);
    },

    refreshFilters : function(component, event, helper) {
    	var searchWord = component.get("v.searchWord");
		var selectedBrands = component.get("v.selectedBrands");
		var selectedTags = component.get("v.selectedTags");
		var selectedCategories = component.get("v.selectedCategories");

    	if( (searchWord != undefined && searchWord != '') || selectedBrands.length > 0 || selectedTags.length > 0 || selectedCategories.length > 0 ){
            helper.getContent(component, event, helper);
    	}else{
    		helper.getInitContent(component, event, helper, '', '', '', '', '');
    	}
    },

    // the function that reads the url parameters
    getUrlParameter : function(sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)), sURLVariables = sPageURL.split('&'), sParameterName, i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    }
})