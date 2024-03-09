// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT
// functions relating to parts and part actions

GLOBAL _COMMONFUNC_PARTS_AVAILABLE IS TRUE.

function getParts {
    parameter forParts is list(), returnSingle is false.
    // accepts a list, part or string
    local returnList is list().
    IF forParts:istype("List") {
        FOR i in forParts {
            set returnlist to addToList(returnList, getParts(i)).
        }
    } ELSE IF forParts:istype("String") {
        set returnList to ship:partstagged(forParts).
    } ELSE IF forParts:istype("Part") {
        returnList:add(forParts).
    }
    IF returnSingle AND NOT(returnList:empty) {
        set returnList to returnList[0].
    }
    return returnList.
}

FUNCTION isPart {
    parameter ofPart is false.
    return ofPart:istype("Part").
}

// has action ect


// partHasEvent 
FUNCTION partHasEvent {
    parameter forPart is false, eventName is "", byIndex is false.
    IF NOT(isPart(forPart)) OR NOT(eventName:istype("String")) { return false. }
    ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { return true. }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { return true. }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasevent(eventName) { return true. }
            }
        }
    }
    return false.
}

FUNCTION partHasAction {
    parameter forpart is false, actionName is list().
    IF NOT(isPart(forPart)) OR NOT(actionName:istype("String")) { return false. }
    ELSE {
        FOR i in forPart:modules {
            IF forPart:getmodule(i):hasaction(actionName) { return true. }
        }
    }
    return false.
}

FUNCTION partHasField {
    parameter forPart is false, fieldName is list().
    IF NOT(isPart(forPart)) OR NOT(fieldName:istype("String")) { return false. }
    ELSE {
        FOR i in forPart:modules {
            IF forPart:getmodule(i):hasfield(fieldName) { return true. }
        }
    }
    return false.
}

// read part field value
// example reading the thrust limiter value

FUNCTION getPartField {
    parameter forPart is false, fieldName is"", byIndex is false.
    local returnValue is "".
    IF NOT(isPart(forPart)) OR NOT(fieldName:istype("String")) { return false. }
    ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { set returnValue to forPart:getmodulebyindex(mIndex):getfield(fieldName). }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { 
                        set returnValue to forPart:getmodulebyindex(mIndex):getfield(fieldName).
                        break.
                    }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasfield(fieldName) { 
                    set returnValue to forPart:getmodule(i):getfield(fieldName). 
                    break.
                }
            }
        }
    }
    return returnValue.
}

// do actions and events

FUNCTION doPartEvent {
    parameter forPart is list(), eventName is false, byIndex is false.
    // doesnt require a single part therefore we can do this through a list
    IF NOT(forPart:istype("Part")) {
        set forPart to getParts(forPart).
        FOR i in forPart {
            doPartEvent(i, eventName, byIndex).
        }
    } ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { forPart:getmodulebyindex(mIndex):doevent(eventName). }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasevent(eventName) { forPart:getmodulebyindex(mIndex):doevent(eventName). }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasevent(eventName) { forPart:getmodule(i):doevent(eventName). }
            }
        }
    }
}

// TODO - not used too often
FUNCTION doPartAction {
    parameter forPart is list(), actionName is false, actionValue is false, byIndex is false.
    set forPart to 1.
    set actionName to 1.
    set actionValue to 1.
    set forPart to actionName+actionValue.
    set actionName to forPart. //errors be damned
    return false.
}

FUNCTION setPartField {
    parameter forPart is list(), fieldName is false, fieldValue is 0, byIndex is false.
    IF NOT(forPart:istype("Part")) {
        set forPart to getParts(forPart).
        FOR i in forPart {
            setPartField(i, fieldName, fieldValue, byIndex).
        }
    } ELSE {
        local doByIndex is false.
        IF byIndex:istype("Boolean") {
            set doByIndex to byIndex.
        } ELSE IF byIndex:istype("Scalar") {
            set doByIndex to byIndex = min(forPart:allmodules:length-1, max(-1, byIndex)).
        }
        IF doByIndex {
            local mIndex is 0.
            IF byIndex:istype("Scalar") {
                set mIndex to byIndex.
                IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { forPart:getmodulebyindex(mIndex):setfield(fieldName, fieldValue). }
            } ELSE {
                FOR i in forPart:modules {
                    IF forPart:getmodulebyindex(mIndex):hasfield(fieldName) { forPart:getmodulebyindex(mIndex):setfield(fieldName, fieldValue). }
                    set mIndex to mIndex+1.
                }
            }
            
        } ELSE {
            FOR i in forPart:modules {
                IF forPart:getmodule(i):hasfield(fieldName) { forPart:getmodule(i):setfield(fieldName, fieldValue). }
            }
        }
    }
}

FUNCTION getPartMassLEX {
    parameter forParts is list().
    local rLex is lexicon(
        "Mass", 0,
        "WetMass", 0,
        "DryMass", 0,
        "fuelMass", LEXICON("t", 0, "c", 0)
    ).
    IF NOT(forParts:istype("Part")) {
        set forParts to getParts(forParts).
        FOR i in forParts {
            local part_rLex is getPartMassLEX(i).
            set rLex:Mass to part_rLex:Mass+rLex:Mass.
            set rLex:WetMass to part_rLex:WetMass+rLex:wetMass.
            set rLex:DryMass to part_rLex:DryMass+rLex:DryMass.
        }
    } ELSE {
        set rLex:Mass to forParts:Mass.
        set rLex:WetMass to forParts:WetMass.
        set rLex:DryMass to forParts:DryMass.
    }
    set rLex:fuelMass:t to rLex:wetmass-rLex:drymass.
    set rLex:fuelMass:c to rLex:mass-rLex:drymass.
    return rLex.
}

FUNCTION getPartResourcesLEX {
    parameter forParts is list().
    local rLex is lexicon().
    IF forParts:istype("Part") {
        FOR i in forParts:resources {
            local resourceSpecificLexicon is LEXICON(
                "Name", i:Name,
                "Amount", i:Amount,
                "MaxAmount", i:Capacity
            ).
            rLex:add(i:Name, resourceSpecificLexicon).
        }
    } ELSE {
        set forParts to getParts(forParts).
        FOR i in forParts {
            local partResources is getPartResourcesLEX(i).
            FOR _i in partResources:keys {
                IF rLex:haskey(_i) {
                    set rLex[_i]:Amount to rLex[_i]:Amount+partResources[_i]:Amount.
                    set rLex[_i]:MaxAmount to rLex[_i]:MaxAmount+partResources[_i]:MaxAmount.
                } ELSE {
                    rLex:add(_i, partResources[_i]).
                }
            }
        }
    }
    return rLex.
}

FUNCTION setTankResourceState {
    parameter prt is LIST(), setState is "Enable", resourceName is LIST().
    IF NOT(resourceName:istype("list")) { set resourceName to LIST(resourceName). }
    IF setState:istype("Boolean") {
        IF setState { set setState to "Enable". }
        ELSE { set setState to "Disable". }
    }
    IF NOT(setState = "Enable" or setState = "Disable") { return. }
    set prt to getParts(prt).
    FOR i in prt {
        setRscState(i, setState, resourceName).
    }
}

local function setRscState {
    parameter prt is "none", setState is "Enable", resourceName is LIST().
    local ii is 0.
    FOR i in prt:resources {
        IF NOT(prt:resources[ii]:name = "ELECTRICCHARGE") {
            IF resourceName:empty {
                set prt:resources[ii]:Enabled to setState = "Enable".
            } ELSE IF resourceName:contains(prt:resources[ii]:Name) {
                set prt:resources[ii]:Enabled to setState = "Enable".
            }
        }
        set ii to ii+1.
    }
}