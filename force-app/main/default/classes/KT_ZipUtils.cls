public class KT_ZipUtils {
    
    public static String BASE_URL = 'https://api.zippopotam.us/';
    
    //@future(callout=true)
    public static KT_ZipUtils.ZipResponse doApiCall(String code, String zipCode) {
        String zipCodeURL = BASE_URL + code +'/'+zipCode;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(zipCodeURL);
        req.setMethod('GET');
        
        /** Response **/
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String response = res.getBody();
        ZipResponse zipResponse = KT_ZipUtils.parseJsonString(response);
        
        return zipResponse;
    }
    
    /*    
{"post code": "90210", 
"country": "United States", 
"country abbreviation": "US", 
"places": [{"place name": "Beverly Hills", 
"longitude": "-118.4065", 
"state": "California", 
"state abbreviation": "CA", 
"latitude": "34.0901"}]}

*/
    public static ZipResponse parseJsonString(String jsonStr) {
        jsonStr = jsonStr.replaceAll('post code', 'postCode');
        jsonStr = jsonStr.replaceAll('country abbreviation', 'countryAbbreviation');   
        jsonStr = jsonStr.replaceAll('place name', 'placeName');
        jsonStr = jsonStr.replaceAll('state abbreviation', 'stateAbbreviation');
        
        ZipResponse zipResponse;
        
        // Parse entire JSON response.
        JSONParser parser = JSON.createParser(jsonStr);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                // Read entire object, including its array of line items.
                zipResponse = (ZipResponse)parser.readValueAs(ZipResponse.class);
                
                // Skip the child start array and start object markers.
                parser.skipChildren();
            }
        }
        return zipResponse;
    }
    
    public class ZipResponse {
        public String postCode;
        public String country;
        public String countryAbbreviation;
        public List<Place> places;
        
        public ZipResponse(String postCode, String country, List<Place> places) {
            this.postCode = postCode;
            this.country = country;
            this.places = places;
        }
    }
    
    public class Place {
        public String placeName;
        public String longitude;
        public String state;
        public String stateAbbreviation;
        public String latitude;
        
        public Place(String placeName, String longitude, String state, String stateAbbreviation, String latitude) {
            this.placeName = placeName;
            this.longitude = longitude;
            this.state = state;
            this.stateAbbreviation = stateAbbreviation;
            this.latitude = latitude;
        }
    }
}