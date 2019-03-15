@isTest
public with sharing class ContentDetailControllerTest {

    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
		List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot');
        List<Cluster__c> clusterGroup = MockupFactory.createCluster('Cluster Group', clusterRoot.get(0).id, 1, 'ClusterGroup');
        List<Cluster__c> clusterLeaf = MockupFactory.createCluster('Cluster Leaf', clusterGroup.get(0).id, 2, 'ClusterLeaf');
        MockupFactory.createComponent('FAQ', 1, clusterRoot.get(0));
		MockupFactory.createComponent('News', 1, clusterRoot.get(0));
		MockupFactory.createClusterUser(clusterRoot.get(0).id, UserInfo.getUserId(), 1, 'Read/Write');
        List<Tag__c> tags = MockupFactory.createTag('Tag Name', '', 2, clusterLeaf.get(0).id);
		List<Category__c> categories = MockupFactory.createCategory('Category', 2, clusterLeaf.get(0).id);
        MockupFactory.createContent('FAQ', clusterLeaf.get(0), 3);
        MockupFactory.createMediaElement(1);       
        
        List<Component__c> components = [SELECT id FROM Component__c ORDER BY Name ASC];
        components.get(0).DataSource__c = 'TagsCategories';
        components.get(1).DataSource__c = 'ManualAssignment';
        
        List<Content__c> contents = [SELECT id FROM Content__c];
        MockupFactory.createTagAssignment(tags, components, contents);
        MockupFactory.createCategoryAssignment(categories, components);
        update components;
	}

    @isTest 
	static void getDataExistingTest(){
        //Given
        Component__c component = [SELECT id FROM Component__c LIMIT 1];
        MediaElement__c me = [SELECT id FROM MediaElement__c LIMIT 1];
        Content__c content = [SELECT id FROM Content__c LIMIT 1];
        Tag__c tag = [SELECT id FROM Tag__c LIMIT 1];
        insert new MediaElementAssignment__c(Content__c = content.id, MediaElement__c = me.id);
        insert new TagAssignment__c(Content__c = content.id, Tag__c = tag.id);
        ContentDetailController.DataWrapper dataWrapper= ContentDetailController.getDataExisting(content.Id);
        //When
        Content__c saveSuccess = ContentDetailController.saveContent(component.Id, dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), me.id, 'Publish', dataWrapper.content.Tags__r);
        //Then
        system.assert(saveSuccess != null);

    }

    @isTest 
	static void getDataNewTest(){
        //Given
        Component__c component = [SELECT id FROM Component__c LIMIT 1];
        RecordType rt = [SELECT id FROM RecordType WHERE sObjectType = 'Content__c' AND developerName = 'News'];
        ContentDetailController.DataWrapper dataWrapper=  ContentDetailController.getDataNew(rt.Id, component.Id);
        dataWrapper.content.Title__c = 'testName';
        //When
        Content__c saveSuccess = ContentDetailController.saveContent(component.Id, dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), null, 'Publish', dataWrapper.content.Tags__r);
        //Then
        system.assert(saveSuccess.id != null);

    }
    
    @isTest 
	static void ComponentBehaviourTest(){
        //Given
        Component__c component = [SELECT id FROM Component__c LIMIT 1];
        RecordType rt = [SELECT id FROM RecordType WHERE sObjectType = 'Content__c' AND developerName = 'FAQ'];
        ContentDetailController.DataWrapper dataWrapper= ContentDetailController.getDataNew(rt.Id, component.Id);
        dataWrapper.content.Title__c = 'testName';
        //When
        Content__c saveSuccess = ContentDetailController.saveContent(component.Id, dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), null, 'Publish', dataWrapper.content.Tags__r);
        //Then
        system.assert(saveSuccess.id != null);
    }
        
    @isTest 
	static void ContentAssignmentTest(){
        //Given
        Component__c component = [SELECT id FROM Component__c LIMIT 1];
        component.Datasource__c = 'ManualAssignment'; update component;
        RecordType rt = [SELECT id FROM RecordType WHERE sObjectType = 'Content__c' AND developerName = 'FAQ'];
        ContentDetailController.DataWrapper dataWrapper= ContentDetailController.getDataNew(rt.Id, component.Id);
        dataWrapper.content.Title__c = 'testName';
        //When
        Content__c saveSuccess = ContentDetailController.saveContent(component.Id, dataWrapper.content, JSON.serialize(dataWrapper.visibilitySelectors), null, 'Publish', dataWrapper.content.Tags__r);
        //Then        
        system.assert(saveSuccess.id != null);
        system.assert([SELECT count() FROM ContentAssignment__c] == 1);
    }
    
}