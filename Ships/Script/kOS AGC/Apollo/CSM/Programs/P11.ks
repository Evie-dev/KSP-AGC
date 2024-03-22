
// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

local _P11refresh is 2. // 1 refresh every 2 seconds
local _P11lastrefresh is 0.

local FL3000 is convertUnit("ft", "me", 300_000).

local alti is 0.
local vmagi is 0.
local padalti is 0.
local hdot is 0.


local isProbably_SIVB is FALSE.
FUNCTION P11_INIT {
    parameter asRestart is false.
    IF LIST("LANDED", "SPLASHED", "PRELAUNCH"):contains(SHIP:STATUS) { return. }

    // we are flying!

    EMEM_WRITE("PROGRAM", 11).
    DSKY_SETMAJORMODE("11").

    IF NOT(asRestart) {
        EMEM_WRITE("TIME0", time:seconds).
        EMEM_WRITE("PROGRAM_STEP", 0).
    }
    EMEM_WRITE("PADALTI", altitude).
    DSKY_SETFLAG("DSPLOCK", false).
    set PROGRAM_FUNCTION to P11_MAINBODY@.
}

LOCAL FUNCTION P11_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").
    P11_VARUPDATER().

    // EVENTUALLY I SHALL HAVE STEPS BASED UPON DIFFERENT ABORT MODES


    IF pstep = 0 {
        P11_DISPLAY().
        IF altitude > FL3000 {
            PNEXT_STEP().
        }
    } ELSE IF pstep = 1 {
        IF mass < 200 and maxthrust = 0 {
            
        }
        IF EMEM_READ("ROUTINE") = 30  {
            P11_DISPLAY().
        } 
    }
}

LOCAL FUNCTION P11_VARUPDATER {
    EMEM_WRITE("VMAGI", ship:velocity:surface:mag).
    EMEM_WRITE("HDOT", ship:verticalspeed).
    EMEM_WRITE("ALTI", altitude-EMEM_READ("PADALTI")).
}

LOCAL FUNCTION P11_DISPLAY {
    // display stuff
    IF time:seconds >= _P11lastrefresh+_P11refresh {
        NVSUB(6, 62).
        set _P11lastrefresh to time:seconds.
    }
}



// ABORT MODES


// BASED UPON THIS

// https://ntrs.nasa.gov/api/citations/19720017278/downloads/19720017278.pdf
// and
// https://ntrs.nasa.gov/api/citations/19730010175/downloads/19730010175.pdf


