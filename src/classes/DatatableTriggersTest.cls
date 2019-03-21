@isTest
private class DatatableTriggersTest {
    
	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}
	
    @isTest
    static void createValidDatatable() {
        
        Test.startTest();
        List<Cluster__c> clusters = MockUpFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot');
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 2, clusters.get(0).Id);
        
        System.assert(datatables.size() > 0);
        
        Test.stopTest();
    }
    
    @isTest
    static void updateValidDatatable() {
        
        Test.startTest();
        List<Cluster__c> clustersRoot = MockUpFactory.createCluster('DummyRootCluster', null, 1, 'ClusterRoot');
        List<Cluster__c> clustersLeaf = MockUpFactory.createCluster('DummyLeafCluster', clustersRoot.get(0).Id, 1, 'ClusterLeaf');
        
        Cluster__c leaf = clustersLeaf.get(0);
        
        List<Datatable__c> datatables = MockupFactory.createDatatables('DummyDatatable', 'DummyDatatable', 'Account', 2, leaf.Id);
        
        System.assert(datatables.size() > 0);
        
        Datatable__c a = datatables.get(0);
        a.Name = 'DummyDatatable2';
        a.Cluster__c = clustersRoot.get(0).Id;
        
        update a;
        
        a = datatables.get(0);
        a.Name = 'DummyDatatable2';
        a.Cluster__c = null;
        
        update a;
        
        Test.stopTest();
    }
    
    @isTest
    static void createInvalidDatatable() {
        
        Test.startTest();
        List<Cluster__c> clusters = MockUpFactory.createCluster('DummyCluster', null, 1, 'ClusterRoot');
        List<Datatable__c> datatables = new List<Datatable__c>();
        
        String name = 'DummyDatatable';
        
        Datatable__c datatable = new Datatable__c();
        datatable.Name = name;
        datatable.Cluster__c = clusters.get(0).Id;
        datatable.ExternalId__c = name;
        datatable.ObjectApiName__c = 'DummyObject';
        
        datatables.add(datatable);
        
        List<Database.SaveResult> results = Database.insert(datatables, false);
        
        Boolean hasError = false;
        
        System.assert(!results[0].isSuccess());
        
        Test.stopTest();
    }
}