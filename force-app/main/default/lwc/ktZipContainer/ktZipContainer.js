import { LightningElement, track } from 'lwc';
import getCountry from '@salesforce/apex/KT_ZipController.getCountry';

export default class KtZipContainer extends LightningElement {
    @track zipCode;
    @track result;
    @track isLoading = false;


    async handleSearch(event) {
        let zipCodeCmp = this.template.querySelector(".zip");
        this.zipCode = zipCodeCmp.value;
        console.log('ZIP CODE: '+this.zipCode);
        try {
            this.isLoading = true;
            this.result = await getCountry(this.zipCode);  
            console.log('result');
            console.log(this.result);    
        } catch (error) {
            console.error(error);
            this.result = "There was an issue while trying to get ZIP Code, please contact support.";
        } finally {
            this.isLoading = false;
        }
        console.log('Result: '+this.result);

        let resultCmp = this.template.querySelector('c-kt-result');
        resultCmp.reload(this.result);
    }
}