import { LightningElement, wire, track } from 'lwc';
import getFilters from	'@salesforce/apex/ContentSearchFiltersController.getFilters';
import ContentLandingAll from '@salesforce/label/c.ContentLandingAll';
import ContentLandingCluster from '@salesforce/label/c.ContentLandingCluster';
import ContentLandingCategory from '@salesforce/label/c.ContentLandingCategory';
import ContentLandingTags from '@salesforce/label/c.ContentLandingTags';
import { CurrentPageReference } from 'lightning/navigation';

export default class NewNewsContainer extends LightningElement {
    
    @track renderHeader;
    @track renderFilterSidebar;
    @track renderTable;
    @track haveFilterSidebar;
    @track haveObjectLabel;
    @track haveFilterStatus;
    @track haveTableData;
    randomObject = {
        string: 'asd'
    }
    

    //TODO DELETE Mock Data
    buttonArraySecondary = [
        {label: "hola", disabled: false},
        {label: "chau", disabled: false},
    ];
    buttonArrayPrimary = [
        {label: "hola", disabled: false},
        {label: "chau", disabled: false},
    ];
    breadcrumbs = [
        "news1",
        "news2",
        "news3"
    ]

    //TODO DELETE Mock Data {id: number, title: string, subtitle: string, iconName: option<string>}
    items = [
        {
            id: 1,
            title: 'Sebas',
            subtitle: 'Hola',
            iconName: 'action:approval'
        },
        {
            id: 2,
            title: 'Sebas',
            subtitle: 'Hola',
            iconName: 'action:approval'
        },
        {
            id: 3,
            title: 'Sebas',
            subtitle: 'Hola',
        },
        {
            id: 4,
            title: 'Sebas',
            subtitle: 'Hola',
            iconName: 'action:approval'
        },
    ];
    

    //Reference used for the pubsub module
    @wire(CurrentPageReference) pageRef;

    label = {
        ContentLandingAll,
        ContentLandingCluster,
        ContentLandingCategory,
        ContentLandingTags,
    };

    constructor() {
        super();
        this.filtersValues = 
        [ 
            {"label": this.label.ContentLandingCluster, "value": null},
            {"label": this.label.ContentLandingCategory, "value": null},
            {"label": this.label.ContentLandingTags, "value": null},
        ];
    }

    @wire(getFilters, { sObjectType: '$objectApiName' })
    wiredFilters({ error, data }) {
        if (error) {
            this.filters = null
            this.haveFilterSidebar = false;
            this.setRenderFilterSidebar();
        } else if (data) {
            this.filters = data.filters;
            this.haveFilterSidebar = true;
            this.adaptDataFilters();
            this.setRenderFilterSidebar();
        }
    }

    setRenderHeader(){
        this.renderHeader = this.haveFilterStatus && this.haveObjectLabel;
    }

    setRenderFilterSidebar(){
        this.renderFilterSidebar = this.haveFilterSidebar;
    }

    adaptDataFilters(){
        var filterNone = this.filters.map(element => {
            var a;
            a = Object.assign({}, element);
            a.values = a.values.slice();
            if(!a.isMultiPicklist){
                a.values.unshift(
                    {"id": "bananas", "isSelected": false, "label": "bananas"}
                );
            }
            return a;
        });
        this.filters = filterNone;
    }

    handleTabChange(event) {
        console.log(event);
    }

}