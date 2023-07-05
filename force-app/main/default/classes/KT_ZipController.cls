public class KT_ZipController {
    public static String BASE_URL = 'https://api.zippopotam.us/';
    
    @AuraEnabled
    public static String getCountry(String zipCode) {
        /*** Check if exists in the US **/
        String initialResult = '';
        String zipCodeURL = BASE_URL + 'US/'+zipCode;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(zipCodeURL);
        req.setMethod('GET');
        /** Response **/
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String response = res.getBody();
        //System.debug(response);
        KT_ZipUtils.ZipResponse zipResponse = KT_ZipUtils.parseJsonString(response);
        
        System.debug('GET COUNTRY method initial response');
        System.debug(zipResponse);
        
        if(zipResponse.countryAbbreviation=='US') {
            initialResult = 'ZIP Code found in the United States. Details: '+zipResponse.places[0].placeName+', '+zipResponse.places[0].state;
        } else {
            List<KT_ZipUtils.ZipResponse> countryResponses = new List<KT_ZipUtils.ZipResponse>();
            /** 1. Get countries and code **/
            List<Country__c> countries = [Select Name, Code__c FROM Country__c LIMIT 100];
            for(Country__c country: countries) {
                KT_ZipUtils.ZipResponse countryResponse = KT_ZipUtils.doApiCall(country.Code__c, zipCode);
                if(countryResponse.country!=null) {
                    countryResponses.add(countryResponse);
                }
            }
            
            Search__c search_obj = new Search__c(ZIP_Code__c = zipCode, Name = 'Search at '+System.now());
            insert search_obj;
            List<Search_Result__c> searchResponses = new List<Search_Result__c>();
            
            for(KT_ZipUtils.ZipResponse zipR: countryResponses) {
                Search_Result__c searchResponse = new Search_Result__c(Country__c = zipR.country,
                                                                       Country_Code__c = zipR.countryAbbreviation,
                                                                       Search__c = search_obj.Id,
                                                                       ZIP_Code__c = zipCode,
                                                                       Places__c = String.valueOf(zipR.places));
                searchResponses.add(searchResponse);
            }
            insert searchResponses;
            
            initialResult = 'ZIP code was not found in US. Please refer to search history to see results.';
        }
        
        System.debug('INITIAL RESULT');
        System.debug(initialResult);
        return initialResult;
    }
}