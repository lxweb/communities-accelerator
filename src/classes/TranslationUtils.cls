global with sharing class TranslationUtils{
    
    global static map<String, String> getTranslated(SObject record, String lang, String parentLookup){
        return getTranslated(new List<SObject>{record}, lang, parentLookup);
    }
    
    global static map<String, String> getTranslated(List<SObject> records, String lang, String parentLookup){
        map<Id, SObject> mapIdRecord = new map<Id, SObject>(records);
        map<String, String> retMap = new map<String, String>();
        set<Id> setIdRecords = mapIdRecord.keySet();
        
        for(Translation__c tra: Database.query('SELECT Id, Name, ' + parentLookup + ', FieldType__c, LanguageCode__c, FieldApiName__c, TranslationText__c, TranslationTextArea__c, TranslationEmail__c, TranslationURL__c, TranslationTextAreaRich__c FROM Translation__c WHERE ' + parentLookup + ' IN: setIdRecords AND LanguageCode__c =: lang ORDER BY FieldApiName__c')){
            SObject obj = mapIdRecord.get(String.ValueOf(tra.get(parentLookup)));

            try{
                if(tra.FieldType__c == 'Text' && obj.get(tra.FieldApiName__c) != null){
                    obj.put(tra.FieldApiName__c, tra.TranslationText__c);
                    retMap.put((retMap.containsKey(tra.FieldApiName__c) ? tra.FieldApiName__c + '-' + tra.Id : tra.FieldApiName__c), tra.TranslationText__c);
                }
                if(tra.FieldType__c == 'TextArea' && obj.get(tra.FieldApiName__c) != null){ 
                    System.debug('Text Area ' + obj.get(tra.FieldApiName__c));
                    obj.put(tra.FieldApiName__c, tra.TranslationTextArea__c);
                    retMap.put((retMap.containsKey(tra.FieldApiName__c) ? tra.FieldApiName__c + '-' + tra.Id : tra.FieldApiName__c), tra.TranslationTextArea__c);
                }
                if(tra.FieldType__c == 'Email' && obj.get(tra.FieldApiName__c) != null){
                    obj.put(tra.FieldApiName__c, tra.TranslationEmail__c);
                    retMap.put((retMap.containsKey(tra.FieldApiName__c) ? tra.FieldApiName__c + '-' + tra.Id : tra.FieldApiName__c), tra.TranslationEmail__c);
                }
                if(tra.FieldType__c == 'URL' && obj.get(tra.FieldApiName__c) != null){
                    System.debug('URL' + obj.get(String.ValueOf(tra.FieldApiName__c)));
                    obj.put(tra.FieldApiName__c, tra.TranslationURL__c);
                    retMap.put((retMap.containsKey(tra.FieldApiName__c) ? tra.FieldApiName__c + '-' + tra.Id : tra.FieldApiName__c), tra.TranslationURL__c);
                }
                if(tra.FieldType__c == 'TextAreaRich' && obj.get(tra.FieldApiName__c) != null){
                    obj.put(tra.FieldApiName__c, tra.TranslationTextAreaRich__c);
                    retMap.put((retMap.containsKey(tra.FieldApiName__c) ? tra.FieldApiName__c + '-' + tra.Id : tra.FieldApiName__c), tra.TranslationTextAreaRich__c);
                }
            }catch(Exception e){
                retMap.put(tra.FieldApiName__c + '-' + tra.Id, 'ERROR: ' + e.getMessage());
            }
        }
        return retMap;
    }
    
}