// Program 27 - CMC UPDATE PROGRAM
local _readState is 0.
local _verbSet is false.
local _verbMode is 0.


local _uplinkReadState is 0.
local _uplinkRate is 

GLOBAL _P27_AVAILABLE IS TRUE.

FUNCTION P27_INIT {
    parameter asRestart is false.
    local _currentProgram is EMEM_READ("PROGRAM").
    IF NOT(LIST(-1,0,2):contains(_currentProgram)) { return. }
    EMEM_WRITE("PROGRAM", 27).
    DSKY_SETMAJORMODE("27").
}

LOCAL FUNCTION P27_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").

    

    
    
}

FUNCTION P27_VERBSET {
    parameter md is 0.
    set _verbSet to true.
    set _verbMode to md.

    DSKY_SETFLAG("N01ECADR", 300).
    DSKY_SETFLAG("N01AUTOSEQUENTIAL", true).
    DSKY_SETFLAG("N01STEP", "DATA").
}


// simple test

LOCAL FUNCTION P27_TEST_LOGIC {

    local _actionList is LIST(
        "VERB", "7","1","ENTER",

    ).
}