@isTest
private class TripTest {

    @TestSetup
    static void setup(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        Contact cont1 = new Contact();
        cont1.FirstName = 'John';
        cont1.LastName = 'Smith';
        insert cont1;

        Flight__c flight1 = new Flight__c();
        flight1.Start__c = Datetime.now().addDays(1);
        insert flight1;

        Ticket__c ticket = new Ticket__c();
        ticket.Flight__c = flight1.Id;
        insert ticket;
    }

    @isTest
    private static void ticketBookingTest() {
        Contact cont = [SELECT Id, FirstName, LastName FROM Contact WHERE FirstName = 'John' LIMIT 1];
        Trip__c trip = new Trip__c();
        trip.Name = 'test';
        trip.Preferred_trip_start__c = Date.valueOf(Datetime.now().addDays(1));
        trip.Contact__c = cont.Id;
        insert trip;

        trip = [SELECT Id, Name, Preferred_trip_start__c FROM Trip__c WHERE Id =: trip.Id];
        System.assert(trip.Name.contains(cont.FirstName), 'Trip Name does not contain Contact First Name');
        System.assert(trip.Name.contains(cont.LastName), 'Trip Name does not contain Contact Last Name');

        List<Flight__c> lstFlights = FligthsListController.getAvailableFligths(String.valueOf(trip.Preferred_trip_start__c));
        System.assertEquals(1, lstFlights.size(), 'Flights List does not match trip date');

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String result = FligthsListController.bookTicket(cont.Id, lstFlights[0].Id);
        System.assertEquals('Success', result, 'Ticket booking error');

        List<Ticket__c> lstTickets = [SELECT Id FROM Ticket__c WHERE Contact__c =: cont.Id AND Flight__c =: lstFlights[0].Id];
        System.assertEquals(1, lstTickets.size(), 'Ticket has not been booked');
    }
}