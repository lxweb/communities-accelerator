@isTest
public class CommunityComponentPreviewControllerTest {
	@isTest static void getRecordTest(){
		/* Comment: Comprueba que dado un String correspondiente a un recordId de un componente, el método getRecord de la clase CommunityComponentPreview, retorne el
		componente representado por dado record Id. */

		//Given
		MockupFactory.createComponent('Banner', 1);
		Component__c testRecord = [SELECT Id, Name, ExternalId__c, RecordTypeId FROM Component__c LIMIT 1]; 
		System.debug('testRecord: ' + testRecord);
		
		//When
		Test.startTest();
        Component__c testComponent = CommunityComponentPreviewController.getRecord(String.valueOf(testRecord.Id));
		Test.stopTest();

		//Then
		System.assertEquals(testRecord.Id, testComponent.Id);
	}
    
    @isTest static void getClusterNameTest(){
		/* Comment: Comprueba que dado un String correspondiente a un recordId de un cluster, el método getClusterName de la clase CommunityComponentPreview, retorne el
		nombre de dicho cluster. */

		//Given
		MockupFactory.generateAcceleratorSetting();
		String clusterName = 'ClusterTest'; 
		Cluster__c clusterTest = MockupFactory.createCluster(clusterName, null, 3, 'ClusterRoot')[0];
		System.debug('clusterTest: ' + clusterTest);
		
		//When
		Test.startTest();
        String testName = CommunityComponentPreviewController.getClusterName(String.valueOf(clusterTest.Id));
		Test.stopTest();

		//Then
		System.assertEquals(testName, clusterTest.Name);
	}

}