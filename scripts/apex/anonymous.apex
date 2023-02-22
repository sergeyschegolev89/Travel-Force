// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


List<Ticket__c> lstTicket = [ 
    SELECT Id, 
        Name,
        Contact__c,
        Contact_Name__c
    FROM Ticket__c
    WHERE Contact__c != null 
    LIMIT 1
];

// JSONGenerator gen = JSON.createGenerator(true);
// gen.writeStartObject();
// gen.writeStringField('ticketnumber', ticket.Name);
// gen.writeStringField('contact', ticket.Contact_Name__c);
// gen.writeEndObject();

// System.debug(gen.getAsString());

// TripHelper.sendCalloutForBookTickets(lstTicket);
System.debug(Trip__c.Status__c.getDescribe().getPicklistValues().get(1).getValue());