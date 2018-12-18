public with sharing class CG_ContentToolsController {
	public class ImagesWrapper{    
	    @auraEnabled public String idImage;
	    @auraEnabled public String url;
	    @auraEnabled public String assetId;
	    @auraEnabled public String assetUrl;
	    
	    public ImagesWrapper(){
	    }
	}

	@auraEnabled
	public static ImagesWrapper initData(String imageUrl, String assetId){
		ImagesWrapper imageWr = new ImagesWrapper();
		imageWr.assetId = assetId;		
		String idImage;
		
		if(imageUrl.contains('file=')){
			imageWr.assetUrl = imageUrl;
			idImage = (imageUrl.split('file='))[1].substring(0,15);
		}

		String url = System.URL.getSalesforceBaseUrl() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=0680b000003Ltck&contentId=05T0b00000ATEnF';
		url = EncodingUtil.urlEncode(url, 'UTF-8');
		
		imageWr.url = url;
		imageWr.idImage = idImage;
		return imageWr;
	}
	
	@auraEnabled
	public static ImagesWrapper addToCarts(String data){
		
		ImagesWrapper imageWr = (ImagesWrapper)JSON.deserialize(data, ImagesWrapper.class);
		//CP_AssetDetailController.addToCart(imageWr.assetId, imageWr.assetUrl, '');
		
		return imageWr;
	}

}