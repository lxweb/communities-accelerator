public class RichTextController {

    public static String replaceExternalIdsWithURLs(String richText, Map<String, String> externalIdUrlMap){
        if(richText.contains('@ME:')){
            String externalId = richText.substringBetween('@ME:', '@');
            String toReplace = '@ME:' + externalId + '@';
            String mediaElementURL = externalIdUrlMap.get(toReplace);
            richText = richText.replace(toReplace, mediaElementURL);
            replaceExternalIdsWithURLs(richText.substringAfter(mediaElementURL), externalIdUrlMap);
        }

        return richText;
    }

    public static Map<String, String> getMediaElementURLs(List<String> mediaElementExternalIds){
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

}