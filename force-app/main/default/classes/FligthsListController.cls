public with sharing class FligthsListController {
    @AuraEnabled(cacheable=true)
    public static List<Flight__c> getAvailableFligths(String preferreddate) {
        try { 
            return [ 
                SELECT Id, Name, Start__c
                FROM Flight__c 
                WHERE DAY_ONLY(Start__c) =: Date.valueOf(preferreddate) and Start__c >: DateTime.now()
                      and Id IN (SELECT Flight__c From Ticket__c WHERE Contact__c = null)
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String bookTicket(String contactId, String flightId) {
        String result = '';
        List<Ticket__c> lstTickets = [
            SELECT Id, Contact__c 
            FROM Ticket__c 
            WHERE Flight__c =: flightId 
            LIMIT 1
        ];
        if (!lstTickets.isEmpty()) {
            Ticket__c ticket = lstTickets.get(0);
            ticket.Contact__c = contactId;
            update ticket;
            TripHelper.sendCalloutToTravelForce(ticket.Id);
            result = 'Success';
        } else {
            result = 'Error: Unfortunately All Tickets for this Flight have been booked';
        }
        
        return result;
    }
}