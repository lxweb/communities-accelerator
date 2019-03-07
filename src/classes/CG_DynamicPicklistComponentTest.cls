@isTest
public class CG_DynamicPicklistComponentTest {
	@isTest 
	static void setValuesInpicklist(){
	//When
	List<Component__c> componentList = MockupFactory.createComponent('Banner',2);

	//Then
	Test.startTest();
	CG_DynamicPicklistComponent picklistValues = new CG_DynamicPicklistComponent();
	picklistValues.getDefaultValue();
	picklistValues.getValues();
	Test.stopTest();
	
	}
}