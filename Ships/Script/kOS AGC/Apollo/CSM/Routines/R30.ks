// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// R30 - Orbit parameter display

local averG is true. // locked to true, for now until i impliment a proper flag system

LOCAL _V04N12 is false. // Option code not currently implimented, however will probably be soon
local _V16N44 is false.

local _V16N50 is false. // No bloody clue lmao
local _V16N32 is false.

local _monstart is false.
local _sentAkeyrel is false.

local _forvech is "CSM".
FUNCTION R30_INIT {
    set _V04N12 to true. // for now as this isnt implimented
    set _V16N44 to false.
    set _V16N32 to false.
    set _V16N50 to false.
    set _monstart to false.

    EMEM_WRITE("ROUTINE", 30).
    
    set ROUTINE_FUNCTION to R30_MAINBODY@.
}

LOCAL FUNCTION R30_MAINBODY {
    local rstep is EMEM_READ("ROUTINE_STEP").

    IF rstep = 0 {
        IF NOT(_V04N12) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
        }
        RNEXT_STEP(). // for now!
    } ELSE IF rstep = 1 {
        R30_CALC().
        RNEXT_STEP().
    } ELSE IF rstep = 2 {
        // ok so here we display N44, but we check if the noun is 50 and the keyrelease has been pressed
        IF NOT(_V16N44) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(16, 44, TRUE).
        }
        IF NOT(_monstart) {
            DSKY_SETFLAG("MONITORKEYREL", true).
        }
        local cNoun is DKSY_GETDISPLAYDATA("ND").
        IF cNoun = "50" or cNoun = "32" {
            IF NOT(DSKY_GETFLAG("NVFLASH")) { DSKY_SETFLAG("NVFLASH", TRUE). }
            IF NOT(_sentAkeyrel) {
                NVSUB(16, 44, true).
                set ROUTINE_PROGRESSION_INHIBIT to true. // ??? maybe
                set _sentAkeyrel to true.
            }
        } ELSE IF _sentAkeyrel { set _sentAkeyrel to false. }
    } ELSE IF rstep = 3 {
        TERMINATE_ROUTINE().
    }
}

LOCAL FUNCTION R30_CALC {
    local currentCOE is orbMech_coe().
    EMEM_WRITE("HAPOX", currentCOE:Apoapsis:A).
    EMEM_WRITE("HPERX", currentCOE:Periapsis:A).
    EMEM_WRITE("TFF", orbMech_Period(currentCOE:semimajoraxis)).
    EMEM_WRITE("TPER", EMEM_READ("TIME2")+eta:periapsis).
}