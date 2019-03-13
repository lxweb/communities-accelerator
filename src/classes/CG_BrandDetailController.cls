public with sharing class CG_BrandDetailController {

    public class BrandDetailWrapper{
        @auraEnabled public Component__c component;
        @auraEnabled public String description;
        @auraEnabled public String title;
        @auraEnabled public String imageLogoURL;
        @auraEnabled public String imageBannerURL;
        @auraEnabled public boolean isVariant;
        @auraEnabled public boolean showContent;
        @auraEnabled public list<VariantWrapper> variants;
        public BrandDetailWrapper(){
            variants = new list<VariantWrapper>();
        }
    }

    public class VariantWrapper{
        @auraEnabled public String imageURL;
        @auraEnabled public String title;
        @auraEnabled public String id;
    }

    @auraEnabled
    public static BrandDetailWrapper getBrandWrapper(String brandId, String componentExternalId){
        BrandDetailWrapper bw = new BrandDetailWrapper();

        if(componentExternalId != null && componentExternalId != ''){
            bw.component = [SELECT Id, LinkDetail__r.URL__c FROM Component__c WHERE ExternalId__c =: componentExternalId];
        }

        if(brandId != null && brandId != '')
        {   
            bw.showContent = true;

            Brand__c brand = [SELECT Id, Name, BrandContent__c, BrandContent__r.Description__c, BrandContent__r.Title__c, MasterBrand__c, RecordType.DeveloperName, Description__c FROM Brand__c WHERE id = :brandId];
            if(brand.RecordType.DeveloperName == 'BrandVariant'){
                bw.isVariant = true;
                bw.description = brand.BrandContent__r.Description__c;
                bw.title = brand.BrandContent__r.Title__c;
            }

            if(brand.RecordType.DeveloperName == 'Brand'){
                bw.isVariant = false;
                bw.description = brand.BrandContent__r.Description__c;
                // GET BANNER URL AND LOGO URL
                list<MediaElementAssignment__c> brandContent = [SELECT MediaElement__r.FileURLDesktop__c, Placement__c  FROM MediaElementAssignment__c WHERE Content__c = :brand.BrandContent__c];
                for(MediaElementAssignment__c mediaElement : brandContent){
                    if(mediaElement.Placement__c == 'BrandImageBanner'){
                        bw.imageBannerURL = mediaElement.MediaElement__r.FileURLDesktop__c;
                    }
                    if(mediaElement.Placement__c == 'BrandImageLogo'){
                        bw.imageLogoURL = mediaElement.MediaElement__r.FileURLDesktop__c;
                    }
                }
                // GET THE RELATEDS 4 BRANDS
                list<Brand__c> relatedBrands = [SELECT Id, Name, BrandContent__c, BrandContent__r.Title__c FROM Brand__c WHERE MasterBrand__c =: brand.Id AND RecordType.DeveloperName = 'BrandVariant' ORDER BY LastModifiedDate DESC LIMIT 4];
                set<String> relatedBrandsContents = new set<String>();
                for (Brand__c rb : relatedBrands){
                    relatedBrandsContents.add(rb.BrandContent__c);
                }
                list<MediaElementAssignment__c> relatedContent = [SELECT MediaElement__r.FileURLDesktop__c, Content__c  FROM MediaElementAssignment__c WHERE Content__c IN: relatedBrandsContents];
                set<VariantWrapper> variants = new set<VariantWrapper>();
                for(Brand__c b : relatedBrands){
                    VariantWrapper vw = new VariantWrapper();
                    for(MediaElementAssignment__c content : relatedContent){
                        if(b.BrandContent__c == content.Content__c){
                            vw.title = b.BrandContent__r.Title__c;
                            vw.imageURL = content.MediaElement__r.FileURLDesktop__c;
                            vw.id = b.Id;
                            if(variants.size() < 4){
                                variants.add(vw);
                            }
                        }
                    }
                }
                if(variants != null){
                    bw.variants.addAll(variants);
                }
            }
        }
        else{
            bw.showContent=false;
        }
        return bw;
    }

}