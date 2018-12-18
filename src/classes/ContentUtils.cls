public without sharing virtual class ContentUtils {

	public class ContentWrapper{
        public set<String> setAllContentIds;
        public Integer totalPages;
        public List<ContentDataWrapper> contentDataPage;
    }
    
    public class ContentDataWrapper{
        public Content__c content;
        public List<MediaElement__c> mediaElements;
    }

    public static ContentWrapper getContentFromComponent(Component__c component, set<String> fieldSet, set<String> setContentDirect, set<String> setContentToExclude, set<String> setClusterIds, String device){
        system.debug('ContentUtils: component: ' + component);
        system.debug('ContentUtils: fieldSet: ' + fieldSet);
        system.debug('ContentUtils: setContentDirect: ' + setContentDirect);
        system.debug('ContentUtils: setContentToExclude: ' + setContentToExclude);
        system.debug('ContentUtils: setClusterIds: ' + setClusterIds);
        system.debug('ContentUtils: device: ' + device);

        set<Id> setContentIds = new set<Id>();
        set<Id> setCategoriesIds = new set<Id>();

        if(setContentToExclude == null){setContentToExclude = new set<String>();}

        //Armado del query principal a objeto Content
        String query = '';

        //SELECT
        query += 'SELECT ' + GeneralUtils.joinFields(fieldSet) + ', (SELECT Id, MediaElement__c FROM MediaElementAssignments__r) ';

        //FROM
        query += 'FROM Content__c ';

        //WHERE
        String contentTypeToSearch = getRecordTypeContentFromRTComponent(component.RecordType.DeveloperName);

        if(setContentDirect != null){
            //Busqueda de contenido por parametro
            query += 'WHERE (Id IN: setContentDirect OR ExternalId__c IN: setContentDirect) AND Recordtype.DeveloperName =: contentTypeToSearch ';
        }else{
            if(component.Datasource__c != null){
                //Busqueda de contenido por Datasource
                if(component.Datasource__c.contains('ParentContent')){
                    if(!setContentToExclude.isEmpty()){
                        Content__c parentContent = [SELECT Id, Category__c FROM Content__c WHERE (Id IN: setContentToExclude OR ExternalId__c IN: setContentToExclude) LIMIT 1];
                        if(component.Datasource__c.contains('Categories') && parentContent.Category__c != null){
                            setCategoriesIds.add(parentContent.Category__c);
                        }
                        if(component.Datasource__c.contains('Tags')){
                            setContentIds.addAll(getContentIdsByTags(parentContent.Id, contentTypeToSearch));
                        }
                    }
                }else{
                    if(component.Datasource__c.contains('ManualAssignment')){
                        setContentIds.addAll(getContentIdsByAssignment(component.Id));
                    }
                    if(component.Datasource__c.contains('Categories')){
                        setCategoriesIds.addAll(getContentIdsByCategories(component.Id));
                    }
                    if(component.Datasource__c.contains('Tags')){
                        setContentIds.addAll(getContentIdsByTags(component.Id, contentTypeToSearch));
                    }
                }
            }

            if(component.Datasource__c != null && (component.Datasource__c == 'All News' || component.Datasource__c == 'All Events') ){
                query += 'WHERE Id NOT IN: setContentToExclude AND ExternalId__c NOT IN: setContentToExclude AND Cluster__c IN: setClusterIds AND Recordtype.DeveloperName =: contentTypeToSearch ';
            }else{
                query += 'WHERE (Id IN: setContentIds OR Category__c IN: setCategoriesIds) AND (Id NOT IN: setContentToExclude) AND (ExternalId__c NOT IN: setContentToExclude) AND Cluster__c IN: setClusterIds AND Recordtype.DeveloperName =: contentTypeToSearch ';
            }

            if(component.Recordtype.Developername == 'Event' || component.Recordtype.DeveloperName == 'RelatedEvent'){
                if (component.ExcludePastEvents__c){
                    Datetime dateAndTime = System.today();
                    query += 'AND (EventEndDate__c >: dateAndTime) ';
                }
            }
        }

        //ORDER
        if((component.OrderBy__c != null && component.OrderBy__c != 'Custom Sorting') || (component.OrderBy__c != null && component.OrderBy__c == 'Custom Sorting' && component.OrderByAdvance__c != null) ){
            query += 'ORDER BY ' + (component.OrderBy__c == 'Custom Sorting' ? component.OrderByAdvance__c : component.OrderBy__c);
        }
        query = query.replace('ORDER BY', 'ORDER BY Cluster__r.ClusterLevel__c ASC, ');
        
        ContentWrapper cw = new ContentWrapper();
        map<Id, Content__c> mapContent = new map<Id, Content__c>((List<Content__c>)Database.query(query));
        
        if(!mapContent.isEmpty()){
        	//TODO: Aca tenemos que aplicar segmentacion y se tiene que cambiar como manejamos las paginas y el total de las paginas
            
            //Si despues de aplicar segmentacion tenemos algun registro evaluamos las paginas
            if(!mapContent.isEmpty()){

                //Seteo todos los Ids posibles para despues hacer el query de paginas
                cw.setAllContentIds = (Set<String>)JSON.deserialize(JSON.serialize(mapContent.keySet()), Set<String>.class);

                //Calculo el total de paginas
                cw.totalPages = component.PageSize__c != null ? Integer.valueOf((mapContent.size() / component.PageSize__c).round(RoundingMode.UP)) : 1;
	            //Content Data Wrapper
	            List<Content__c> firstPage = new List<Content__c>();
	            if(component.PageSize__c == null){
	            	firstPage = mapContent.values();
	            }else{
                    Decimal limitSize = component.PageSize__c < mapContent.values().size() ? component.PageSize__c : mapContent.values().size();
	            	for(Integer i = 0; i < limitSize; i++){
	            		firstPage.add(mapContent.values()[i]);
		            }
	            }
                //Translate content records
                TranslationUtils.getTranslated(firstPage, UserInfo.getLanguage(), 'Content__c');

                //Replace User information on Advance Content
                if(component.Recordtype.DeveloperName == 'AdvanceContent'){
                    replaceDynamicFieldsOnContent(firstPage);
                }

	            cw.contentDataPage = createContentDataWrappers(firstPage);
            }
        }

        return cw;
    }

    public static List<ContentDataWrapper> getContentPage(set<String> setAllContentIds, set<String> fieldSet, Integer page, Integer pageSize, String orderBy, String device){
        String query = '';
        query += 'SELECT ' + GeneralUtils.joinFields(fieldSet) + ', (SELECT Id, MediaElement__c FROM MediaElementAssignments__r) ';
        query += 'FROM Content__c ';
        query += 'WHERE Id IN: setAllContentIds ';
        query += 'ORDER BY ' + orderBy + ' ';
        query = query.replace('ORDER BY', 'ORDER BY Cluster__r.ClusterLevel__c ASC, ');
        query += 'LIMIT ' + pageSize + ' ';

        Decimal offSet = (page-1) * pageSize;

        query += 'OFFSET ' + offSet;
        
        List<Content__c> listContentPage = Database.query(query);

        //Translate content records
        TranslationUtils.getTranslated(listContentPage, UserInfo.getLanguage(), 'Content__c');

        List<ContentDataWrapper> contentDataPage = createContentDataWrappers(listContentPage);
        return contentDataPage;
    }
    
    private static set<Id> getContentIdsByAssignment(Id componentId){
        set<Id> setContentIds = new set<Id>();
        for(ContentAssignment__c ca: [SELECT Id, Content__c FROM ContentAssignment__c WHERE Component__c =: componentId]){
            setContentIds.add(ca.Content__c);
        }
        return setContentIds;
    }

    private static set<Id> getContentIdsByCategories(Id parentId){
        set<Id> setCategoriesIds = new set<Id>();
        for(CategoryAssignment__c ca: [SELECT Id, Category__c FROM CategoryAssignment__c WHERE Component__c =: parentId]){
            setCategoriesIds.add(ca.Category__c);
        }
        return setCategoriesIds;
    }

    private static set<Id> getContentIdsByTags(Id parentId, String contentTypeToSearch){
        set<Id> setTagIds = new set<Id>();
        for(TagAssignment__c ta: [SELECT Id, Tag__c FROM TagAssignment__c WHERE Component__c =: parentId OR Content__c =: parentId]){
            setTagIds.add(ta.Tag__c);
        }

        set<Id> setContentIds = new set<Id>();
        for(TagAssignment__c ta: [SELECT Id, Content__c FROM TagAssignment__c WHERE Tag__c IN: setTagIds AND Content__r.RecordType.Developername =: contentTypeToSearch]){
            setContentIds.add(ta.Content__c);
        }

        return setContentIds;
    }

    private static List<ContentDataWrapper> createContentDataWrappers(List<Content__c> contents){
        List<ContentDataWrapper> listCDW = new List<ContentDataWrapper>();

        set<Id> setMediaElementIds = new set<Id>();
        for(Content__c c: contents){
            for(MediaElementAssignment__c m: c.MediaElementAssignments__r){
                setMediaElementIds.add(m.MediaElement__c);
            }
        }

        map<Id, MediaElement__c> mapMediaElements;
        if(!setMediaElementIds.isEmpty()){
            mapMediaElements = new map<Id, MediaElement__c>([SELECT Id, Name, FileURLDesktop__c FROM MediaElement__c WHERE Id IN: setMediaElementIds]);
        }

        for(Content__c c: contents){
            ContentDataWrapper cdw = new ContentDataWrapper();
            cdw.content = c;
            cdw.mediaElements = new List<MediaElement__c>();
            for(MediaElementAssignment__c m: c.MediaElementAssignments__r){
                if(mapMediaElements != null && mapMediaElements.containsKey(m.MediaElement__c)){
                    cdw.mediaElements.add(mapMediaElements.get(m.MediaElement__c));
                }
            }
            listCDW.add(cdw);
        }

        return listCDW;
    }

    private static String getRecordTypeContentFromRTComponent(String componentRT){
        String contentTypeToSearch;
        if (componentRT == 'RelatedNews' || componentRT == 'NewsDetail') {
            contentTypeToSearch = 'News';
        }else if (componentRT == 'RelatedEvents' || componentRT == 'EventDetail') {
            contentTypeToSearch = 'Event';
        }else{
            contentTypeToSearch = componentRT;
        }
        return contentTypeToSearch;
    }

    private static void replaceDynamicFieldsOnContent(List<Content__c> contentList){
        for(Content__c con: contentList){
            con.HTMLContent__c = GeneralUtils.replaceDynamicFields(con.HTMLContent__c, 'User', UserInfo.getUserId(), false);
        }
    }
    
}