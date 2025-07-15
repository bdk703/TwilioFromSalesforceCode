public class TwilioSMS {

    // Replace with your Account SID and Auth Token
    private static final String ACCOUNT_SID = 'AC3c0a18de3611f417e015b33c1f488cf8';
    private static final String AUTH_TOKEN = 'a2fe954caaff3bb1d37d96613296cd71';
    private static final String TWILIO_NUMBER = '+91 9663893735'; // Your Twilio phone number

    public class TwilioResponse {
        public String sid;
        public String status;
    }

    public static TwilioResponse sendSMS(String toPhoneNumber, String messageBody) {
        TwilioResponse response = new TwilioResponse();
        try {
            // Construct the endpoint URL
            String endpoint = 'https://api.twilio.com/2010-04-01/Accounts/' + ACCOUNT_SID + '/Messages.json';

            // Construct the request body
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(ACCOUNT_SID + ':' + AUTH_TOKEN)));

            String body = 'To=' + EncodingUtil.urlEncode(toPhoneNumber, 'UTF-8') +
                          '&From=' + EncodingUtil.urlEncode(TWILIO_NUMBER, 'UTF-8') +
                          '&Body=' + EncodingUtil.urlEncode(messageBody, 'UTF-8');
            request.setBody(body);

            // Execute the request
            Http http = new Http();
            HTTPResponse httpResponse = http.send(request);

            //Handle the response
            if (httpResponse.getStatusCode() == 201) {
                // Successful response
                String jsonResponse = httpResponse.getBody();
                Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                response.sid = (String) resp.get('sid');
                response.status = (String) resp.get('status');
            } else {
                // Error handling
                System.debug('Error sending SMS: ' + httpResponse.getStatusCode() + ' ' + httpResponse.getStatus());
                System.debug('Response Body: ' + httpResponse.getBody());
                // You might want to throw an exception or handle the error in a more specific way
            }
        } catch (Exception e) {
            System.debug('Exception during SMS sending: ' + e.getMessage());
            // Handle the exception
        }
        return response;
    }
}