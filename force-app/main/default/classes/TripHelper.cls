public class TripHelper {

    @future (callout=true)
    public static void sendCalloutToTravelForce(Id ticketId) {
        Ticket__c ticket = [
            SELECT 
                Id, 
                Name, 
                Contact_Name__c 
            FROM Ticket__c 
            WHERE Id =: ticketId
        ];

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('ticketnumber', ticket.Name);
        gen.writeStringField('contact', ticket.Contact_Name__c);
        gen.writeEndObject();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Travel_Force');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(gen.getAsString());

        try {
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
        } catch(Exception error) {
            // here should be email alert to administrator
            throw error;
        }
       
    }

    private static final List<Schema.PicklistEntry> STATUS_VALUES = Trip__c.Status__c.getDescribe().getPicklistValues();
    public static final String STATUS_SEARCH = STATUS_VALUES.get(0).getValue(); 
    public static final String STATUS_BOOKED = STATUS_VALUES.get(1).getValue(); 
}