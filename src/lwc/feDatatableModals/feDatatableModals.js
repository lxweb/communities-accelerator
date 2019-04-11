import { LightningElement, api, track } from 'lwc';

export default class FeDatatableModals extends LightningElement {
    @api table;
    @api row;
    @api closeicon;
    @api rowkey;
    @api type;
    @api rowaction;

    @track rowData = [];
    @track actionmodal;
    @track detailmodal;

    renderedCallback() {
        if (this.type === "detailModal" && this.rowData.length === 0) {
            this.dataDetailModal();
        }
        if (this.type) {
            this.modal();
        } 
    }

    modal() {
        if (this.type === "detailModal") {
            this.actionmodal = false;
            this.detailmodal = true;
        } else if (this.type === "actionModal") {
            this.actionmodal = true;
            this.detailmodal = false;
        }
    }
        
    dataDetailModal() {
        var row = JSON.parse(JSON.stringify(this.row)).find(r => r.key === parseInt(this.rowkey, 0));
        var data;
        this.table.columns.forEach(col => {
            let rowValue = row.row[col.fieldName];
            if (!row.row[col.fieldName]) {
                rowValue = "-"
            }
            data = {    column: col.label, 
                        row: rowValue }
            this.rowData.push(data);
        });
    }

    closeDetailModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    // closeActionModal() {
    //     this.dispatchEvent(new CustomEvent('close'));
    // }
}