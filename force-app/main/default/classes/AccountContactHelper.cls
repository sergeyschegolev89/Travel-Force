public class AccountContactHelper {
    public static Map<Id, List<AccountContactRelation>> mpRelations {get; private set;}

    public static void loadRelations(List<AccountContactRelation> lstCurrentRecords) {
        Set<Id> stContactIds = Helper.getSetOfIds(lstCurrentRecords, 'ContactId');
        List<AccountContactRelation> lstACR = [
            SELECT 
                Id, 
                ContactId, 
                Is_Primary__c 
            FROM AccountContactRelation 
            WHERE ContactId IN: stContactIds AND Id NOT IN: lstCurrentRecords 
            ORDER BY Is_Primary__c DESC, CreatedDate DESC
        ];

        mpRelations = Helper.getMapOfListsOfSObjects(lstACR, 'ContactId');
    }

    public static AccountContactRelation getLatest(Id contactId) {
        List<AccountContactRelation> lstACR = mpRelations.get(contactId);
        return lstACR != null ? lstACR[0] : null;
    }
}