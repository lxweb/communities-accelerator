({	
	doInit : function(component, event, helper){
        var layoutOptions = [
			{value:"Title Top", imageUrl:"/ContentLayouts/News-Layouts/TitleTop.png", label:$A.get("$Label.c.NewsContentDetailTitleTop")},
			{value:"Title Middle", imageUrl:"/ContentLayouts/News-Layouts/TitleMiddle.png", label:$A.get("$Label.c.NewsContentDetailTitleMiddle")},
			{value:"Title Bottom", imageUrl:"/ContentLayouts/News-Layouts/TitleBottom.png", label:$A.get("$Label.c.NewsContentDetailTitleBottom")}
		];
		component.set('v.layoutOptions', layoutOptions);
        component.set('v.contentData.Layout__c', component.get('v.contentData.Layout__c') == null ? 'Title Top' : component.get('v.contentData.Layout__c')); 
	}
})