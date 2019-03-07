public with sharing class CG_ContentCatalogController {
	
	//WRAPPERS
    public class CatalogWrapper{
        @auraEnabled public Component__c component;
        @auraEnabled public Boolean isMini;
        @auraEnabled public Boolean withFilters;
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
        @auraEnabled public Brand__c brand;
        @auraEnabled public String brandURL;
        @auraEnabled public String behavior;
    }

    public class QueryContentWrapper {
    	private ContentSearchWrapper csw;
    	private ContentWrapper cw;
    	private QueryContentWrapper(){
    		this.csw = new ContentSearchWrapper();
    	}
    }

    //CatalogWrapper
    @auraEnabled
	public static CatalogWrapper getCatalogWrapper(String componentExternalId, String asset, String search, String brand, String tag, String category, String orderBy){
		//Query Component
		Component__c component = [SELECT Id, Mode__c, PageSize__c, OrderBy__c, LinkDetail__c, Datasource__c, ShowFilters__c, ShowDisplayMode__c, ShowOrder__c, ShowSearch__c, CatalogContentType__c, RecordType.DeveloperName
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
		
		//Order By
		if(component.OrderBy__c != null){
			orderBy = component.OrderBy__c;
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
		if(component.Datasource__c == 'Brands' || component.Datasource__c == 'Brand Variants'){
            
			//Filtro : Brands
			List<Brand__c> brandobj = [SELECT BrandContent__c, BrandContent__r.ListTitle__c FROM Brand__c WHERE BrandContent__c != NULL];
			set<String> setBrands = new set<String>();
			for(Brand__c c2 : brandobj){
				setContentIds.add(c2.BrandContent__c);
				if(!setBrands.contains(c2.BrandContent__c)){
					setBrands.add(c2.BrandContent__c);
					catalogWrapper.brands.add(c2.BrandContent__r.ListTitle__c);
				}	
			}

			//Filtro: content
			List<Content__c> contentForCategories = [SELECT Id, Category__c, Category__r.Name FROM Content__c WHERE RecordType.DeveloperName = 'BrandDetail' AND Category__c != NULL];
			set<String> setCategories = new set<String>();
			for(Content__c c: contentForCategories){
				setContentIds.add(c.Id);
				if(!setCategories.contains(c.Category__c)){
					setCategories.add(c.Category__c);
					catalogWrapper.categories.add(c.Category__r.Name);
				}
			}

			//Filtro: tags
			List<TagAssignment__c> contentTags = [SELECT Id, Tag__r.Name FROM TagAssignment__c WHERE Content__r.RecordType.DeveloperName  = 'BrandDetail'];
			set<String> setTags = new set<String>();
			for(TagAssignment__c c : contentTags){
				setTags.add(c.Tag__r.Name);
				catalogWrapper.tags.add(c.Tag__r.Name);
			}

		}

		Integer brandTotal = CatalogWrapper.brands.size();
		//Query Content
		if(component.Mode__c == 'Mini'){
			for(QueryContentWrapper qcw: getContentWrapper(setContentIds, orderBy, Integer.valueOf(component.PageSize__c), true, Integer.valueOf(component.PageSize__c))){
				
				//Data used for search(Filter side panel)
				catalogWrapper.allContentSearchWrapper.add(qcw.csw);	
				
				//Elements shown as cards/Lines
				if(qcw.cw != null){catalogWrapper.contentWrapper.add(qcw.cw);}
			}
		}
		if(component.Mode__c == 'Full'){
			for(QueryContentWrapper qcw: getContentWrapper(setContentIds, orderBy, Integer.valueOf(component.PageSize__c), true, brandTotal)){
			
				catalogWrapper.allContentSearchWrapper.add(qcw.csw);	
	
				if(qcw.cw != null){catalogWrapper.contentWrapper.add(qcw.cw);}
			}	
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

		for(QueryContentWrapper qcw: getContentWrapper(setContentIds, orderBy, contentIds.size(), false, setContentIds.size())){
			wrapper.add(qcw.cw);
		}		
		return wrapper;
	}
    
	public static List<QueryContentWrapper> getContentWrapper(set<Id> setContentIds, String orderBy, Integer contentWrapperQuantity, Boolean getSearchWrapper, Integer queryLimit){
		List<QueryContentWrapper> wrapper = new List<QueryContentWrapper>();

		//Display Brands
		String queryContent = '';
		queryContent += 'SELECT Id, Name, ListTitle__c, Category__r.Name, Category__c, RecordType.DeveloperName, Description__c, LinkDetail__r.URL__c ';
		queryContent += 'FROM Content__c ';
		queryContent += 'WHERE Id IN: setContentIds AND ListTitle__c != \'' + '' + '\' ';
		queryContent += 'ORDER BY ' + orderBy ;
		queryContent += '\' '+ queryLimit != null ? (' LIMIT ' + String.ValueOf(queryLimit)) : ''; 	

		//Search Properties	
		for(Content__c content: Database.query(queryContent)){
			QueryContentWrapper qcw = new QueryContentWrapper();
			if(getSearchWrapper){
				qcw.csw = new ContentSearchWrapper();
				qcw.csw.contentId = content.Id;
		        qcw.csw.searchWords = content.ListTitle__c;
		        qcw.csw.brand = content.ListTitle__c;
		        qcw.csw.category = content.Category__r.Name;
		        qcw.csw.tags = '';
		        for(TagAssignment__c c : [SELECT Tag__r.Name FROM TagAssignment__c WHERE Content__r.RecordType.DeveloperName  = 'BrandDetail' AND Content__r.Name =: content.Name]){
		        	qcw.csw.tags += c.Tag__r.Name + ';';
		        }
	    	}

	    	//Content
			if(contentWrapperQuantity > 0){
				qcw.cw = new ContentWrapper(); 
                List<Brand__c> brandsOnly = [SELECT Id, RecordTypeId, Name, BrandContent__c, Description__c FROM Brand__c WHERE BrandContent__c =: content.Id];	
                for(Brand__c b : brandsOnly){
            		qcw.cw.brand = new Brand__c(Id = b.Id, Name = b.Name, BrandContent__c = b.BrandContent__c, RecordTypeId = b.RecordTypeId);	
            		qcw.cw.content = new Content__c(Id = content.Id, Description__c = content.Description__c, ListTitle__c = content.ListTitle__c);
                    qcw.cw.brandURL = content.LinkDetail__r.URL__c;
                }
                // Load mediaElement images 
                List<MediaElementAssignment__c> med = [SELECT Id, MediaElement__r.FileURLDesktop__c, MediaElement__r.ExternalId__c FROM MediaElementAssignment__c WHERE Content__c =: content.Id];
                if(!med.isEmpty()){
                    qcw.cw.mediaElementImageURL = med[0].MediaElement__r.FileURLDesktop__c;
                    qcw.cw.documentId = med[0].MediaElement__r.ExternalId__c;
                }  
			}
			wrapper.add(qcw);
		}
		return wrapper;
	}
}