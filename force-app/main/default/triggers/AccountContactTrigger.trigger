trigger AccountContactTrigger on AccountContactRelation (before insert, before update, before delete) {
    if (Helper.SkipTriggers.contains('all')) return;

    AccountContactHelper.loadRelations(!Trigger.isDelete ? Trigger.new : Trigger.old);
    List<AccountContactRelation> lstForUpdate = new List<AccountContactRelation>();
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            AccountContactRelation oldRecord = Trigger.isInsert ? new AccountContactRelation() : Trigger.old[i];
            AccountContactRelation newRecord = Trigger.new[i];

            AccountContactRelation latestRelation = AccountContactHelper.getLatest(newRecord.ContactId);

            if (Trigger.isInsert && latestRelation == null) {
                newRecord.Is_Primary__c = true;
            } else if (oldRecord.Is_Primary__c != newRecord.Is_Primary__c) {
                if (newRecord.Is_Primary__c && latestRelation != null) {
                    latestRelation.Is_Primary__c = false;
                    lstForUpdate.add(latestRelation);
                } else if (!newRecord.Is_Primary__c) {
                    if (latestRelation != null) {
                        latestRelation.Is_Primary__c = true;
                        lstForUpdate.add(latestRelation);
                    } else {
                        newRecord.addError('You cannot change Is Primary field when Relation to Account is the only one');
                    }
                }
            }
        }
    } else if (Trigger.isDelete) {
        for (AccountContactRelation oldRecord: Trigger.old) {
            AccountContactRelation latestRelation = AccountContactHelper.getLatest(oldRecord.ContactId);
            if (latestRelation != null) {
                latestRelation.Is_Primary__c = true;
                lstForUpdate.add(latestRelation);
            }
        }
    }

    if (lstForUpdate.size() > 0) {
        Helper.updateSkipTriggers(lstForUpdate);
    }
}