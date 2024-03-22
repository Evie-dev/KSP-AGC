runOncePath("0:/kOS AGC/Database/Parts/BDB.ks").
runOncePath("0:/kOS AGC/Database/Parts/FASA.ks").
runOncePath("0:/kOS AGC/Database/Parts/blank.ks").

runOncePath("0:/Common/commonFuncWrapper.ks").

// returns a FULL part database
FUNCTION getPartDatabase {
    parameter rootDatabase is "BDB".

    local _blankDatabaseOVERALL is getBlankDatabase().


    local _returnDatabase is lexicon().
    FOR i in _blankDatabaseOVERALL:keys {
        _returnDatabase:add(i, getDatabaseComponent(rootDatabase, i)).
    }

    return _returnDatabase.
}



LOCAL FUNCTION getRootDatabase {
    parameter baseName is "BDB", forComponent is "a".

    IF baseName = "BDB" {
        return getBDBdatabase(forComponent).
    } ELSE IF baseName = "FASA" {
        return getFASAdatabase(forComponent).
    } ELSE IF baseName = "DECQ" {
        //return getDECQdatabase(forComponent).
    }
}

// returns a specific part of a database
FUNCTION getDatabaseComponent {
    parameter usingRoot is "BDB", toGetComponent is "CSM".

    local _blankDatabase is getBlankDatabase(toGetComponent).

    local _rootDatabase is getRootDatabase(usingRoot, toGetComponent).

    local _returnData is lexicon().

    FOR i in _rootDatabase:keys {
        IF i = "S-IVB" or i = "S-II" {
            // special function for reading part databases, due to the fact that they have different
            _returnData:add(i, readPartDatabase(_rootDatabase[i], i)).
        }
        _returnData:add(i, readPartDatabase(_rootDatabase[i])).

    }

    return _returnData.
}

// seems to function

// In order to differenciate between different engines, 
LOCAL FUNCTION readPartDatabase {
    parameter usingDatabase is lexicon(), saturnStage is "N".

    local _returnLexicon is lexicon().

    // lexicon tree walking
    IF usingDatabase:istype("List") {
        return getParts(usingDatabase, saturnStage).
    }
    local _rStruct is lexicon().
    FOR i in usingDatabase:keys {
        set _rStruct to lexicon().
        set _rStruct to usingDatabase[i].
        IF _rStruct:istype("Lexicon") { set _rStruct to readPartDatabase(_rStruct,saturnStage). }
        ELSE IF _rStruct:istype("List") { 
            set _rStruct to getParts(_rStruct).
            IF NOT(saturnStage = "N") {
                local _rstruct2 is list().
                FOR i in _rStruct {
                    IF i:hasmodule("ModuleApolloSaturnEngine") {
                        local _stageName is getPartField(i, "Engine Stage").
                        IF _stageName = saturnStage {
                            _rstruct2:add(i).
                        }
                    } ELSE {
                        _rstruct2:add(i).
                    }
                }
            }
        }
        _returnLexicon:add(i, _rStruct).
    }

    return _returnLexicon.
}

// huge WIP
LOCAL FUNCTION getRCSdata {
    parameter usingRoot is "BDB".

    local _RCSparts is getDatabaseComponent(usingRoot, "CSM"):SM:RCS.

    // for BDB

    local _BDBrcsOrientation is LEXICON("A", -90, "B", 90).

    FOR i in _RCSparts {
        local rFacing is i:facing.
        local sFacing is ship:facing.

        local _pitchEqual is false.
        local _yawEqual is false.
        local _rollEqual is false.
    }
}