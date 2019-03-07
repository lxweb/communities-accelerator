({
	doInit : function(component, event, helper) {
		helper.initialization(component, event, helper);
	},
	doGetNextPage : function (component, event, helper){
        //Infinite Scroll
        var scrollPlace = component.get("v.scrollPlace");
        var loadingScroll = component.get("v.loadingScroll");
        if(window.scrollY > scrollPlace && !loadingScroll){
            component.set("v.scrollPlace", window.scrollY);
            if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight) {
                component.set("v.loadingScroll", true);
                helper.getNextPage(component, event, helper);
            }
        }
    },
    doOrderBy : function (component, event, helper){
        //Change Order By
        helper.orderBy(component, event, helper);
    },
    doViewList : function (component, event, helper){
        //Change layout to List
        helper.viewList(component, event, helper);
    },
    doViewCards : function (component, event, helper){
        //Change layout to Cards
        helper.viewCards(component, event, helper);
    },
    doSearch : function (component, event, helper){
        //Click on search
        helper.search(component, event, helper);
    },
    doSelectFilter : function (component, event, helper){
        //Select filter
        helper.selectFilter(component, event, helper);
    },
    doRemoveFilter : function (component, event, helper){
        //Remove filter
        helper.removeFilter(component, event, helper);
    },
    doRemoveAllFilters : function (component, event, helper){
        //Remove all filters
        helper.removeAllFilters(component, event, helper);
    }
})