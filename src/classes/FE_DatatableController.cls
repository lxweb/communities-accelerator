public class FE_DatatableController extends FE_ComponentManager {

    public Datatable__c datatable {get;set;}
    public List<DatatableElement__c> datatableElements {get;set;}
    public List<DatatableAction__c> datatableActions {get;set;}

    /* Aura Methods - BEGIN */
    @AuraEnabled
    public static String doInit(String externalId) {
        FE_DatatableController controller = new FE_DatatableController();
        controller.componentExternalId = externalId;
        controller.componentFieldSet = new Set<String>();
        controller.customPermissionEdit='Datatable Edit Frame';
        controller.customPermissionView='Datatable View Frame';
        controller.defaultComponentFieldSet = new Set<String>();
        return JSON.serialize(controller.getCW());
    }

    @AuraEnabled
    public static String getPage(String componentWrapper, Integer actualPage) {
        System.debug('in FE_DatatableController.getPage() method. componentWrapper: ');
        System.debug(componentWrapper);

        FE_DatatableController.DatatableWrapper wrapper = (FE_DatatableController.DatatableWrapper)JSON.deserialize(componentWrapper, FE_DatatableController.DatatableWrapper.class);
        Datatable__c datatable = getDatatableInfo(wrapper.componentExternalId);

        System.debug('wrapper: ' + wrapper + ' - actualPage: ' + actualPage);

        Integer offSet = wrapper.recordsPerPage * actualPage;

        System.debug('offSet: ' + offSet);

        List<SObject> records = doGetRecords(datatable, offSet, wrapper);

        System.debug('records: ' + records);

        return JSON.serialize(mapDatatableDataToWrappers(records, wrapper.columns));
    }

    @AuraEnabled
    public static String handleDelete(String componentWrapper, List<Id> ids) {
        System.debug('in FE_DatatableController.handleDelete() method.');
        Boolean result = true;

        if(result) {
            FE_DatatableController.DatatableWrapper wrapper = (FE_DatatableController.DatatableWrapper)JSON.deserialize(componentWrapper, FE_DatatableController.DatatableWrapper.class);

        }
        return '';
    }

    @AuraEnabled
    public static String handleSort(String componentWrapper, String fieldName, String direction) {
        System.debug('in FE_DatatableController.handleSort() method.');

        FE_DatatableController.DatatableWrapper wrapper = (FE_DatatableController.DatatableWrapper)JSON.deserialize(componentWrapper, FE_DatatableController.DatatableWrapper.class);
        wrapper.orderBy = fieldName + ' ' + direction;

        Datatable__c datatable = getDatatableInfo(wrapper.componentExternalId);
        datatable.OrderBy__c = wrapper.orderBy;

        System.debug('datatable.OrderBy__c: ' + datatable.OrderBy__c);

        List<SObject> records = doGetRecords(datatable, 0, wrapper);
        return JSON.serialize(mapDatatableDataToWrappers(records, wrapper.columns));
    }

    @AuraEnabled
    public static String handleFilter(String componentWrapper) {
        System.debug('in FE_DatatableController.handleFilter() method. ');

        FE_DatatableController.DatatableWrapper wrapper = (FE_DatatableController.DatatableWrapper)JSON.deserialize(componentWrapper, FE_DatatableController.DatatableWrapper.class);
        
        Datatable__c datatable = getDatatableInfo(wrapper.componentExternalId);
        List<SObject> records = doGetRecords(datatable, 0, wrapper);

        return JSON.serialize(mapDatatableDataToWrappers(records, wrapper.columns));
    }
    /* Aura Methods - END */

     public override MetaWrapper getMeta() {
         MetaWrapper mw = new MetaWrapper();
         List<DataTable__c> dt = [SELECT Id,Name FROM DataTable__c WHERE ExternalId__c=: this.componentExternalId];
         if (dt[0] != null){
            mw.objectId = dt[0].Id;
            mw.name = dt[0].Name;
         }
  
         return mw;
     }

    public override DataWrapper getData() {
        System.debug('in FE_DatatableController.getData() - externalId: ' + this.componentExternalId);

        Datatable__c datatable = getDatatableInfo(this.componentExternalId);

        if(datatable != null) {
            
            System.debug('datatable: ' + datatable);
            DatatableWrapper datatableWrapper = mapDatatableToWrapper(datatable);
            datatableWrapper.componentExternalId = this.componentExternalId;

            datatableWrapper.columns = mapDatatableElementsToWrappers(datatable.DatatableElements__r);

            datatableWrapper.actions = mapDatatableActionsToWrappers(datatable.DatatableActions__r);
            
            List<SObject> records = doGetRecords(datatable, 0, datatableWrapper);

            datatableWrapper.tableData = mapDatatableDataToWrappers(records, datatableWrapper.columns);

            return datatableWrapper;
        }else {
            return null;
        }
    }

    /**
     * Methods that retrieves the Datatable__c object information, and its childs relationships (Elements & Actions)
     * @input componentExternalId
     * @return Datatable__c
     **/
    public static Datatable__c getDatatableInfo(String componentExternalId) {
        List<Datatable__c> datatables = [SELECT Id 
                                        , Title__c
                                        , Navigation__c
                                        , ObjectApiName__c
                                        , RecordsPerPage__c 
                                        , PagingType__c
                                        , NumberOfColumns__c
                                        , NoRecordsMessage__c
                                        , ActionLabel__c
                                        , WhereCondition__c
                                        , OrderBy__c
                                        , (SELECT Id, Label__c, Navigation__c, ColumnInformation__c, ColumnInformationIcon__c
                                                    , DisplaySettings__c, FieldApiName__c, Filtrable__c, Searchable__c, Sortable__c
                                                    , Type__c, Datatable__r.ObjectApiName__c, ExcludedPicklistValues__c
                                            FROM DatatableElements__r ORDER BY Order__c)
                                        , (SELECT Id, Label__c, DisplaySettings__c, Icon__c, SelectableRow__c
                                                , Type__c, RecordType.DeveloperName, Component__c
                                            FROM DatatableActions__r)
                                    FROM Datatable__c 
                                    WHERE ExternalId__c = : componentExternalId
                                    LIMIT 1];

        if(datatables.size() > 0) {
            return datatables.get(0);
        }else {
            return null;
        }
    }

    public static FE_DatatableController.DatatableWrapper mapDatatableToWrapper(Datatable__c datatable) {
        DatatableWrapper datatableWrapper = new DatatableWrapper();
        datatableWrapper.Id = datatable.Id;
        datatableWrapper.title = datatable.Title__c;
        datatableWrapper.objectApiName = datatable.ObjectApiName__c;
        datatableWrapper.navigation = datatable.Navigation__c;
        datatableWrapper.recordsPerPage = Integer.valueOf(datatable.RecordsPerPage__c);
        datatableWrapper.pagingType = datatable.PagingType__c;
        datatableWrapper.numberOfColumns = Integer.valueOf(datatable.NumberOfColumns__c);
        datatableWrapper.noRecordsMsg = datatable.NoRecordsMessage__c;
        datatableWrapper.actionLabel = datatable.ActionLabel__c;
        datatableWrapper.orderBy = datatable.OrderBy__c;

        return datatableWrapper;
    }

    public static List<SObject> doGetRecords(Datatable__c datatable, Integer offSet, FE_DatatableController.DatatableWrapper wrapper){
        List<SObject> rows = new List<SObject>();
        List<String> fieldSet = new List<String>();

        for(DatatableElement__c elem : datatable.DatatableElements__r) {
            fieldSet.add(elem.FieldApiName__c);
        }

        String fieldSetString = String.join(fieldSet, ', ');

        String fromPart = ' FROM ' + datatable.ObjectApiName__c;

        String filtersWhereCondition = processAppliedFilters(wrapper.appliedFilters);

        String whereCondition = '';

        if(String.isNotEmpty(datatable.WhereCondition__c) && String.isNotEmpty(filtersWhereCondition)) {
            whereCondition = datatable.WhereCondition__c + ' AND ' + filtersWhereCondition;
        }else if(String.isEmpty(whereCondition) && String.isNotEmpty(filtersWhereCondition)) {
            whereCondition = ' WHERE ' + filtersWhereCondition;
        }else if(String.isNotEmpty(datatable.WhereCondition__c)) {
            whereCondition = datatable.WhereCondition__c;
        }
        
        String query = 'SELECT count() ' + fromPart + ' ' + whereCondition;
        System.debug('query: ' + query);

        Integer totalRows = Database.countQuery(query);

        if(totalRows > 0) {
            wrapper.totalRows = totalRows;

            query = 'SELECT ' + fieldSetString + ' ' + fromPart + ' ' + whereCondition;

            if(String.isNotEmpty(datatable.OrderBy__c)) {
                System.debug('datatable.orderBy: ' + datatable.OrderBy__c);
                query += ' ORDER BY ' + datatable.OrderBy__c;
            }

            query += ' LIMIT ' + datatable.RecordsPerPage__c + ' OFFSET ' + offset;
            
            System.debug('query: ' + query);

            rows = Database.query(query);
        }

        return rows;
    }

    public static List<Map<String, String>> mapDatatableDataToWrappers(List<SObject> records, List<FE_DatatableController.DatatableElementWrapper> datatableElements) {
        List<Map<String, String>> datatableData = new List<Map<String, String>>();
        
        for(SObject record : records) {
            Map<String, String> structure = new Map<String, String>();

            for(FE_DatatableController.DatatableElementWrapper de : datatableElements) {
                String fieldApiName = de.fieldName;

                structure.put(fieldApiName, (String)record.get(fieldApiName));
            }

            datatableData.add(structure);
        }

        return datatableData;
    }

    public static List<FE_DatatableController.DatatableElementWrapper> mapDatatableElementsToWrappers(List<DatatableElement__c> elements) {
        List<FE_DatatableController.DatatableElementWrapper> result = new List<FE_DatatableController.DatatableElementWrapper>();

        for(DatatableElement__c ele : elements) {
            FE_DatatableController.DatatableElementWrapper elem = new FE_DatatableController.DatatableElementWrapper();

            elem.label = ele.Label__c;
            elem.fieldName = ele.FieldApiName__c;
            elem.type = ele.Type__c;
            elem.columnInformation = ele.ColumnInformation__c;
            elem.displaySettings = ele.DisplaySettings__c;
            elem.searchable = ele.Searchable__c;
            elem.sortable = ele.Sortable__c;
            elem.filtrable = ele.Filtrable__c;
            elem.navigation = ele.Navigation__c;

            if(ele.Type__c == String.valueOf(Schema.DisplayType.PICKLIST)) {
                elem.filtrableValues = new List<String>();

                String objectName = ele.Datatable__r.ObjectApiName__c;

                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                List<Schema.PicklistEntry> values = fieldMap.get(ele.FieldApiName__c).getDescribe().getPickListValues();
                for( Schema.PicklistEntry pickListVal : values) {
                    Boolean excluded = false;

                    if(String.isNotEmpty(ele.ExcludedPicklistValues__c) && ele.ExcludedPicklistValues__c.contains(pickListVal.getValue()) ) {
                        excluded = true;
                    }

                    if(!excluded) {
                        elem.filtrableValues.add(pickListVal.getValue());
                    }
                }
            }

            result.add(elem);
        }

        return result;
    }

    public static List<FE_DatatableController.DatatableActionWrapper> mapDatatableActionsToWrappers(List<DatatableAction__c> actions) {
        List<FE_DatatableController.DatatableActionWrapper> result = new List<FE_DatatableController.DatatableActionWrapper>();

        for(DatatableAction__c action : actions) {
            FE_DatatableController.DatatableActionWrapper ac = new FE_DatatableController.DatatableActionWrapper();
        
            ac.recordType = action.RecordType.DeveloperName;
            ac.component = action.Component__c;
            ac.selectableRows = action.SelectableRow__c;
            ac.label = action.Label__c;
            ac.icon = action.Icon__c;
            ac.displaySettings = action.DisplaySettings__c;

            result.add(ac);
        }

        return result;
    }

    public static String processAppliedFilters(List<FE_DatatableController.DatatableFilterWrapper> appliedFilters) {
        System.debug('in FE_DatatableController.processAppliedFilters() method.');
        String result = '';

        for(FE_DatatableController.DatatableFilterWrapper appliedFilter : appliedFilters) {

            if(appliedFilter.filter.type == String.valueOf(Schema.DisplayType.STRING) || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.PICKLIST)) {
                result += appliedFilter.filter.name + ' = \'' + String.escapeSingleQuotes(appliedFilter.value1) + '\' ';
            }else if(appliedFilter.filter.type == String.valueOf(Schema.DisplayType.DATE)) {
                if(String.isNotEmpty(appliedFilter.value1) && String.isNotEmpty(appliedFilter.value2)) {
                    result += appliedFilter.filter.name + ' BETWEEN \'' + String.escapeSingleQuotes(appliedFilter.value1) + '\' AND \'' + String.escapeSingleQuotes(appliedFilter.value2) + '\'';
                }else if(String.isNotEmpty(appliedFilter.value1)) {
                    result += appliedFilter.filter.name + ' >= \'' + String.escapeSingleQuotes(appliedFilter.value1) + '\'';
                }else if(String.isNotEmpty(appliedFilter.value2)) {
                    result += appliedFilter.filter.name + ' <= \'' + String.escapeSingleQuotes(appliedFilter.value2) + '\'';
                }
            }else if(appliedFilter.filter.type == String.valueOf(Schema.DisplayType.INTEGER) || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.LONG) 
                    || appliedFilter.filter.type == String.valueOf(Schema.DisplayType.DOUBLE)) {
                if(String.isNotEmpty(appliedFilter.value1) && String.isNotEmpty(appliedFilter.value2)) {
                    result += appliedFilter.filter.name + ' >= ' + appliedFilter.value1 + ' AND ' + appliedFilter.filter.name + ' <= ' + appliedFilter.value2;
                }else if(String.isNotEmpty(appliedFilter.value1)) {
                    result += appliedFilter.filter.name + ' >= ' + appliedFilter.value1;
                }else if(String.isNotEmpty(appliedFilter.value2)) {
                    result += appliedFilter.filter.name + ' <= ' + appliedFilter.value2;
                }
            }
        }

        System.debug('applied filters result: ' + result);

        return result;
    }


    public class DatatableWrapper extends FE_ComponentManager.DataWrapper {
        public String componentExternalId {get;set;}
        public String id {get;set;}
        public String name {get;set;}
        public String objectApiName {get;set;}
        public String title {get;set;}
        public String navigation {get;set;}
        public Integer recordsPerPage {get;set;}
        public String pagingType {get;set;}
        public Integer totalRows {get;set;}
        public Integer numberOfColumns {get;set;}
        public String noRecordsMsg {get;set;}
        public String actionLabel {get;set;}
        public String orderBy {get;set;}

        public List<DatatableFilterWrapper> appliedFilters {get;set;}
        public List<FE_DatatableController.DatatableElementWrapper> columns {get;set;}
        public List<FE_DatatableController.DatatableActionWrapper> actions {get;set;}        
        public List<Map<String, String>> tableData {get;set;}

        public DatatableWrapper() {
            appliedFilters = new List<DatatableFilterWrapper>();
        }
    }

    public class DatatableElementWrapper {
        public String label {get;set;}
        public String fieldName {get;set;}
        public String type {get;set;}

        public String navigation {get;set;}
        public String columnInformation {get;set;}
        public String columnInformationIcon {get;set;}
        public String displaySettings {get;set;}
        
        public Boolean searchable {get;set;}
        public Boolean sortable {get;set;}
        public Boolean filtrable {get;set;}
        public List<String> filtrableValues {get;set;}
    }

    public class DatatableActionWrapper {
        public String navigation {get;set;}
        public String recordType {get;set;}
        public String component {get;set;}
        public Boolean selectableRows {get;set;}
        public String label {get;set;}
        public String icon {get;set;}
        public String displaySettings {get;set;}
    }

    public class DatatableFilterWrapper {
        public FE_DatatableController.DatatableFilterFieldWrapper filter {get;set;}
        public String value1 {get;set;}
        public String value2 {get;set;}
    }

    public class DatatableFilterFieldWrapper {
        public String name {get;set;}
        public String type {get;set;}
    }

    public class DatatableRowWrapper {
        public String columnName {get;set;}
        public String rowValue {get;set;}
    }
}