({	
	doInit : function(component, event, helper){
		var layoutOptions = [
			{value:"Middle-Left", imageUrl:"/ContentLayouts/Banner-OverlayQuadrant/Middle-Left.png", label:$A.get("$Label.c.BannerContentDetailLeftAlign")},
			{value:"Middle-Center", imageUrl:"/ContentLayouts/Banner-OverlayQuadrant/Middle-Center.png", label:$A.get("$Label.c.BannerContentDetailMiddleAlign")},
			{value:"Middle-Right", imageUrl:"/ContentLayouts/Banner-OverlayQuadrant/Middle-Right.png", label:$A.get("$Label.c.BannerContentDetailRightAlign")}
		];
		component.set('v.layoutOptions', layoutOptions);
		component.set('v.contentData.OverlayQuadrant__c', component.get('v.contentData.OverlayQuadrant__c') == null ? 'Middle-Left' : component.get('v.contentData.OverlayQuadrant__c'));
	}
})