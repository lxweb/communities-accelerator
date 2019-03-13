({	
	doInit : function(component, event, helper){
		var layoutOptions = [
			{value:"Middle-Left", imageUrl:"/ContentLayouts/OverlayQuadrant__c/Middle-Left.png", label:$A.get("$Label.c.BannerContentDetailLeftAlign")},
			{value:"Middle-Center", imageUrl:"/ContentLayouts/OverlayQuadrant__c/Middle-Center.png", label:$A.get("$Label.c.BannerContentDetailMiddleAlign")},
			{value:"Middle-Right", imageUrl:"/ContentLayouts/OverlayQuadrant__c/Middle-Right.png", label:$A.get("$Label.c.BannerContentDetailRightAlign")}
		];
		component.set('v.layoutOptions', layoutOptions);
	}
})