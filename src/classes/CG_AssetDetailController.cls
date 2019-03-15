public with sharing class CG_AssetDetailController {
    //WRAPPERS
    public class ContentWrapper{
        @auraEnabled public String detailTitle;     
        @auraEnabled public String longDescription;
        @auraEnabled public String mediaElementImageURL;
        @auraEnabled public String mediaElementImageDocumentId;
        @auraEnabled public Boolean disableAdd;
        @auraEnabled public Boolean disableDownload;
        @auraEnabled public List<TagWrapper> tagsList;
        @auraEnabled public Boolean isRecipie;
        @auraEnabled public String pdfUrl;
        @auraEnabled public String ingredients;
        @auraEnabled public String instructions;
        @auraEnabled public String urlPrimaryImage;
        @auraEnabled public String urlPrimaryImageDocumentId;
        @auraEnabled public String urlFeaturingImage;
        @auraEnabled public String brandTitle;
        @auraEnabled public String urlBrandLink;

        public ContentWrapper(){
            isRecipie=false;
            detailTitle=' ';
            longDescription=' ';
            ingredients='';
            instructions=''; 
            urlPrimaryImageDocumentId=null;//'';
            mediaElementImageDocumentId='';
            disableAdd=false;
            disableDownload=false;
            tagsList= new List<TagWrapper>();
        }
	}

    public class TagWrapper{
        @auraEnabled public String detailTitle;
        @auraEnabled public String tagLink;
        public TagWrapper(String title, String link){
            detailTitle=title;
            tagLink= link;
        }
    }

/**
* Load all Wrappers attributes for the contentId. externalId is used to find the tags url
* and urlBrand for Featuring's image 
**/
    @AuraEnabled
    public static ContentWrapper getRecord(Id contentId, String externalId){
        Content__c content = getcontent(contentId);
        
        ContentWrapper contentWrapper = new ContentWrapper();
        if(content != null){
            contentWrapper.detailTitle = content.Title__c;

            contentWrapper.longDescription = content.Description__c;
            contentWrapper.tagsList = getTags(contentId, externalId);            

            System.debug('DEBUG: content.RecordType.DeveloperName: '+content.RecordType.DeveloperName);
            System.debug('DeveloperName: '+content.RecordType.DeveloperName);
            if(content.RecordType.DeveloperName == 'Recipe'){

                contentWrapper.isRecipie = true;
                //contentWrapper.pdfUrl = content.PDFURL__c;  ????????????? PREGUNTAR A LIHUE
                contentWrapper.pdfUrl =content.URLRedirect__c;	

				for(RecipeIngredient__c ing : [Select Id, CustomIngredient__c, OtherIngredient__c, Name, Quantity__c, Unit__c, BrandVariant__c, RecordType.DeveloperName  from RecipeIngredient__c where Recipe__r.content__c =: contentId order by Order__c]){                
               
                    if(String.isNotEmpty(ing.Quantity__c+ing.Unit__c)){
                       contentWrapper.ingredients= contentWrapper.ingredients + ing.Quantity__c+ing.Unit__c+' ';
                    }
                    if( ing.RecordType.DeveloperName.equalsIgnoreCase('BrandIngredient')){
                       contentWrapper.ingredients= contentWrapper.ingredients + ing.Name+'<br/>';
                    } 
                    if(String.isNotEmpty(ing.CustomIngredient__c)){
                        contentWrapper.ingredients= contentWrapper.ingredients + ing.CustomIngredient__c+'<br/>';
                    }
                    if(String.isNotEmpty(ing.OtherIngredient__c)){
                        contentWrapper.ingredients= contentWrapper.ingredients + ing.OtherIngredient__c+'<br/>';
                    }
                }

                for(RecipeStep__c step : [Select Id, Name, Order__c, Step__c from RecipeStep__c where Recipe__r.content__c =: contentId order by Order__c]){
                    contentWrapper.instructions = contentWrapper.instructions + step.Order__c+' '+ step.Step__c +'<br/>';
                }

                Map<String,String> mediaMap = searchMediasRecipes(contentId, externalId);

                if(String.isNotEmpty(mediaMap.get('RecipeImageDetail'))){
                    contentWrapper.urlPrimaryImage = mediaMap.get('RecipeImageDetail');
                    contentWrapper.urlPrimaryImageDocumentId = mediaMap.get('RecipeImageDetail').right(18);
                }
                if(String.isNotEmpty(mediaMap.get('RecipeImageList'))){
                    contentWrapper.mediaElementImageURL = mediaMap.get('RecipeImageList');
                    contentWrapper.mediaElementImageDocumentId = mediaMap.get('RecipeImageList').right(18);
                }

                if(String.isNotEmpty(mediaMap.get('BrandImageList'))){
                    contentWrapper.urlFeaturingImage = mediaMap.get('BrandImageList');
                }
                contentWrapper.brandTitle = mediaMap.get('brandTitle');

                contentWrapper.disableAdd = (String.isEmpty(mediaMap.get('RecipeImageDetail')) && String.isEmpty(mediaMap.get('RecipeImageList')));
                contentWrapper.disableDownload = (String.isEmpty(mediaMap.get('RecipeImageDetail')) && String.isEmpty(mediaMap.get('RecipeImageList')));

                contentWrapper.urlBrandLink = mediaMap.get('urlBrandLink');

            }else if(!content.MediaElementAssignments__r.isEmpty() && content.MediaElementAssignments__r[0].MediaElement__c != null){
                contentWrapper.mediaElementImageURL = content.MediaElementAssignments__r[0].MediaElement__r.FileURLDesktop__c;
                contentWrapper.mediaElementImageDocumentId = contentWrapper.mediaElementImageURL.right(18);
                contentWrapper.disableAdd=false;
                contentWrapper.disableDownload=false;
            }
        }
    
        return contentWrapper;
    }

/**
* This method is called to add a mediaElement to the cart
* url is the url of the mediaElement image
* urlPrimary is the url for the second image (only for recipes) 
**/ 

    @AuraEnabled
    public static void addToCart(Id contentId){ 
        Boolean isInserted = CG_ContentCartController.addContentToCart(contentId);
        if (!isInserted){
        	throw new AuraHandledException(System.Label.DuplicateItem);
        }
    }
    
    /**
    * obtains the corresponding CP_content_c for the requested contentId
    **/
    private static Content__c getcontent(Id contentId){

        Content__c content;
        try{
            //search for asset-details page
            //Ingredients__c, Instructions__c,
        	 content = [SELECT Id, RecordType.DeveloperName, Title__c, Description__c, URLRedirect__c, 
                       (SELECT Id, MediaElement__c, Placement__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE Placement__c = 'assetImage')
                        FROM Content__c
                        WHERE Id =:contentId]; 

            //search for assets page
            //Ingredients__c, Instructions__c,
            if(content.RecordType.DeveloperName == 'BrandDetail'){
                content = [SELECT Id, RecordType.DeveloperName, Title__c, Description__c, URLRedirect__c,
                       (SELECT Id, MediaElement__c, Placement__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE Placement__c = 'BrandImageList') //'brandVariantCatalogImage')
                        FROM Content__c
                        WHERE Id =:contentId]; 
            }
/* NO EXISTEN ESTOS RECORD TYPE
            //Ingredients__c, Instructions__c,
            if(content.RecordType.DeveloperName == 'Product'){
                content = [SELECT Id, RecordType.DeveloperName, Title__c, Description__c, URLRedirect__c,
                       (SELECT Id, MediaElement__c, Placement__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE Placement__c = 'productImage')
                        FROM Content__c
                        WHERE Id =:contentId]; 
            }

            //Ingredients__c, Instructions__c,
            if(content.RecordType.DeveloperName == 'Brand'){
                content = [SELECT Id, RecordType.DeveloperName, Title__c, Description__c, URLRedirect__c,
                       (SELECT Id, MediaElement__c, Placement__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE Placement__c = 'BrandImageLogo') //'BrandLogoImage')
                        FROM Content__c
                        WHERE Id =:contentId]; 
            }
*/
        }catch(exception e){}

        return content;     
    }

/**
* search tags related with the Content__c with id = contentId
**/
    private static List<TagWrapper> getTags(Id contentId, String externalId){
        String link= getLinkTag(externalId);
        List<TagWrapper> tagsList = new List<TagWrapper>();
        try{
            for(TagAssignment__c tagAssig :[SELECT id, Tag__r.id, Tag__r.Name  from TagAssignment__c where Content__c =: contentId]){
                TagWrapper tag = new TagWrapper(tagAssig.Tag__r.Name, link+'?tag='+tagAssig.Tag__r.id);
                tagsList.add(tag);
            }
        }catch(exception e){} 
        return tagsList; 
    }   

/**
* search media elements and Brand Url for asset type recipe for recipe-detail page
**/
    private static Map<String, String> searchMediasRecipes(Id contentId, String externalId){
        Map<String, String> mediaMap = new Map<String, String>();
        try{
            Content__c content = [SELECT Id,
                                    (SELECT Id, MediaElement__c, Placement__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignments__r WHERE Placement__c in ('RecipeImageList','RecipeImageDetail')) 
                                     FROM Content__c WHERE Id =: contentId Limit 1];
            
            for(MediaElementAssignment__c media : content.MediaElementAssignments__r){
                mediaMap.put(media.Placement__c, media.MediaElement__r.FileURLDesktop__c);
            }
            
            RecipeIngredient__c recipe = [SELECT id, BrandVariant__c, Recipe__c FROM RecipeIngredient__c WHERE Recipe__r.content__c =: contentId and RecordType.DeveloperName = 'BrandIngredient' ];
            Brand__c brand = [SELECT Id, Name, BrandContent__c, BrandContent__r.Description__c, BrandContent__r.Title__c, MasterBrand__c, RecordType.DeveloperName, Description__c FROM Brand__c WHERE Id = :recipe.BrandVariant__c];

            list<MediaElementAssignment__c> brandContent = [SELECT id, MediaElement__r.FileURLDesktop__c, Placement__c FROM MediaElementAssignment__c WHERE Content__c =: brand.BrandContent__c and Placement__c = 'BrandImageList' ];
            mediaMap.put('BrandImageList', brandContent[0].MediaElement__r.FileURLDesktop__c);
            mediaMap.put('brandTitle', brand.BrandContent__r.Title__c);
            String link = getLinkFeaturing(externalId);
           mediaMap.put('urlBrandLink', link+'?brand='+brand.Id);
    
        }catch(exception e){}
        return mediaMap;
    }

/**
* 
**/
    private static String getLinkTag(String externalId){ 
        if(externalId != null){
            try{
                Component__c comp = [SELECT id, NavigationMode__c FROM Component__c WHERE ExternalId__c = :externalId ];
                return comp.NavigationMode__c;
            }catch(exception e){}
        }
        return '';
    }

    private static String getLinkFeaturing(String externalId){
        if(externalId != null){
            try{
                Component__c comp = [SELECT id, LinkDetail__c FROM Component__c WHERE ExternalId__c = :externalId ];
                return comp.LinkDetail__c;
            }catch(exception e){}
        }
        return '';
    } 


    @AuraEnabled
    public static Map <String, String> downloadAllItems(String data){
        ContentWrapper contentWr = (ContentWrapper)JSON.deserialize(data, ContentWrapper.class);                
        Map <String, String> imageMap = new Map <String, String>();
        List<String> documentInternalIdList = new List<String>();
        List<String> documentExternalList = new List<String>();

        List<String> urlList = new List<String>();
        
        if(String.isNotEmpty(contentWr.mediaElementImageURL)){
           urlList.add(contentWr.mediaElementImageURL);
        }   
        if(String.isNotEmpty(contentWr.urlPrimaryImage)){
           urlList.add(contentWr.urlPrimaryImage);
        }  
        
        //GET SALESFORCE DOCUMENTID FOR INTERNAL IMAGE
        for(String mea : urlList){
            List<String> stringSplit = mea.split('/');
            String str = stringSplit[stringSplit.size() - 1];
            if (Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(str).matches()){
	            documentInternalIdList.add(str);
            } else {
            	documentExternalList.add(mea); 
            }
        }
        
        //GET BASE64 FOR EXTERNAL IMAGE
        for (String ext : documentExternalList){        
        	HttpRequest req = new HttpRequest();
            req.setEndpoint(ext);
            req.setMethod('GET');
            Http binding = new Http();
            HttpResponse res = binding.send(req);
            Blob image = res.getBodyAsBlob();
            String name = ext.substringAfterLast('/');
            if(String.isNotEmpty(name)){
                if(!name.contains('.')){
                    name=name+'.jpg';
                }
            }else{
                name=contentWr.detailTitle+'.jpg';
            }
            imageMap.put(name, EncodingUtil.base64Encode(image));
        }

        //GET BASE64 FOR IMAGE IN SALESFORCE
        List<ContentVersion> contentVersionList = [SELECT Id, Title, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId in : documentInternalIdList AND IsLatest = true];
        for (ContentVersion contv : contentVersionList){
            imageMap.put(contv.Title + '.' + contv.FileExtension, EncodingUtil.base64Encode(contv.VersionData));
        }

        return imageMap;
    } 
}