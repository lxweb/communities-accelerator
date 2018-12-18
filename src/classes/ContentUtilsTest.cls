@isTest
public class ContentUtilsTest {
	@isTest
	static void TEST_CASE_01(){
		// Comment:

		// Given
		//MockupFactory.createRecords();
		Component__c comp = [SELECT id, RecordType.DeveloperName, Datasource__c, OrderBy__c, PageSize__c FROM Component__c WHERE ExternalId__c = 'BannerComponent_01' LIMIT 1];
		set<String> fieldSet =  new set<String>{'ExternalId__c'};

		// When
		Test.startTest();
		//ContentUtils.ContentWrapper cw = ContentUtils.getContentFromComponent(comp, fieldSet, null, null, 'Desktop');
		Test.stopTest();
		// Then
		//System.debug('Nahue: ' + cw);
	}
}