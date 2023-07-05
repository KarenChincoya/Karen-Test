import { LightningElement, api } from 'lwc';

export default class KtResult extends LightningElement {
    @api result;

    @api reload(result) {
        this.result = result;
    }

}