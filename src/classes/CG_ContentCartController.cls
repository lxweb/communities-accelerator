public with sharing class CG_ContentCartController {
    public class ContentCartWrapper{
        @AuraEnabled public List<CartItemWrapper> cartItemList;
        @AuraEnabled public Map<String, CartItemWrapper> cartItemMap;
        @AuraEnabled public List<String> fileDocumentList;

        public ContentCartWrapper(){
            this.cartItemList = new List<CartItemWrapper>();
            this.cartItemMap = new Map<String, CartItemWrapper>();
            this.fileDocumentList = new List<String>();
        }
    }
    public class CartItemWrapper{
        @auraEnabled public String cartItemId;
        @auraEnabled public String contentDocumentId;
        @auraEnabled public String contentId;
        @auraEnabled public String name;
        @auraEnabled public String description;
        @auraEnabled public String fileLink;
        @auraEnabled public String filePreviewLink;        
        @auraEnabled public String fileDownloadLink;


        public CartItemWrapper(String itemId, String name, String description, String contentDocumentId){
            this.cartItemId = itemId;
            this.name = name;
            this.description = description;
            this.fileLink = '';
            this.filePreviewLink = '';
            this.fileDownloadLink = '';
            this.contentDocumentId = contentDocumentId;
        }
        public CartItemWrapper(){
        }
    }

    @AuraEnabled
    public static ContentCartWrapper initData(){
        ContentCartWrapper contentCartWr = new ContentCartWrapper();
        Map<String, CartItemWrapper> contentCartItemMap = new Map<String, CartItemWrapper>();

        CartItemWrapper cartItemWrapper;

        List<ContentCartItem__c> contentCartList = [SELECT id, Content__c, Content__r.Name, Content__r.Description__c FROM ContentCartItem__c WHERE User__c =: UserInfo.getUserId()];
        for(ContentCartItem__c cci : contentCartList){
            cartItemWrapper = new CartItemWrapper();
            cartItemWrapper.cartItemId = cci.id;
            cartItemWrapper.name = cci.Content__r.Name;
            cartItemWrapper.description = cci.Content__r.Description__c;
            contentCartItemMap.put(cci.Content__c, cartItemWrapper);
        }

        List<MediaElementAssignment__c> contentAssignmentList = [SELECT Content__c, MediaElement__r.FileURLDesktop__c FROM MediaElementAssignment__c WHERE Content__c IN: contentCartItemMap.keySet() AND isDeleted = false];
        Map<String, String> contentDocIdMap = new Map<String, String>();

        for(MediaElementAssignment__c mea : contentAssignmentList){
            List<String> stringSplit = mea.MediaElement__r.FileURLDesktop__c.split('/');
            String str = stringSplit[stringSplit.size() - 1];

        	cartItemWrapper = contentCartItemMap.get(mea.Content__c);

            if (Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher(str).matches()){
	            contentDocIdMap.put(str, mea.Content__c);
	            cartItemWrapper.contentDocumentId = str;
            } else {
	            cartItemWrapper.contentDocumentId = '';
	            cartitemWrapper.filePreviewLink = mea.MediaElement__r.FileURLDesktop__c;
	            cartitemWrapper.fileDownloadLink = mea.MediaElement__r.FileURLDesktop__c;
            }
	        cartItemWrapper.contentId = mea.Content__c;
	        cartitemWrapper.fileLink = mea.MediaElement__r.FileURLDesktop__c;
            contentCartWr.cartItemMap.put(cartItemWrapper.cartItemId, cartItemWrapper);
            contentCartItemMap.put(mea.Content__c, cartItemWrapper);
        }

        if(contentDocIdMap.size() > 0){
			List<ContentDistribution> contentDocList = [SELECT id, ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN: contentDocIdMap.keySet()];
			for(ContentDistribution cd : contentDocList){
				cartItemWrapper = contentCartItemMap.get(contentDocIdMap.get(cd.ContentDocumentId));
				cartitemWrapper.filePreviewLink = cd.DistributionPublicUrl;
				cartitemWrapper.fileDownloadLink = cd.ContentDownloadUrl;
				contentCartItemMap.put(contentDocIdMap.get(cd.ContentDocumentId), cartitemWrapper);
			}        	
        }

        contentCartWr.cartItemList = contentCartItemMap.values();
        return contentCartWr;
    }


    @AuraEnabled
    public static Boolean addContentToCart(String contentId){
		List<ContentCartItem__c> contentCartList = [SELECT id, Content__c, Content__r.Name, Content__r.Description__c FROM ContentCartItem__c WHERE Content__c =: contentId AND User__c =: UserInfo.getUserId()];
		Boolean isCreated = false;
		if(contentCartList.size() == 0){
            ContentCartItem__c contentCart = new ContentCartItem__c();
            contentCart.User__c = UserInfo.getUserId();
            contentCart.Content__c = contentId;
            insert contentCart;
            isCreated = true;
		}

        return isCreated;
    }

    @AuraEnabled
    public static ContentCartWrapper deleteCartItems(String contentCartId, String data, Boolean isDeleteAll){
        ContentCartWrapper contentCartWr = (ContentCartWrapper)JSON.deserialize(data, ContentCartWrapper.class);        
        
        String queryContentCartItem = 'SELECT id FROM ContentCartItem__c';
        if(!isDeleteAll){
        	queryContentCartItem += ' WHERE Id =: contentCartId';
        }
        List<sObject> contentCartList = Database.query(queryContentCartItem);

        if(contentCartList.size() > 0){
        	delete contentCartList;

        	if(contentCartList.size() == contentCartWr.cartItemList.size()){
        		contentCartWr = new ContentCartWrapper();
			} else {
				contentCartWr.cartItemMap.remove(contentCartId);
				contentCartWr.cartItemList = contentCartWr.cartItemMap.values();				
    		}
        }
        return contentCartWr;
    }

    @AuraEnabled
    public static ContentCartWrapper downloadAllItems(String data){
        ContentCartWrapper contentCartWr = (ContentCartWrapper)JSON.deserialize(data, ContentCartWrapper.class);        
        List<String> fileDocumentList = new List<String>();

        for(CartItemWrapper ciw : contentCartWr.cartItemList){
        	contentCartWr.fileDocumentList.add(ciw.fileDownloadLink);
        }

        //Descargar el .ZIP desde aquí porque ya se tiene el fileDownloadLink

        return contentCartWr;
    }
}