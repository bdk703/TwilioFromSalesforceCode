/**
 * @description This Apex class provides a utility to make HTTP callouts to the Twilio API.
 * It includes a method to send an SMS, which can be adapted for other Twilio endpoints.
 * * Before deploying and using this code, ensure you have:
 * 1. Your Twilio Account SID and Auth Token.
 * 2. Added 'https://api.twilio.com' (or the specific Twilio API endpoint URL)
 * to Salesforce's Remote Site Settings.
 */
public class TwilioAPICaller {
    // IMPORTANT: Replace with your actual Twilio Account SID and Auth Token
    // Consider storing these securely in Custom Metadata Types or Protected Custom Settings
    // for production environments.
    private static final String TWILIO_ACCOUNT_SID = 'ACXXXX'; // Your Twilio Account SID
    private static final String TWILIO_AUTH_TOKEN = 'Auth token'; // Your Twilio Auth Token

    /**
     * @description Makes a generic HTTP POST callout to a specified Twilio API endpoint.
     * @param endpoint The specific Twilio API endpoint (e.g., '/2010-04-01/Accounts/{AccountSid}/Messages.json')
     * @param requestBody The URL-encoded body for the POST request (e.g., 'To=+1234567890&From=+1987654321&Body=Hello+from+Salesforce')
     * @return String The response body from the Twilio API.
     * @throws CalloutException If there's an error during the HTTP callout.
     */
    public static String makeTwilioCallout(String endpoint, String requestBody) {
        // Construct the full Twilio API URL
        // Example for Messages API: https://api.twilio.com/2010-04-01/Accounts/{AccountSid}/Messages.json
        String fullUrl = 'https://api.twilio.com' + endpoint;

        // Initialize HTTP objects
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        // Set the endpoint URL
        req.setEndpoint(fullUrl);
        // Set the HTTP method to POST for most Twilio API calls (e.g., sending messages)
        req.setMethod('POST');
        // Set the content type for URL-encoded form data
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        // Set the Authorization header for basic authentication
        // The format is 'Basic ' + Base64.encode(AccountSID + ':' + AuthToken)
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(TWILIO_ACCOUNT_SID + ':' + TWILIO_AUTH_TOKEN));
        req.setHeader('Authorization', authHeader);
        // Set the request body
        req.setBody(requestBody);
        // Set the timeout (optional, default is 10 seconds)
        req.setTimeout(60000); // 60 seconds timeout

        System.debug('Twilio Request URL: ' + fullUrl);
        System.debug('Twilio Request Body: ' + requestBody);

        try {
            // Send the HTTP request
            res = http.send(req);

            // Check the response status code
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                System.debug('Twilio Response Body: ' + res.getBody());
                return res.getBody();
            } else {
                // Handle non-success responses
                System.debug('Twilio API Error - Status Code: ' + res.getStatusCode());
                System.debug('Twilio API Error - Status: ' + res.getStatus());
                System.debug('Twilio API Error - Response Body: ' + res.getBody());
                throw new CalloutException('Error calling Twilio API: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (System.CalloutException e) {
            // Catch any callout specific exceptions (e.g., timeout, network issues)
            System.debug('Callout Exception: ' + e.getMessage());
            throw new CalloutException('Failed to connect to Twilio API: ' + e.getMessage());
        } catch (Exception e) {
            // Catch any other unexpected exceptions
            System.debug('General Exception: ' + e.getMessage());
            throw new CalloutException('An unexpected error occurred: ' + e.getMessage());
        }
    }

    /**
     * @description Example method to send an SMS using the Twilio Messages API.
     * This method demonstrates how to use the generic makeTwilioCallout.
     * @param toPhoneNumber The recipient's phone number (e.g., '+1234567890')
     * @param fromPhoneNumber The Twilio phone number (e.g., '+1987654321')
     * @param messageBody The content of the SMS message
     * @return String The response body from Twilio, typically containing message SID.
     */
    @AuraEnabled // Example: If you want to call this from Lightning Web Components or Aura
    @RemoteAction // Example: If you want to call this from Visualforce JavaScript
    public static String sendSMS(String toPhoneNumber, String fromPhoneNumber, String messageBody) {
        // Encode the message body for URL-encoding
        String encodedMessageBody = EncodingUtil.urlEncode(messageBody, 'UTF-8');

        // Construct the request body for sending an SMS
        // Parameters: To, From, Body
        String requestBody = 'To=' + EncodingUtil.urlEncode(toPhoneNumber, 'UTF-8') +
                             '&From=' + EncodingUtil.urlEncode(fromPhoneNumber, 'UTF-8') +
                             '&Body=' + encodedMessageBody;

        // Define the Twilio Messages API endpoint
        String endpoint = '/2010-04-01/Accounts/' + TWILIO_ACCOUNT_SID + '/Messages.json';

        // Make the callout
        return makeTwilioCallout(endpoint, requestBody);
    }

    /**
     * @description Example usage of the sendSMS method.
     * You can execute this anonymously or from a test class.
     */
    public static void exampleUsage() {
        try {
            // IMPORTANT: Replace with actual phone numbers
            String recipient = '+1234567890'; // Replace with recipient's phone number
            String twilioNumber = '+1987654321'; // Replace with your Twilio phone number
            String message = 'Hello from Salesforce via Twilio!';

            System.debug('Attempting to send SMS...');
            String response = sendSMS(recipient, twilioNumber, message);
            System.debug('SMS Sent Successfully! Twilio Response: ' + response);
        } catch (CalloutException e) {
            System.debug('Failed to send SMS: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('An unexpected error occurred during SMS sending: ' + e.getMessage());
        }
    }
}
