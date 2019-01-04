/********************************************************************
* Company: Fielo
* Developer: Waldemar Mayo
* Created Date: 14/12/2016
* Description: 
********************************************************************/

@isTest
public without sharing class TranslationUtilsTest{
    
    @isTest
    static void unitTest1(){
        /*Comment: Comprueba que dado un Objeto con traducciones en campos especificos, esas traducciones son mostradas correctamente
        y en el caso de que el campo no exista, se muestre un error.*/
        
        //Given
        Translation__c tra1 = new Translation__c(
            Name = UserInfo.getUserId() + ' - EN - FirstName',
            FieldType__c = 'Text',
            LanguageCode__c = 'en_US',
            FieldApiName__c = 'FirstName',
            TranslationText__c = 'Test');
        insert tra1;
        Translation__c tra2 = new Translation__c(
            Name = UserInfo.getUserId() + ' - EN - FirstName2',
            FieldType__c = 'TextArea',
            LanguageCode__c = 'en_US',
            FieldApiName__c = 'FirstName',
            TranslationTextArea__c = 'Test');
        insert tra2;
        Translation__c tra3 = new Translation__c(
            Name = UserInfo.getUserId() + ' - EN - FirstName3',
            FieldType__c = 'Email',
            LanguageCode__c = 'en_US',
            FieldApiName__c = 'FirstName',
            TranslationEmail__c = 'test@test.com');
        insert tra3;
        Translation__c tra4 = new Translation__c(
            Name = UserInfo.getUserId() + ' - EN - FirstName4',
            FieldType__c = 'URL',
            LanguageCode__c = 'en_US',
            FieldApiName__c = 'FirstName',
            TranslationURL__c = 'Test');
        insert tra4;
        Translation__c tra5 = new Translation__c(
            Name = UserInfo.getUserId() + ' - EN - FailField',
            FieldType__c = 'URL',
            LanguageCode__c = 'en_US',
            FieldApiName__c = 'FailField',
            TranslationURL__c = 'Test');
        insert tra5;
        
        User us = [SELECT Id, FirstName, Name FROM User WHERE Id =: UserInfo.getUserId()];

        //When
        Test.startTest();
        Map<String, String> testWithRecord = TranslationUtils.getTranslated(us, 'en_US', 'OwnerId');
        Map<String, String> testWithList = TranslationUtils.getTranslated(new List<User>{us}, 'en_US', 'OwnerId');
        Test.stopTest();


        //Then
        System.assertEquals(testWithRecord.get('FirstName'), 'Test');
        System.assertEquals(testWithList.get('FirstName'), 'Test');
        System.assertEquals(testWithRecord.get('FirstName-'+tra2.Id), 'Test');
        System.assertEquals(testWithList.get('FirstName-'+tra2.Id), 'Test');
        System.assertEquals(testWithRecord.get('FirstName-'+ tra3.Id), 'test@test.com');
        System.assertEquals(testWithList.get('FirstName-'+ tra3.Id), 'test@test.com');
        //System.assertEquals(testWithRecord.get('FirstName-' + tra4.Id), 'Test');
        System.assertEquals(testWithList.get('FirstName-' + tra4.Id), 'Test');
        System.assertEquals(testWithRecord.get('FailField-' + tra5.Id).contains('ERROR'), true);


    }
}