// Program 27 - CMC UPDATE PROGRAM
local _readState is 0.
local _verbSet is false.
local _verbMode is 0.


local _uplinkReadState is 0.
local _uplinkRate is 2. // unsure for now
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

    IF pstep < 3 { UPLINK_CONTROLLER(). }
    IF pstep = 0 {
        // VERBSET
        
        IF _verbSet {
            PNEXT_STEP().
        }

    } ELSE IF pstep = 1 {
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

    } ELSE IF pstep = 3 {
        print "complete...".
    }
    

    
    
}

LOCAL FUNCTION UPLINK_CONTROLLER {
    IF TIME:SECONDS > _lastUplink+_lastUplinkRate {
        IF EXISTS("0:/kOS AGC/Apollo/CSM/P27uplink.json") {
            local _p27Uplink is READJSON("0:/kOS AGC/Apollo/CSM/P27uplink.json").

            UPLINK_INPUT(_p27Uplink[_uplinkReadState]).
            IF _p27Uplink[_uplinkReadState] = "1 11111 00000 11111" { 
                set _dataState to _dataState+1.
                set _lastUplinkRate to 2.
                } ELSE {
                    set _lastUplinkRate to _uplinkRate.
                }
            set _uplinkReadState to _uplinkReadState+1.

            IF _uplinkReadState > _p27Uplink:length-1 {
                P27_COMPLETE().
            }
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
        "+12",
        "+3065",
        "+11111",
        "+3066",
        "+11111",
        "+3072",
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