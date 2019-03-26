@isTest
public class RichTextControllerTest {

    @isTest
    public static void testReplace(){

        // Given
        List<MediaElement__c> mediaElements = MockupFactory.createMediaElement(8);
        mediaElements.get(0).ExternalId__c = '123'; mediaElements.get(0).FileURLDesktop__c = 'www.123';
        mediaElements.get(1).ExternalId__c = '456'; mediaElements.get(1).FileURLDesktop__c = 'www.456';
        mediaElements.get(2).ExternalId__c = '789'; mediaElements.get(2).FileURLDesktop__c = 'www.789';
        mediaElements.get(3).ExternalId__c = '100'; mediaElements.get(3).FileURLDesktop__c = 'www.100';
        mediaElements.get(4).ExternalId__c = 'ABC'; mediaElements.get(4).FileURLDesktop__c = 'www.ABC';
        mediaElements.get(5).ExternalId__c = 'DEF'; mediaElements.get(5).FileURLDesktop__c = 'www.DEF';
        mediaElements.get(6).ExternalId__c = 'GHI'; mediaElements.get(6).FileURLDesktop__c = 'www.GHI';
        mediaElements.get(7).ExternalId__c = 'JKL'; mediaElements.get(7).FileURLDesktop__c = 'www.JKL';
        update MediaElements;
        String richTextExternalIds = '<img src="@ME:123@">-<img src="@ME:456@">-<img src="@ME:789@">-<img src="@ME:100@">-'
            					   + '<img src="@ME:ABC@">-<img src="@ME:DEF@">-<img src="@ME:GHI@">-<img src="@ME:JKL@">-';
        
        // When
        List<String> mediaElementExternalIds = RichTextController.getMediaElementExternalIds(new List<String>{richTextExternalIds});
        Map<String, String> externalIdURLMap = RichTextController.getExternalIdURLMap(mediaElementExternalIds);
        String richTextURLs = RichTextController.replaceExternalIdsWithURLs(richTextExternalIds, externalIdURLMap);

        List<String> mediaElementURLs = RichTextController.getMediaElementURLs(new List<String>{richTextURLs});
        Map<String, String> urlExternalIdMap = RichTextController.getURLExternalIdMap(mediaElementURLs);
        String richTextFinal = RichTextController.replaceURLsWithExternalIds(richTextURLs, urlExternalIdMap);
        
        // Then
        System.assertEquals(richTextExternalIds, richTextFinal);
    }

    
    @isTest
    public static void testGetMediaElementExternalIds(){
        // Given
        String richText1 = '<img src="@ME:123@">-<img src="@ME:456@">-<img src="@ME:789@">-<img src="@ME:100@">-';
        String richTextA = '<img src="@ME:ABC@">-<img src="@ME:DEF@">-<img src="@ME:GHI@">-<img src="@ME:JKL@">-';
        List<String> richTexts = new List<String>{richText1, richTextA};
        // When    
        List<String> mediaElementExternalIds = RichTextController.getMediaElementExternalIds(richTexts);
        // Then
        List<String> expected = new List<String>{'123', '456', '789', '100', 'ABC', 'DEF', 'GHI', 'JKL'};
        System.assertEquals(expected, mediaElementExternalIds);
    }
    
    @isTest
    public static void testGetMediaElementURLs(){
        // Given
        String richText1 = '<img src="www.123">-<img src="www.456">-<img src="www.789">-<img src="www.100">-';
        String richTextA = '<img src="www.ABC">-<img src="www.DEF">-<img src="www.GHI">-<img src="www.JKL">-';
        List<String> richTexts = new List<String>{richText1, richTextA};
        // When
        List<String> mediaElementURLs = RichTextController.getMediaElementURLs(richTexts);
        // Then
        List<String> expected = new List<String>{'www.123', 'www.456', 'www.789', 'www.100', 'www.ABC', 'www.DEF', 'www.GHI', 'www.JKL'};
        System.assertEquals(expected, mediaElementURLs);
    }
    
}