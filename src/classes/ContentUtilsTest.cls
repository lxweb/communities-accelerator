@isTest
public class ContentUtilsTest {
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest
	static void getContentFromComponentTest(){
		// Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente 

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1);

		List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);

		List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);

		set<String> fieldSet =  new set<String>{'ExternalId__c'};
		set<String> setClusterIds = new set<String>{clusterRootList[0].Id};
		
		// When
		Test.startTest();
		ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, null, setClusterIds, 'Desktop');
		Test.stopTest();
		// Then
		
		System.assertNotEquals(cw, null);
	}

	@isTest
	static void getContentPageTest(){
		/* Comment: dado una lista de Ids de Content__c devuelve una lista de Content__c 
		con una lista de sus MediaElement__c  correspondientes.
		*/

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1);

		List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);

		List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);

		set<String> fieldSet =  new set<String>{'ExternalId__c'};
		set<String> setClusterIds = new set<String>{clusterRootList[0].Id};
		set<String> setContentIds = new set<String>{contentList[0].Id};
		
		// When
		Test.startTest();

		List<ContentUtils.ContentDataWrapper> cdwList = ContentUtils.getContentPage(setContentIds, fieldSet, 1, 1, 'ExternalId__c', 'Desktop');

		Test.stopTest();
		// Then
		
		System.assertNotEquals(cdwList, null);


	}	
}