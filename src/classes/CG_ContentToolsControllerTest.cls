@isTest
private class CG_ContentToolsControllerTest {
	@testSetup
    static void setupTest(){
    	String nameRecordType = 'Banner';
    	MockupFactory.generateAcceleratorSetting();
        
        String name = 'Argentina';
        List<Cluster__c> clusterRootList = MockupFactory.createCluster(name, null, 1, 'ClusterRoot');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster(cg.Name, cg.Id, 1, 'ClusterGroup');

    	List<Component__c> componentList = MockupFactory.createComponent(nameRecordType, 1);
    	List<Content__c> contentList = MockupFactory.createContent(nameRecordType, clusterList[0], 1);
    	List<ContentAssignment__c> contentAssignmentList = MockupFactory.createContentAssignment(contentList, componentList);
    }

	@isTest 
	static void initDataTest() {
		Content__c cont = [SELECT id from Content__c where Cluster__c != null LIMIT 1];
		Test.startTest();
		CG_ContentToolsController.initData(cont.id);
		Test.stopTest();
		//System.assertNotEquals(rw, null);
	}
	
	@isTest 
	static void addToCartsTest() {
		Content__c cont = [SELECT id from Content__c where Cluster__c != null LIMIT 1];
		CG_ContentToolsController.ContentWrapper contentWr = CG_ContentToolsController.initData(cont.id);
		Test.startTest();
		CG_ContentToolsController.addToCarts(JSON.serialize(contentWr));
		Test.stopTest();
		//System.assertNotEquals(rw, null);
	}
}