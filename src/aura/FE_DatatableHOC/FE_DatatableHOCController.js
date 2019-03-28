({
    getRecord : function(component, event, helper) {
        helper.getRecord(component, event, helper);
    },
    doGetPage : function(component, event, helper) {
        helper.doGetPage(component, event, helper);
    },
    doHandleSearch : function(component, event, helper) {
        helper.doHandleSearch(component, event, helper);
    },
    doHandleDelete : function(component, event, helper) {
        helper.doHandleDelete(component, event, helper);
    },
    doHandleSort : function(component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var direction = event.getParam('direction');
        helper.doHandleSort(component, event, helper, fieldName, direction);
    },
    doHandleFilter : function(component, event, helper) {
        var value1 = event.getParam('value1');
        var value1 = event.getParam('value2');
        var isRange = event.getParam('isRange');
        var fieldName = event.getParam('fieldName');

        helper.doHandleFilter(component, event, helper, fieldName, value1, value2, isRange);
    },

    doGetPageMock : function(component, event, helper) {
        helper.doGetPage(component, event, helper, 1);
    },
    doHandleSortMock : function(component, event, helper) {
        helper.doHandleSort(component, event, helper, 'Name', 'ASC');
    },
    doHandleFilterMock : function(component, event, helper) {
        var componentWrapper = component.get("v.componentWrapper");
        
        var filters = [];
        var filter = {filter: {
                            name: 'Name'
                            , type: 'STRING'
                        }
                        ,value1: 'DUMMY_Event'};
        filters.push(filter);

        componentWrapper.data.appliedFilters  = filters;

        component.set('v.componentWrapper', componentWrapper);

        helper.doHandleFilter(component, event, helper);
    },
    doHandleClearFilters : function(component, event, helper) {
        var componentWrapper = component.get("v.componentWrapper");
        
        var filters = [];
        componentWrapper.data.appliedFilters  = filters;

        component.set('v.componentWrapper', componentWrapper);

        helper.doHandleFilter(component, event, helper);
    },
    doHandleFilter : function(component, event, helper){
        var componentWrapper = component.get("v.componentWrapper");
        var eventValues = JSON.parse(event.getParam("values"));
        var filters = [];
        var filter = {filter: {
                            name: eventValues.name, 
                            type: eventValues.type
                        },
                        value1: eventValues.value};

        filters.push(filter);
        componentWrapper.data.appliedFilters  = filters;
        component.set('v.componentWrapper', componentWrapper);
        helper.dohandleFilter(component);
    }

})