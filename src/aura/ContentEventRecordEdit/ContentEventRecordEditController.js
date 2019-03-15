({	
	doInit : function(component, event, helper){
        var layoutOptions = [
			{value:"Title Top", imageUrl:"/ContentLayouts/Event-Layouts/TitleTop.png", label:$A.get("$Label.c.EventContentDetailTitleTop")},
			{value:"Title Middle", imageUrl:"/ContentLayouts/Event-Layouts/TitleMiddle.png", label:$A.get("$Label.c.EventContentDetailTitleMiddle")},
			{value:"Title Bottom", imageUrl:"/ContentLayouts/Event-Layouts/TitleBottom.png", label:$A.get("$Label.c.EventContentDetailTitleBottom")}
		];
		component.set('v.layoutOptions', layoutOptions);
        component.set('v.contentData.Layout__c', component.get('v.contentData.Layout__c') == null ? 'Title Top' : component.get('v.contentData.Layout__c')); 
	}
})