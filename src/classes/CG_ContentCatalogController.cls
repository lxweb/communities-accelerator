public with sharing class CG_ContentCatalogController {
	
	//WRAPPERS
    public class CatalogWrapper{
        @auraEnabled public Component__c component;
        @auraEnabled public Boolean isMini;
        @auraEnabled public Boolean withFilters;
        @auraEnabled public String navigationURL;
		@auraEnabled public List<ContentSearchWrapper> allContentSearchWrapper;
		@auraEnabled public List<ContentWrapper> contentWrapper;
        @auraEnabled public List<String> brands;
		@auraEnabled public List<String> tags;
		@auraEnabled public List<String> categories;
	}

    public class ContentSearchWrapper{
        @auraEnabled public String contentId;
        @auraEnabled public String searchWords;
        @auraEnabled public String brand;
        @auraEnabled public String tags;
        @auraEnabled public String category;
    }

    public class ContentWrapper{
        @auraEnabled public Content__c content;
        @auraEnabled public String documentId;
        @auraEnabled public String mediaElementImageURL;
    }

    public class QueryContentWrapper {
    	private ContentSearchWrapper csw;
    	private ContentWrapper cw;
    	private QueryContentWrapper(){
    		this.csw = new ContentSearchWrapper();
    	}
    }

    @auraEnabled
	public static CatalogWrapper getCatalogWrapper(String componentExternalId, String asset, String search, String brand, String tag, String category, String orderBy){
		//Query Component
		Component__c component = [SELECT Id, Mode__c, PageSize__c, OrderBy__c, LinkDetail__c,LinkDetail__r.URL__c, Datasource__c, ShowFilters__c, ShowDisplayMode__c, ShowOrder__c, ShowSearch__c, CatalogContentType__c, RecordType.DeveloperName
									 FROM Component__c
									 WHERE ExternalId__c =: componentExternalId];

		//Armo el wrapper de retorno
		CatalogWrapper catalogWrapper = new CatalogWrapper();
		catalogWrapper.component = new Component__c(
			Id = component.Id,
			PageSize__c = component.PageSize__c, 
			ShowFilters__c = component.ShowFilters__c,
			ShowDisplayMode__c = component.ShowDisplayMode__c,
			ShowOrder__c = component.ShowOrder__c,
			ShowSearch__c = component.ShowSearch__c,
			LinkDetail__c = component.LinkDetail__c,
			Datasource__c = component.Datasource__c,
			CatalogContentType__c = component.CatalogContentType__c,
			OrderBy__c = component.OrderBy__c
		);

		catalogWrapper.isMini = component.Mode__c == 'Mini';
		catalogWrapper.withFilters = component.ShowFilters__c && component.ShowDisplayMode__c && component.ShowOrder__c && component.ShowSearch__c;
		catalogWrapper.allContentSearchWrapper = new List<ContentSearchWrapper>();
		catalogWrapper.contentWrapper = new List<ContentWrapper>();
		catalogWrapper.brands = new List<String>();
		catalogWrapper.categories = new List<String>();
		catalogWrapper.tags = new List<String>();
		catalogWrapper.navigationURL = component.LinkDetail__r.URL__c;

		//Order By
		if(component.OrderBy__c != null){
			orderBy = component.OrderBy__c;
		}

		//Busco los tags relacionados al Component
		set<Id> setComponentTagIds = new set<Id>();
		for(TagAssignment__c tagAssignment: [SELECT Id, Name FROM TagAssignment__c WHERE Component__r.Id =: component.Id]){
			setComponentTagIds.add(tagAssignment.Id);
		}


		//Filtro por Tag por parametro
		if(tag != null && tag != ''){
			setComponentTagIds = new set<Id>();
			setComponentTagIds.add(tag);
		}

		//Filtro Asset type
		String cTypes = component.CatalogContentType__c;
		set<String> typesToSearch = new set<String>();
		if(cTypes != null){
			if(cTypes.contains('Logo')){typesToSearch.add('Logo');}
			if(cTypes.contains('Social Media')){typesToSearch.add('Social Media');}
			if(cTypes.contains('Videos')){typesToSearch.add('Videos');}
			if(cTypes.contains('Occasion')){typesToSearch.add('Occasion');}
		}

		set<Id> setContentIds = new set<Id>();
		if(component.Datasource__c == 'Brands')
		{

			set<Id> contentIdsByTags = new set<Id>();
			if(!setComponentTagIds.isEmpty()){
				for(TagAssignment__c ta: [SELECT Id, Content__c FROM TagAssignment__c WHERE ExternalId__c IN: setComponentTagIds AND Content__c != NULL AND Content__r.RecordType.DeveloperName = 'BrandDetail']){
					contentIdsByTags.add(ta.Content__c);
				}
			}

			String query = '';
			query += 'SELECT Id, Category__r.Name ';
			query += 'FROM Content__c ';
			query += 'WHERE ' + (!contentIdsByTags.isEmpty() ? ' Id IN: contentIdsByTags AND ' : '') + (category != null && category != '' ? ' Category__c =: category AND ' : '') + ' RecordType.DeveloperName = \'BrandDetail\' ';
      
			//Completo los Wrappers con la lista final de contenido
			for(Content__c c: Database.query(query)){
				setContentIds.add(c.Id);
				catalogWrapper.categories.add(c.Category__r.Name);
				
			}
			
	       //Filtro : Brands
            List<Brand__c> brandobj = [SELECT Id, Name FROM Brand__c WHERE BrandContent__c IN: setContentIds];
            for(Brand__c c2 : brandobj){
            	catalogWrapper.brands.add(c2.Name);
            }	
        
			
		

		}else if(component.Datasource__c == 'Brand Variants' && brand != null && brand != '')
		{
		    
			set<Id> contentIds = new set<Id>();
			for(Brand__c b: [SELECT Id, BrandContent__c FROM Brand__c WHERE Id =: brand AND BrandContent__c != NULL]){
				contentIds.add(b.BrandContent__c);
			}

			for(Content__c c: [SELECT Id, Brand__r.Name, Category__r.Name FROM Content__c WHERE Id IN: contentIds]){
				setContentIds.add(c.Id);
				catalogWrapper.brands.add(c.Brand__r.Name);
				catalogWrapper.categories.add(c.Category__r.Name);
			}

		}else if(component.Datasource__c == 'Assets' && cTypes != null)
		{
			if(!setComponentTagIds.isEmpty()){
				//Get content by Tag
				String query = '';
				query += 'SELECT Id, Content__c, Content__r.Brand__r.Name, Content__r.Category__r.Name ';
				query += 'FROM TagAssignment__c ';
				query += 'WHERE ';
				query += 'Tag__c IN: setComponentTagIds AND ';
				query += 'Content__c != NULL AND ';

				//Brand filter
				if(brand != null && brand != ''){
					query += '(Content__r.Brand__c =: brand OR Content__r.Brand__r.MasterBrand__c =: brand) AND ';
				}

				//Filtro Asset type
				query += getConditionForAssetType(cTypes, typesToSearch, 'TagAssignment__c');

				for(TagAssignment__c tagAssignment: Database.query(query)){
					setContentIds.add(tagAssignment.Content__c);
					catalogWrapper.brands.add(tagAssignment.Content__r.Brand__r.Name);
				    catalogWrapper.categories.add(tagAssignment.Content__r.Category__r.Name);
				}
			}else{
				//Get content by Tag
				String query = '';
				query += 'SELECT Id, Brand__c, Brand__r.Name, Category__r.Name ';
				query += 'FROM Content__c ';
				query += 'WHERE ';

				//Brand filter
				if(brand != null && brand != ''){
					query += '(Brand__c =: brand OR Brand__r.MasterBrand__c =: brand) AND ';
				}

				//Filtro Asset type
				query += getConditionForAssetType(cTypes, typesToSearch, 'Content__c');
				
	            for(Content__c content: Database.query(query)){
					setContentIds.add(content.Id);
					catalogWrapper.brands.add(content.Brand__r.Name);
				    catalogWrapper.categories.add(content.Category__r.Name);
				}
		
			}

		}else if(component.Datasource__c == 'Assets related to Assets' && asset != null && asset != '' && cTypes != null)
		{

			orderBy = 'RecordType.Name ASC, AssetType__c ASC, Title__c ASC';

			Content__c contentAsset = [SELECT Id, Brand__c, Brand__r.MasterBrand__c FROM Content__c WHERE Id =: asset];

			String query = '';
			query += 'SELECT Id, Brand__r.Name, Category__r.Name ';
			query += 'FROM Content__c ';
			query += 'WHERE ';
			query += 'Id != \'' + contentAsset.Id + '\' AND ';
			
			if(contentAsset.Brand__c != null && contentAsset.Brand__r.MasterBrand__c != null){
				query += '(Brand__c = \'' + contentAsset.Brand__c + '\' OR Brand__c = \'' + contentAsset.Brand__r.MasterBrand__c + '\') AND ';
			}else if(contentAsset.Brand__c != null){
				query += '(Brand__c = \'' + contentAsset.Brand__c + '\') AND ';
			}

			//Filtro Asset type
			query += getConditionForAssetType(cTypes, typesToSearch, 'Content__c');
			
            for(Content__c content: Database.query(query)){
				setContentIds.add(content.Id);
				catalogWrapper.brands.add(content.Brand__r.Name);
			    catalogWrapper.categories.add(content.Category__r.Name);
			}
		}
  
		//Query Content
		set<String> setContentTags = new set<String>();
		for(QueryContentWrapper qcw: getContentWrapper(setContentIds, orderBy, Integer.valueOf(component.PageSize__c), true, null)){
			//Cargo los datos para el search
			catalogWrapper.allContentSearchWrapper.add(qcw.csw);
			
			//Cargo los tags de los contenidos

			if(qcw.csw.tags != ''){	
				for(String t: qcw.csw.tags.split(';')){
					if(t != ''){setContentTags.add(t);}
				}
			}

			//Cargo los contenidos de la primera pagina
			if(qcw.cw != null){
				catalogWrapper.contentWrapper.add(qcw.cw);
			}
		}

		for(String t: setContentTags){
			catalogWrapper.tags.add(t);
		}

		return catalogWrapper;
	}

	@auraEnabled
	public static List<ContentWrapper> getNextContent(List<String> contentIds, String orderBy){
		List<ContentWrapper> wrapper = new List<ContentWrapper>();

		set<Id> setContentIds = new set<Id>();
		for(String i: contentIds){
			setContentIds.add(i);
		}
		for(QueryContentWrapper qcw: getContentWrapper(setContentIds, orderBy, contentIds.size(), false, null)){
			wrapper.add(qcw.cw);
		}
		return wrapper;
	}

	public static List<QueryContentWrapper> getContentWrapper(set<Id> setContentIds, String orderBy, Integer contentWrapperQuantity, Boolean getSearchWrapper, Integer queryLimit){
		List<QueryContentWrapper> wrapper = new List<QueryContentWrapper>();
        

		if(orderBy == null || orderBy == ''){
			orderBy = 'Title__c ASC';
		}

        String queryContent = '';
		queryContent += 'SELECT Id,Brand__c, Brand__r.Name, Category__r.Name, LinkDetail__r.URL__c,  ';
		queryContent += 'RecordType.DeveloperName, AssetType__c, Title__c, ';
		queryContent += 'Description__c, (SELECT Tag__r.Name FROM Tags__r) ';
		queryContent += 'FROM Content__c ';
		queryContent += 'WHERE Id IN: setContentIds ORDER BY ' + orderBy + (queryLimit != null ? (' LIMIT ' + String.ValueOf(queryLimit)) : '');
        
  
        
        
		for(Content__c content: Database.query(queryContent)){
		    QueryContentWrapper qcw = new QueryContentWrapper();
            if (content.RecordType.DeveloperName == 'BrandDetail')
            {
                Brand__c brandOnly = [SELECT Id,Name FROM Brand__c WHERE BrandContent__c =: content.Id];
    			//Search properties
    			if (brandOnly != null){
        			if(getSearchWrapper){
        				qcw.csw = new ContentSearchWrapper();
        				qcw.csw.contentId = content.Id;
        		        qcw.csw.searchWords = content.Title__c;
        		        qcw.csw.brand = brandOnly.Name;
        		        qcw.csw.category = content.Category__r.Name;
        				qcw.csw.tags = '';
        		        for(TagAssignment__c ta: content.Tags__r){
        		        	qcw.csw.tags += ta.Tag__r.Name + ';';
        		    	}
        			}
    			}
            }else{
            	//Search properties
    			if(getSearchWrapper){
    				qcw.csw = new ContentSearchWrapper();
    				qcw.csw.contentId = content.Id;
    		        qcw.csw.searchWords = content.Title__c;
    		        qcw.csw.brand = content.Brand__r.Name;
    		        qcw.csw.category = content.Category__c;
    				qcw.csw.tags = '';
    		        for(TagAssignment__c ta: content.Tags__r){
    		        	qcw.csw.tags += ta.Tag__r.Name + ';';
    		    	}
                }
		
	    	}
       
	    

	    	//Content
			if(contentWrapperQuantity > 0){
				contentWrapperQuantity--;
				qcw.cw = new ContentWrapper();
				if (content.RecordType.DeveloperName == 'BrandDetail'){
				    Brand__c brandOnly = [SELECT Id,Name FROM Brand__c WHERE BrandContent__c =: content.Id];
                	qcw.cw.content = new Content__c(Id = content.Id, Description__c = content.Description__c, Title__c = content.Title__c, Brand__c = brandOnly.Id);
				}
				else{
				    qcw.cw.content = new Content__c(
					Id = content.Id,
					Title__c = content.Title__c,
					Description__c = content.Description__c,
					AssetType__c = content.RecordType.DeveloperName + (content.AssetType__c != null ? ' ' + content.AssetType__c : ''),
					Brand__c = content.Brand__c
				    );
				}
		
		
		        List<MediaElementAssignment__c> media = [SELECT Id, MediaElement__c, MediaElement__r.ExternalId__c ,MediaElement__r.FileURLDesktop__c FROM MediaElementAssignment__c WHERE Content__c =: content.Id];
		        
		   
				if(!media.isEmpty() && media[0].MediaElement__c != null){
					qcw.cw.mediaElementImageURL = media[0].MediaElement__r.FileURLDesktop__c;
					qcw.cw.documentId = media[0].MediaElement__r.ExternalId__c;
				}else{
					qcw.cw.mediaElementImageURL = 'http://ingoforce.co.za/wp-content/uploads/2012/08/placeholder2.jpg';
				}
			}
			
			wrapper.add(qcw);
		}
		return wrapper;
	}

	private static String getConditionForAssetType(String cTypes, set<String> typesToSearch, String queryObject){

		Boolean isRelated = queryObject != 'Content__c';

		List<String> listConditions = new List<String>();
		if(cTypes.contains('Recipe')){
			listConditions.add('(' + (isRelated ? 'Content__r.' : '') + 'RecordType.DeveloperName = \'Recipe\')');
		}
		if(cTypes.contains('Product')){
			listConditions.add('(' + (isRelated ? 'Content__r.' : '') + 'RecordType.DeveloperName = \'Product\')');
		}
		if(!typesToSearch.isEmpty()){
			listConditions.add('(' + (isRelated ? 'Content__r.' : '') + 'RecordType.DeveloperName = \'Asset\' AND ' + (isRelated ? 'Content__r.' : '') + 'AssetType__c IN: typesToSearch)');
		}

		String query = '(' + String.join(listConditions, ' OR ') + ')';

		return query;
	}

}