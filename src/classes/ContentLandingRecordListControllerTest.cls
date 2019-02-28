@isTest
public class ContentLandingRecordListControllerTest {

	@isTest
	public static void testDefaultCondition(){
		
		//Given
		MockupFactory.generateAcceleratorSetting();
		Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot')[0];
		Content__c bannerTest = MockupFactory.createContent('Banner', clusterTest, 1)[0];
		Content__c newsTest = MockupFactory.createContent('News', clusterTest, 1)[0];

		//When
		ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, null);

		//Then
		System.assertEquals(2, tableWrapperTest.contentWrappers.size());
	}

	@isTest
	public static void testCustomCondition(){
		
		//Given
		MockupFactory.generateAcceleratorSetting();
		Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot')[0];
		List<Content__c> contents = MockupFactory.createContent('Banner', clusterTest, 2);
		Content__c bannerTest1 = contents[0];
		Content__c bannerTest2 = contents[1];
        String bannerRecordTypeId = bannerTest1.RecordTypeId;
		Category__c categoryTest = MockupFactory.createCategory('CategoryTest', 1, clusterTest.Id)[0];
		Tag__c TagTest1 = MockupFactory.createTag('TagTest1', 'DescriptionTest', 1, clusterTest.Id)[0];
		Tag__c TagTest2 = MockupFactory.createTag('TagTest2', 'DescriptionTest', 1, clusterTest.Id)[0];
		Component__c componentTest = MockupFactory.createComponent('Banner', 1)[0];
		bannerTest1.Category__c = categoryTest.Id; bannerTest1.Status__c = 'Draft'; update bannerTest1;
		bannerTest2.Category__c = categoryTest.Id; bannerTest1.Status__c = 'Draft'; update bannerTest2;
		insert new TagAssignment__c(Component__c = componentTest.Id, Content__c = bannerTest1.Id, Tag__c = TagTest1.Id);
		insert new TagAssignment__c(Component__c = componentTest.Id, Content__c = bannerTest1.Id, Tag__c = TagTest2.Id);
		insert new TagAssignment__c(Component__c = componentTest.Id, Content__c = bannerTest2.Id, Tag__c = TagTest2.Id);

		//When
		ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(bannerRecordTypeId, clusterTest.Id, categoryTest.Id, new List<String>{TagTest1.Id, TagTest2.Id}, 'Draft', null);

		//Then
		System.assertEquals(1, tableWrapperTest.contentWrappers.size());
		System.assertEquals('Banner 0', tableWrapperTest.contentWrappers[0].fieldWrappers[1].value);
	}

	@isTest
	public static void testSearch(){

		//Given
		MockupFactory.generateAcceleratorSetting();
		Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot')[0];
		Content__c bannerTest = MockupFactory.createContent('Banner', clusterTest, 1)[0]; bannerTest.Status__c = 'Draft'; 
		Content__c newsTest = MockupFactory.createContent('News', clusterTest, 1)[0]; newsTest.Status__c = 'Draft';

		//When
		ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, 'Banner');
		
		//Then
		System.assertEquals(1, tableWrapperTest.contentWrappers.size());		
		System.assertEquals('Banner 0', tableWrapperTest.contentWrappers[0].fieldWrappers[1].value);
	}

	@isTest
	public static void testEmpty(){

		//Given
		MockupFactory.generateAcceleratorSetting();
		Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot')[0];
		Content__c bannerTest = MockupFactory.createContent('Banner', clusterTest, 1)[0]; bannerTest.Status__c = 'Draft'; 
		Content__c newsTest = MockupFactory.createContent('News', clusterTest, 1)[0]; newsTest.Status__c = 'Draft';

		//When
		ContentLandingRecordListController.TableWrapper tableWrapperTest = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, 'String Inexistente');
		
		//Then	
		System.assertEquals(True, tableWrapperTest.title.contains('No records'));
	}

	@isTest
	public static void testJSON(){

		//Given
		MockupFactory.generateAcceleratorSetting();
		Cluster__c clusterTest = MockupFactory.createCluster('ClusterTest', null, 1, 'ClusterRoot')[0];
		Content__c bannerTest = MockupFactory.createContent('Banner', clusterTest, 1)[0]; bannerTest.Status__c = 'Draft'; 
		Content__c newsTest = MockupFactory.createContent('News', clusterTest, 1)[0]; newsTest.Status__c = 'Draft';

		//When
		ContentLandingRecordListController.TableWrapper tableWrapperTest1 = ContentLandingRecordListController.buildTableWrapper(null, null, null, null, null, null);
		String tableWrapperJSON = ContentLandingRecordListController.getTableWrapper(null, null, null, null, null, null);
		ContentLandingRecordListController.TableWrapper tableWrapperTest2 = (ContentLandingRecordListController.TableWrapper) JSON.deserialize(tableWrapperJSON, ContentLandingRecordListController.TableWrapper.class);

		//Then
		System.debug(tableWrapperTest1.contentWrappers +' '+ tableWrapperTest2.contentWrappers);
		System.assertEquals(True, tableWrapperTest1.title == tableWrapperTest2.title);
		System.assertEquals(True, tableWrapperTest1.columnSet == tableWrapperTest2.columnSet);
	}
}