@isTest
public with sharing class ContentDetailControllerTest {

    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf');
		MockupFactory.createCategory('Category', 2, clusterLeaf.get(0).id);
		MockupFactory.createClusterUser(clusterRoot.get(0).id, UserInfo.getUserId(), 1, 'Read/Write');
        MockupFactory.createTag('Tag Name', '', 2, clusterLeaf.get(0).id);
        MockupFactory.createContent('Event', clusterLeaf.get(0), 3);
        MockupFactory.createMediaElement(1);
	}

    @isTest 
	static void getDataExistingTest(){
        //Given
        MediaElement__c me = [SELECT id FROM MediaElement__c LIMIT 1];
        Content__c content = [SELECT id FROM Content__c LIMIT 1];
        Tag__c tag = [SELECT id FROM Tag__c LIMIT 1];
        insert new MediaElementAssignment__c(Content__c = content.id, MediaElement__c = me.id);
        insert new TagAssignment__c(Content__c = content.id, Tag__c = tag.id);
        ContentDetailController.DataWrapper dataWrapper= ContentDetailController.getDataExisting(content.Id);
        //When
        Content__c saveSuccess = ContentDetailController.saveContent(dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), me.id, 'Publish', dataWrapper.content.Tags__r);
        //Then
        system.assert(saveSuccess != null);

    }

    @isTest 
	static void getDataNewTest(){
        //Given
        RecordType rt = [SELECT id FROM RecordType WHERE sObjectType = 'Content__c' AND developerName = 'News'];
        ContentDetailController.DataWrapper dataWrapper= ContentDetailController.getDataNew(rt.Id);
        dataWrapper.content.listTitle__c = 'testName';
        //When
        Content__c saveSuccess = ContentDetailController.saveContent(dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), null, 'Publish', dataWrapper.content.Tags__r);
        //Then
        system.assert(saveSuccess.id != null);

    }
}