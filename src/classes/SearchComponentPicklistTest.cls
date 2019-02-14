@isTest
public class SearchComponentPicklistTest {
	@isTest
    static void getValues(){
        SearchComponentPicklist scp = new SearchComponentPicklist();
        scp.getDefaultValue();
        scp.getValues();
        
        MockupFactory.createComponent('Search',1);
        
        SearchComponentPicklist scp2 = new SearchComponentPicklist();
        scp2.getDefaultValue();
        scp2.getValues();
    }
}