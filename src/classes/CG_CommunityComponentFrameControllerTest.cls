@isTest
private class CG_CommunityComponentFrameControllerTest
{
	@isTest
	static void getContentRecordtypeId()
	{
		// Given


		// When
		CG_CommunityComponentFrameController.ContentRecordTypeWrapper crtw = CG_CommunityComponentFrameController.getContentRecordtypeId('RelatedNews');



		// Then
		System.assert(crtw.haveContentRecordType);

	}
}