public with sharing class CG_SocialNetworkController {
	public class NetworkWrapper{
        //Default parameters
		@auraEnabled public String token;
		@auraEnabled public String site;
		@auraEnabled public String tags;
		@auraEnabled public List<SocialNetworkWrapper> socialnetWrapper;
        //todo : token access to access media
        @auraEnabled public String usernameInstagram;
        @auraEnabled public String imagesToShare;
        @auraEnabled public List<ImagesWrapper> netWrapperList;
		

		public NetworkWrapper(){
			this.netWrapperList = new List<ImagesWrapper>();
			this.socialnetWrapper = new List<SocialNetworkWrapper>();
		}
	}

	public class ImagesWrapper{    
	    @auraEnabled public String url;
	    @auraEnabled public String description;
	    @auraEnabled public String position;
	    
	    public ImagesWrapper(String url, String description){
	        this.url = url;
	        this.description = description;
	        this.position = '0';
	    }
	}

	//Wrapper for socialNetworks
	public class SocialNetworkWrapper{
		@auraEnabled public String name;
		@auraEnabled public String username;
		@auraEnabled public String brand;
		@auraEnabled public String navigation;
		@auraEnabled public String token;
		@auraEnabled public String recordType;
		@auraEnabled public String tags;

		public SocialNetworkWrapper(String name, String username, String brand, String navigation, String token, String recordType, String tags){
			this.name = name;
			this.username = username;
			this.brand = brand;
			this.navigation = navigation;
			this.token = token;
			this.recordType = recordType;
			this.tags = tags;
		}
	}

	@auraEnabled
	public static NetworkWrapper getSocialNetworks(String brandId){
		NetworkWrapper nw = new NetworkWrapper();
		List<socialNetworkWrapper> sNetwork = new List<socialNetworkWrapper>();

		List<SocialNetwork__c> socialNetwork = [SELECT Id, Name, RecordType.Developername, Token__c, 
										  Brand__r.SiteURL__c, Username__c, Navigation__r.URL__c 
										  FROM SocialNetwork__c 
										  WHERE Brand__c =: brandId ORDER BY RecordType.Developername];

		for(SocialNetwork__c c : socialNetwork){
			String name = c.name;
			String username = c.Username__c;
			String navigation = c.Navigation__r.URL__c;
			String brand = c.Brand__r.SiteURL__c;
			String token = c.Token__c;
			String recordType = c.RecordType.Developername;

			sNetwork.add(new SocialNetworkWrapper(name,username,brand,navigation,token,recordType,null));
		}

		nw.socialnetWrapper = sNetwork;
		nw.site = sNetwork[0].brand;
       	return nw;
	} 

	//TODO: Investigate how to integrate SocialMedias like Twitter in CMS.
	//This code works for Instagram.
	private static NetworkWrapper getNetworkWrapper(String token){
		//String name = 'Instagram';	
		
		NetworkWrapper networkWrap;
		List<ImagesWrapper> imageWrList = new List<ImagesWrapper>();

		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://api.instagram.com/v1/users/self/media/recent?access_token=' + token + '&count=7');
		request.setMethod('GET');

		Http http = new Http();
		HTTPResponse response = http.send(request);
		system.debug('iris' + request);
		Map<String, Object> lista = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		Integer count = 0;
		String user;
		String tags = '';

		if(lista != null && lista.get('data') != null){
			List<Object> listobj = (List<Object>)lista.get('data');			

			for(Object obj : listobj) {			
				Map<String, Object> castedObjectMap = (Map<String, Object>)obj;

				//images
			    Map<String, Object> castedObject = (Map<String, Object>)castedObjectMap.get('images');
			    castedObject = (Map<String, Object>)castedObject.get('standard_resolution');
			    String url = (String)castedObject.get('url');

			    //description
			    castedObject = (Map<String, Object>)castedObjectMap.get('caption');
			    String description = (String)castedObject.get('text');

			    imageWrList.add(new ImagesWrapper(url, description));
			    imageWrList[count].position = String.valueOf(count);

			    if(count == 0){
			    	//username
				    castedObject = (Map<String, Object>)castedObjectMap.get('user');
				    user = (String)castedObject.get('username');
			    }

			    //tags
			    if(String.isBlank(tags) && ((List<Object>)castedObjectMap.get('tags')).size() > 0) {
			    	tags += '#' + String.join((List<Object>)castedObjectMap.get('tags'), ', #');			    	
			    }
			    count++;
			}
		}

		networkWrap = new networkWrapper();
		networkWrap.usernameInstagram = user;
		networkWrap.tags = tags;
		networkWrap.netWrapperList = imageWrList;

		return networkWrap;
	}
}