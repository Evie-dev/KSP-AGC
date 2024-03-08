GLOBAL _COMMONFUNC_COLLECTIONS_AVAILABLE IS TRUE.

FUNCTION addToList {
    parameter list1 is list(), list2 is list().
    local returnList is list().
    IF NOT(list1:istype("List")) { returnList:add(list1). }
    ELSE { set returnList to list1. }
    IF NOT(list2:istype("List")) {
        returnList:add(list2).
    } ELSE { for i in list2 { returnList:add(i). }}
    return returnList.
}

FUNCTION removeFromList {
    parameter listItem is list(), itemsToRemove is list().
    local returnList is list().
    FOR i in listItem {
        IF NOT(itemsToRemove:contains(i)) { returnList:add(i). }
    }
    return returnList.
}

FUNCTION compareList {
    parameter listtoCheck is list(), checkAgainst is list(), excludeFromCheck is list().

    local returnData is lexicon(
        "isEqual", true,
        "NumberofDifferences", 0,
        "differences", list()
    ).

    local longestList is list().
    local shortestList is list().
    local excludeList is list().

    IF listtoCheck:length < checkAgainst:length {
        set longestList to checkAgainst.
        set shortestList to listtoCheck.
    } ELSE {
        set longestList to listtoCheck.
        set shortestList to checkAgainst.
    }
    set excludeList to excludeFromCheck.

    FOR i in longestList {
        IF NOT(exclusionList:contains(i)) {
            IF NOT(shortestList:contains(i)) {
                set returnData:isEqual to false.
                set returnData:NumberofDifferences to returnData:NumberofDifferences+1.
                returnData:differences:add(i).
            }
        }
    }

    return returnData.

}