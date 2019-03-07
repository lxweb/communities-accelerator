@isTest
private class CG_CommunityComponentFrameControllerTest
{
	@isTest
	static void getContentRecordtypeId()
	{
		// Given Exist a sObject with recordType RelatedNews


		// When
		test.startTest();
		CG_CommunityComponentFrameController.ContentRecordTypeWrapper crtw = CG_CommunityComponentFrameController.getContentRecordtypeId('RelatedNews');
		test.stopTest();


		// Then
		System.assert(crtw.haveContentRecordType);

	}
}