trigger TripTrigger on Trip__c (before insert, before update) {
    for (Trip__c newTrip: Trigger.new) {
        newTrip.Name = newTrip.Contact_Name__c + ' ' + newTrip.Preferred_trip_start__c.format();
        newTrip.Status__c = newTrip.Flight__c != null ? TripHelper.STATUS_BOOKED : TripHelper.STATUS_SEARCH;     
    }
}