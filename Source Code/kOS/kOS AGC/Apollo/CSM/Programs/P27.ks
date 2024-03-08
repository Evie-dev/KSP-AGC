// Program 27 - CMC UPDATE PROGRAM

local _V02N02 is false.


local _readState is 0.
local _verbSet is false.
local _verbMode is 0.


local _uplinkReadState is 0.
local _uplinkRate is 0.67. // unsure for now, assuming it would be 2x the refresh rate
local _lastUplinkRate is 0.5.
local _lastUplink is 0.

local _dataState is 0.

GLOBAL _P27_AVAILABLE IS TRUE.

FUNCTION P27_INIT {
    parameter asRestart is false.
    local _currentProgram is EMEM_READ("PROGRAM").
    IF NOT(LIST(-1,0,2):contains(_currentProgram)) { return. }
    P27_TEST_LOGIC().
    IF NOT(EXISTS("0:/kOS AGC/Apollo/CSM/P27uplink.json")) { return. }
    EMEM_WRITE("PROGRAM", 27).
    DSKY_SETMAJORMODE("27").
    set PROGRAM_FUNCTION to P27_MAINBODY@.
}

// in theory this supports an unlimited uplink... for now at least

LOCAL FUNCTION P27_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").
    IF pstep = 0 {
        // VERBSET
        UPLINK_CONTROLLER().
        IF _verbSet {
            PNEXT_STEP().
        }

    } ELSE IF pstep = 1 {
        UPLINK_CONTROLLER(). 
        IF _dataState = 2 {
            local _indexes is EMEM_READ(304).

            IF _indexes > 3 and _indexes < 20 {
                PNEXT_STEP().
            } ELSE {
                // unsure!
                PNEXT_STEP().
            }
        }
    } ELSE IF pstep = 2 {
        UPLINK_CONTROLLER(). 
    } ELSE IF pstep = 3 {
        IF NOT(_V02N02) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(2,2,TRUE).
            set _V02N02 to true.
        }
    }
    

    
    
}

LOCAL FUNCTION UPLINK_CONTROLLER {
    IF TIME:SECONDS > _lastUplink+_lastUplinkRate {
        IF EXISTS("0:/kOS AGC/Apollo/CSM/P27uplink.json") {
            local _p27Uplink is READJSON("0:/kOS AGC/Apollo/CSM/P27uplink.json").
            IF _uplinkReadState > _p27Uplink:length-1 {
                P27_COMPLETE().
                return.
            }
            UPLINK_INPUT(_p27Uplink[_uplinkReadState]).
            IF _p27Uplink[_uplinkReadState] = "1 11111 00000 11111" { 
                set _dataState to _dataState+1.
                set _lastUplinkRate to 2.
                } ELSE {
                    set _lastUplinkRate to _uplinkRate.
                }
            set _uplinkReadState to _uplinkReadState+1.
            set _lastUplink to time:seconds.
        }
    }
}

FUNCTION P27_VERBSET {
    parameter md is 0.
    set _verbSet to true.
    set _verbMode to md.

    DSKY_SETFLAG("N01ECADR", "300").
    DSKY_SETFLAG("N01AUTOSEQUENTIAL", true).
    DSKY_SETFLAG("N01STEP", "ECADR2").

    
}

local function P27_INDEXSET {
    
}

LOCAL FUNCTION P27_COMPLETE {
    PNEXT_STEP().
}


// simple test

LOCAL FUNCTION P27_TEST_LOGIC {
    local _uplLIST is LIST().
    local _dataList is LIST(
        "72",
        "12",
        "3065",
        "+11111",
        "3066",
        "+11111",
        "3072",
        "+12345",
        "3073",
        "+54321"
    ).

    _uplLIST:add("VERB").
    FOR i in _dataList {
        set _uplLIST to TESTLOGIC2(i, _uplLIST).
        _uplLIST:add("ENTR").
    }

    log _uplLIST to "0:/uplist.txt".

    local _upl2 is LIST().
    FOR i in _uplLIST {
        _upl2:add(PINBALL_UPLINK_WORDS(i)).
    }

    writeJson(_upl2, "0:/kOS AGC/Apollo/CSM/P27uplink.json").
}

LOCAL FUNCTION TESTLOGIC2 {
    parameter strng is "", currentList is LIST().

    FOR i in strng {
        currentList:add(i).
    }
    return currentList.
}

FUNCTION P27_COMMIT {

    local vMode is _verbMode.
    local vIndexes is 0.
    
    local _UBlist is LIST().

    local _UB is "UPBUFF".
    local _currentUpbuff is 0.
    local _maxUpbuff is 20. // 24 octal
    local _decAddress is tobase(8,10,304).
    local _octAddress is tobase(10,8,304).

    UNTIL _currentUpbuff > _maxUpbuff {
        set _octAddress to tobase(10,8,_decAddress).
        set _UB to "UPBUFF" + _currentUpbuff:tostring.
        _UBlist:add(EMEM_READ(_UB)).
        set _decAddress to _decAddress+1.
        set _currentUpbuff to _currentUpbuff+1.
    }

    local _commitList is LEXICON().

    set vIndexes to _UBlist[0].
    local UBindex is 0.
    
    local UBecadrBase is 0.
    local _currentECADR is 0.
    UNTIL UBindex > _UBlist:length-1 {
        IF UBindex > 0 {
            IF vMode = 1 {
                IF UBindex = 1 {
                    set UBecadrBase to _UBlist[UBindex]:tostring.

                    local _base2 is UBecadrBase.
                    set UBecadrBase to "".
                    FOR i in _base2 {
                        IF NOT(i = "b") { set UBecadrBase to UBecadrBase+i.}
                    }
                    set UBecadrBase to UBecadrBase:tonumber(301).
                    set _currentECADR to UBecadrBase.
                } ELSE {
                    set _currentECADR to tobase(8,10,_currentECADR)+1.
                    set _currentECADR to tobase(10,8,_currentECADR).
                    local _value is _UBlist[UBindex].
                    local _value2 is _value.
                    set _value to "".
                    FOR i in _value2 {
                        IF NOT(i = "b") { set _value to _value+i.}
                    }
                    _commitList:add(_currentECADR:tostring, _value).
                }
                set UBecadrBase to UBecadrBase+1.
                set UBindex to UBindex+1.
            } 
            ELSE IF vMode = 2 {
                local _key is _UBlist[UBindex]:tostring.
                local _key2 is _key.
                set _key to "".
                FOR i in _key2 {
                    IF NOT(i = "b") { set _key to _key+i. }
                }

                set UBindex to UBindex+1.


                local _value is _UBlist[UBindex]:tostring.

                local _value2 is _value.
                set _value to "".
                for i in _value2 {
                    IF NOT(i = "b") { set _value to _value+i. }
                }
                set UBindex to UBindex+1.

                _commitList:add(_key, _value).
            }
        }
    }
    // ill add this whenever


    local _ikey is "".
    local _ivalue is "".
    FOR i in _commitList:keys {
        EMEM_WRITE(i, _commitList[i]).
    }
}