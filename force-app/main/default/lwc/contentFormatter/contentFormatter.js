const formatContent = (content, type) => {
    let formatedContent;
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'Event') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId__c,
                type: type,
                headerText: content.content.EventStartDate__c,
                title: content.content.Title__c,
                bodyText: content.content.Extract__c,
                imgSrc: temp.FileURLDesktop__c,
                footer: {
                    description: {
                        descPrimary: content.content.Name,
                        descSecondary: content.content.Name,
                    },
                },
            };
        }
        else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId__c,
                headerText: null,
                title: content.content.Title__c,
                bodyText: content.content.Extract__c,
                imgSrc: temp.FileURLDesktop__c,
                footer: {
                    description: {
                        descPrimary: content.content.Name,
                        descSecondary: content.content.Name,
                    },
                },
            };
        }
    }
    return formatedContent;
}

const formatContentCompressed = (content, type) => {
    let formatedContent;
    let temp = content.mediaElements.length > 0 ? content.mediaElements[0] : {};
    if (content.content !== null && !formatedContent) {
        if (type === 'Event') {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId__c,
                type: type,
                headerText: content.content.EventStartDate__c.slice(0, 10),
                title: content.content.Title__c,
                imgSrc: temp.FileURLDesktop__c,
                description: content.content.Name
            };
        }
        else {
            formatedContent = {
                id: content.content.Id,
                externalId: content.content.ExternalId__c,
                type: type,
                headerText: null,
                title: content.content.Title__c,
                imgSrc: temp.FileURLDesktop__c,
                description: null
            };
        }
    }
    return formatedContent;
}

export {formatContent, formatContentCompressed};