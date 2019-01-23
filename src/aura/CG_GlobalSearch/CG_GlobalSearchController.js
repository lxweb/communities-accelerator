({
	handleKeyUp: function (cmp, evt, helper) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search').get('v.value');
            helper.getSearchResults(cmp, queryTerm);
        }
    }
})