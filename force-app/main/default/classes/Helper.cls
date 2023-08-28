public class Helper {
    public static Set<String> SkipTriggers {
		get {
			return SkipTriggers = (SkipTriggers == null ? new Set<String>() : SkipTriggers);
		}
		set;
	}

    public static void updateSkipTriggers(List<SObject> lstObjects) {
		Helper.SkipTriggers.add('all');
		update lstObjects;
		Helper.SkipTriggers.remove('all');
	}

    public static Set<Object> getSetOfValues(List<SObject> lstSObjects, String strField) {
		Set<Object> stResult = new Set<Object>();
		for (SObject obj : lstSObjects) {
			Object value = obj.get(strField);
			if (value != null) {
				stResult.add(value);
			}
		}

		return stResult;
	}

	public static Set<Id> getSetOfIds(List<SObject> lstSObjects, String strField) {
		Set<Id> stResult = new Set<Id>();
		Set<Object> stValues = Helper.getSetOfValues(lstSObjects, strField);
		for (Object obj : stValues) {
			stResult.add((Id) obj);
		}

		return stResult;
	}

    public static Map<Id, List<SObject>> getMapOfListsOfSObjects(List<SObject> lstSObjects, String strField) {
		Map<Id, List<SObject>> mpResult = new Map<Id, List<SObject>>();
		for (SObject obj : lstSObjects) {
			Id key = (Id) obj.get(strField);
			if (key != null) {
				if (!mpResult.containsKey(key)) {
					mpResult.put(key, new List<SObject>());
				}
				mpResult.get(key).add(obj);
			}
		}

		return mpResult;
	}
}