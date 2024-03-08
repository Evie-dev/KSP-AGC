
local _P11refresh is 2. // 1 refresh every 2 seconds
local _P11lastrefresh is 0.

local FL3000 is convertUnit("ft", "me", 300_000).

local alti is 0.
local vmagi is 0.
local padalti is 0.
local hdot is 0.

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
    P11_DISPLAY().
    IF pstep = 0 {
        IF altitude > FL3000 {
            PNEXT_STEP().
        }
    } ELSE IF pstep = 1 {
        
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