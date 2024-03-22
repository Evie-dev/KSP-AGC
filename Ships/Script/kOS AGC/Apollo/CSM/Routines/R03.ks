// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// DAP DATA MODIFICATION

local _V04N46 IS FALSE.
LOCAL _V06N47 IS FALSE.
LOCAL _V06N48 IS FALSE.

FUNCTION R03_INIT {
    EMEM_WRITE("ROUTINE", 3).
    set _V04N46 to false.
    set _V06N47 to false.
    set _V06N48 to false.
    set ROUTINE_FUNCTION to R03_MAINBODY@.
}

LOCAL FUNCTION R03_MAINBODY {
    local rstep is EMEM_READ("ROUTINE_STEP").

    IF rstep = 0 {
        // F 04 46
        IF NOT(_V04N46) {
            DSKY_SETFLAG("DSPLOCK", false).
            NVSUB(04,46, TRUE). // but this flashes?
            set _V04N46 to true.
        }
    } ELSE IF rstep = 1 {
        IF NOT(_V06N47) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(04,47,TRUE).
            set _V06N47 to true.
        }
    } ELSE IF rstep = 2 {
        IF NOT(_V06N48) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(06, 48, TRUE).
            set _V06N48 to true.
        }
    } ELSE IF rstep = 3 {
        TERMINATE_ROUTINE().
    }
}