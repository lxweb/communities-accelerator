public class ContentLandingRecordListController {
    
	//TODO:CheckList
	// Get Parameters
	// Create Test Class

	public class TableWrapper{
		public String title;
		public List<String> columnSet;
		public List<ContentWrapper> contentWrappers;
		// Wrapper para enviar el título, las columnas y los registros que componen la tabla
		public TableWrapper(String title, List<String> columnSet, List<ContentWrapper> contentWrappers){
			this.title = title;
			this.columnSet = columnSet;
			this.contentWrappers = contentWrappers;
		}	
	}

	class ContentWrapper{
		public List<FieldWrapper> fieldWrappers;
		// Wrapper que emula un Contenido para soportar Wrappers de campo
		ContentWrapper(List<FieldWrapper> fieldWrappers){
			this.fieldWrappers = fieldWrappers;
		}
	}

	class FieldWrapper{
		public String value;
		public String link;
		// Wrapper para incluir el valor de un campo y un link al registro
		FieldWrapper(String value, String link){
			this.value = value;
			this.link = link;
		} 
	}

	class FilterWrapper{
		String contentTypeName;
		String contentTypeId;
		String clusterId;
		String categoryId;
		List<String> tagIds;
		// Wrapper para agrupar los criterios de filtro recibidos
		FilterWrapper(String contentTypeId, String clusterId, String categoryId, List<String> tagIds){
            this.contentTypeName = contentTypeId != null ? [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Content__c' AND Id =: contentTypeId LIMIT 1].Name : 'Recent';
			this.contentTypeId = contentTypeId;
			this.clusterId = clusterId;
			this.categoryId = categoryId;
			this.tagIds = tagIds;
		}
	}

	@auraEnabled(Cacheable = true)
	public static String getTableWrapper(String contentTypeId, String clusterId, String categoryId, List<String> tagIds){
		TableWrapper tableWrapper = buildTableWrapper(contentTypeId, clusterId, categoryId, tagIds);
		// El Wrapper es enviado al componente en forma de JSON
		return JSON.serialize(tableWrapper);
	}

	public static TableWrapper buildTableWrapper(String contentType, String clusterId, String categoryId, List<String> tagIds){
//		FilterWrapper wrapper = mockUpWrapper();
		FilterWrapper wrapper = new FilterWrapper(contentType, clusterId, categoryId, tagIds);
		String title = (wrapper.contentTypeName + ' Records').toUpperCase();
		List<String> columnSet = getColumnSet().split(',');		
		TableWrapper tableWrapper = new TableWrapper(title, columnSet, new List<ContentWrapper>());
		List<Content__c> contents = getRecords(wrapper);
		// Construye los Wrappers auxiliares
		for(Content__c content : contents){
			List<FieldWrapper> fieldWrappers = new List<FieldWrapper>();
			for(String column : columnSet){
				// Verifica si la Columna es un campo relacionado y si esta populado
				String value = getWrapperValue(content, column);
				// La Columna lleva un link al registro de Contenido
				String link = column == 'Name' ? System.URL.getSalesforceBaseURL().toExternalForm()+'/'+content.Id : null;
				// Crea el Wrapper de campo y lo agrega a la lista
				fieldWrappers.add(new FieldWrapper(value, link));
			}
			// Crea el Wrapper de Contenido y lo agrega a la lista
			tableWrapper.contentWrappers.add(new ContentWrapper(fieldWrappers));
		}
		// El Wrapper es enviado al componente en forma de JSON
		return tableWrapper;
	}

	static List<Content__c> getRecords(FilterWrapper wrapper){		
		String queryInString = 'SELECT Id, ' + getColumnSet() + ' FROM Content__c ';
		List<String> queryConditions = getQueryConditions(wrapper);
		// Si no recibe filtros, trae los 10 registros modificados mas recientemente
		if(queryConditions.isEmpty()){
			queryInString = setDefaultCondition(queryInString);
		// Si recibe filtros, construye la query
		} else {
			queryInString = setCustomConditions(queryInString, queryConditions);
		}
		// Devuelve los registros filtrados
		List<Content__c> records = Database.query(queryInString);
		return records;
	}

	static String getColumnSet(){
		// Trae las columnas seteadas en Custom Settings
		AcceleratorSettings__c settings = [SELECT Id, ContentLandingColumnFields__c FROM AcceleratorSettings__c LIMIT 1];
		return settings.ContentLandingColumnFields__c;
	}

	static String getWrapperValue(Content__c content, String column){
		String value;
		// Si la columna es un campo relacionado y esta populado
		if(column.contains('.') && content.getSObject(column.split('\\.')[0]) != null){ 
			value = (String) content.getSObject(column.split('\\.')[0]).get(column.split('\\.')[1]);
		// Si la columna es un campo populado
		} else if(! column.contains('.')){
			value = (String) content.get(column);
		// Si la columna es un campo vacio
		} else {
			value = ' - ';
		}
		return value;
	}

	static List<String> getQueryConditions(FilterWrapper wrapper){
		List<String> queryConditions = new List<String>();
		// Agrega los filtros recibidos a una lista de Query Conditions
		if(wrapper.contentTypeId != null) 	queryConditions.add('RecordTypeId = \'' + wrapper.contentTypeId + '\'');
		if(wrapper.clusterId != null) 		queryConditions.add('Cluster__c = \'' + wrapper.clusterId + '\'');
		if(wrapper.categoryId != null) 		queryConditions.add('Category__c = \'' + wrapper.categoryId + '\'');
		if(wrapper.tagIds != null && ! wrapper.tagIds.isEmpty()){
			// Trae los IDs de los Contenidos asociados a las Tags recibidas
			String tagedContentIds = getTagedContentIds(wrapper.tagIds);
			queryConditions.add('Id IN ' + tagedContentIds);
		}
		return queryConditions;
	}

	static String setDefaultCondition(String queryInString){
		String defaultCondition = 'ORDER BY LastModifiedDate DESC LIMIT 10';
		queryInString += defaultCondition;
		return queryInString;
	}

	static String setCustomConditions(String queryInString, List<String> queryConditions){
		// Agrega las Query Conditions a la query
		queryInString += 'WHERE ';
		for(String queryCondition : queryConditions){
			if(queryConditions.indexOf(queryCondition) < queryConditions.size() -1){
				queryInString += queryCondition + ' AND ';
			}
			else{
				queryInString += queryCondition;
			} 
		}
		return queryInString;
	}

	static String getTagedContentIds(List<String> tagIds){
		List<tagAssignment__c> tagAssignments = [SELECT Id, Content__c, Tag__c FROM TagAssignment__c WHERE Tag__c IN: tagIds AND Content__c != NULL];
		Map<String,List<String>> contentTagMap = new Map<String,List<String>>();
		for(tagAssignment__c tagAssignment : tagAssignments){
			// Si el Contenido ya está en al mapa con una Tag, agregamos la Tag actual a su lista
			if(contentTagMap.keySet().contains(tagAssignment.Content__c)){
				contentTagMap.get(tagAssignment.Content__c).add(tagAssignment.Tag__c);
			// Si el Contenido no está en el mapa, lo agregamos creando una lista con la Tag actual
			} else{
				contentTagMap.put(tagAssignment.Content__c, new List<String>{tagAssignment.Tag__c});	
			}
		}
		// Construye la lista de Contenidos asociados a las Tags recibidas
		String tagedContentIds = '';
		for(String contentId : contentTagMap.keySet()){
			if(! tagedContentIds.contains(contentId)){
				Boolean taged = true;
				for(String tagId : tagIds){
					taged &= (contentTagMap.get(contentId).contains(tagId));
				}
				// Si el Contenido está asociado a TODAS las Tags recibidas, lo agrega a la lista
				if(taged){
					tagedContentIds += '\'' + contentId +  + '\', ';
				}
			}
		}
		// Devuelve la lista de forma que pueda ser incluida en la query dinámicamente
		tagedContentIds = '(' + tagedContentIds.substring(0, tagedContentIds.length()-2) + ')';
		return tagedContentIds;
	}

}