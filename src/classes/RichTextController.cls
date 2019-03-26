public class RichTextController {

    // From ExternalIds To URLs

    public static String replaceExternalIdsWithURLs(String richText, Map<String, String> externalIdUrlMap){
        // Replaces External Ids in tags @ME:@ with URLs
        if(richText.contains('@ME:')){
            String externalId = richText.substringBetween('@ME:', '@');
            String toReplace = '@ME:' + externalId + '@';
            String mediaElementURL = externalIdUrlMap.get(externalId);
            richText = richText.replace(toReplace, mediaElementURL);
            return replaceExternalIdsWithURLs(richText, externalIdUrlMap);
        } else {
            return richText;
        }        
    }

    public static Map<String, String> getExternalIdURLMap(List<String> mediaElementExternalIds){
        Map<String, String> mapToReturn = new Map<String, String>();
        List<MediaElement__c> mediaElements = [SELECT Id, ExternalId__c, FileURLDesktop__c FROM MediaElement__c WHERE ExternalId__c IN: mediaElementExternalIds];
        for(MediaElement__c mediaElement : mediaElements){
            mapToReturn.put(mediaElement.ExternalId__c, mediaElement.FileURLDesktop__c);
        }

        return mapToReturn;
    }

    public static List<String> getMediaElementExternalIds(List<String> richTexts){
        Set<String> externalIds = new Set<String>();
        for(String richText : richTexts){
            externalIds.addAll(getExternalIdsFromRichText(richText, externalIds));
        }
        
        List<String> toReturn = new List<String>(externalIds);
        return toReturn;
    }

    private static Set<String> getExternalIdsFromRichText(String richText, Set<String> externalIds){
        if(richText.contains('@ME:')){
            String externalId = richText.substringBetween('@ME:', '@');
            externalIds.add(externalId);
            getExternalIdsFromRichText(richText.substringAfter(externalId), externalIds);
        }

        return externalIds;
    }

    // From URLs To ExternalIds

    public static String replaceURLsWithExternalIds(String richText, Map<String, String> urlExternalIdMap){
        // Replaces URLs with External Ids in tags @ME:@ 
        String richTextTemp = richText.contains('@ME:') ? richText.substring(richText.lastIndexOf('@ME:') + 1) : richText;
        String url = richTextTemp.substringBetween('<img src="', '">');
        if(url != null){
            String mediaElementExternalId = '@ME:' + urlExternalIdMap.get(url) + '@';
            richText = richText.replace(url, mediaElementExternalId);
            return replaceURLsWithExternalIds(richText, urlExternalIdMap);
        } else {
            return richText;
        }  
    }

    public static Map<String, String> getURLExternalIdMap(List<String> mediaElementURLs){
        Map<String, String> mapToReturn = new Map<String, String>();
        List<MediaElement__c> mediaElements = [SELECT Id, ExternalId__c, FileURLDesktop__c FROM MediaElement__c WHERE FileURLDesktop__c IN: mediaElementURLs];
        for(MediaElement__c mediaElement : mediaElements){
            mapToReturn.put(mediaElement.FileURLDesktop__c, mediaElement.ExternalId__c);
        }

        return mapToReturn;
    }

    public static List<String> getMediaElementURLs(List<String> richTexts){
        Set<String> urls = new Set<String>();
        for(String richText : richTexts){
            urls.addAll(getURLsFromRichText(richText, urls));
        }
        
        List<String> toReturn = new List<String>(urls);
        return toReturn;
    }

    private static Set<String> getURLsFromRichText(String richText, Set<String> urls){
        if(richText.contains('<img src="')){
            String url = richText.substringBetween('<img src="', '">');
            urls.add(url);
            getURLsFromRichText(richText.substringAfter(url), urls);
        }

        return urls;
    }

}