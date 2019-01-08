@isTest
public class ContentUtilsTest {
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest
	static void getContentPageTest(){
		
		/* Comment: dado una lista de Ids de Content__c devuelve una lista de Content__c 
		con una lista de sus MediaElement__c  correspondientes.
		*/

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1);
		Component__c comp = componentList[0];
		componentList = [SELECT Name, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
				FROM Component__c WHERE Id =: comp.ID];


		List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);

		List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);

		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

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

	@isTest
	static void getContentFromComponentTest(){
		// Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente 

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Event', 1);
		Component__c comp = componentList[0];
		comp.ExcludePastEvents__c=true;
		update comp;

		componentList = [SELECT Name, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
				FROM Component__c WHERE Id =: comp.ID];

//HACER QERY COMPLETA DE COMP


		List<Content__c> contentList = MockupFactory.createContent('Event', clusterRootList[0], 1);
		List<ContentAssignment__c> contentAssigmentList = MockupFactory.createContentAssignment(contentList, componentList);

		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

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
	static void getContentFromTagTest(){
		// Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a un Tag

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1);
		Component__c comp = componentList[0];
		comp.Datasource__c='Tags';
		update comp;
		componentList = [SELECT Name, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c, PageSize__c
				FROM Component__c WHERE Id =: comp.ID];
		List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);

		List<Tag__c> tagList = MockupFactory.createTag('TestTag', 'Tag de test', 1, clusterRootList[0].Id);
		List<TagAssignment__c> tagAssigmentList = MockupFactory.createTagAssignment(tagList, componentList, contentList);

		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

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
	static void getContentFromCategoriesTest(){
		// Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a una Category__c

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1);
		Component__c comp = componentList[0];
		comp.Datasource__c='Categories';
		update comp;
		componentList = [SELECT Name, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
				FROM Component__c WHERE Id =: comp.ID];
		List<Category__c> categoryList = MockupFactory.createCategory('TestCategory', 1, clusterRootList[0].Id);
		List<CategoryAssignment__c> categoryAssignmentList = MockupFactory.createCategoryAssignment(categoryList, componentList);	
		
		List<Content__c> contentList = MockupFactory.createContent('Banner', clusterRootList[0], 1);

		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

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
	static void getContentFromParentContentTest(){
		// Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a una Category__c

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Related News', 1, clusterRootList[0]);
		Component__c comp = componentList[0];
		comp.Datasource__c='ParentContentTags';
		update comp;
		componentList = [SELECT Name, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c
				FROM Component__c WHERE Id =: comp.ID];

		List<Category__c> categoryList = MockupFactory.createCategory('Test2', 1, clusterRootList[0].Id);
		List<CategoryAssignment__c> categoryAssignmentList = MockupFactory.createCategoryAssignment(categoryList, componentList);	
		List<Content__c> contentList = MockupFactory.createContent('Event', clusterRootList[0], 1);

		set<String> fieldSet =  new set<String>{'ExternalId__c'};
		set<String> setClusterIds = new set<String>{clusterRootList[0].Id};
		
		List<Content__c> contentListExclude = MockupFactory.createContent('Banner', clusterRootList[0], 1);
		set<String> setContentToExclude= new set<String>{contentListExclude[0].Id};

		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentList, mediaElementList);

		// When
		Test.startTest();
		ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, null, setContentToExclude, setClusterIds, 'Desktop');
		Test.stopTest();
		// Then
		
		System.assertNotEquals(cw, null);
	}

	@isTest
	static void getSetContextDirectTest(){
		// Comment: dado un Component__c y un Cluster__c devuelve el componente correspondiente asignado a una Category__c

		// Given
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot');
		List<Component__c> componentList = MockupFactory.createComponent('Banner', 1, clusterRootList[0]);
		Component__c comp = componentList[0];
		componentList = [SELECT Name, ExternalId__c, Datasource__c, Status__c, RecordTypeId, RecordType.DeveloperName, Cluster__c, ExcludePastEvents__c, OrderBy__c, HierarchicalOrderBy__c, PageSize__c
				FROM Component__c WHERE Id =: comp.ID];
		set<String> fieldSet =  new set<String>{'ExternalId__c'};
		set<String> setClusterIds = new set<String>{clusterRootList[0].Id};
		
		List<Content__c> contentListDirect = MockupFactory.createContent('Banner', clusterRootList[0], 1);
		set<String> setContentDirect= new set<String>{contentListDirect[0].Id};

		List<MediaElement__c> mediaElementList = MockupFactory.createMediaElement(1);
		List<MediaElementAssignment__c> mediaElementAssigList = MockupFactory.createMediaElementAssignment(contentListDirect, mediaElementList);

		// When
		Test.startTest();
		ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(componentList[0], fieldSet, setContentDirect, null, setClusterIds, 'Desktop');
		Test.stopTest();
		// Then
		
		System.assertNotEquals(cw, null);
	}

}