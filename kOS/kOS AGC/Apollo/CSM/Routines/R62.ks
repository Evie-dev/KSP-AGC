
local _steerDB is 5.

local _V06N22 IS FALSE.
local _V50N18 is false.
local _V06N18 is false.
local _V50N18trim is false.

local _trimRequest is false.

FUNCTION R62_INIT {
    set _V06N22 to false.
    set _V06N18 to false.
    set _V50N18 to false.
    set _V50N18trim to false.

    set _trimRequest to false.


    EMEM_WRITE("ROUTINE", 62).

    set ROUTINE_FUNCTION TO R62_MAINBODY@.
    
}

LOCAL FUNCTION R62_MAINBODY {
    local rstep is EMEM_READ("ROUTINE_STEP").

    IF rstep = 0 {
        // F 06 22 
        IF NOT(_V06N22) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(06, 22, TRUE).
            set _V06N22 to true.
        }
    }
    ELSE IF rstep = 1 {
        // request to manuver...
        IF NOT(_V50N18) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(50, 18, TRUE).
            set _V50N18 to true.
        }
    } ELSE IF rstep = 2 {
        // enable automanuver
        SAS OFF.
        set AGC_GUIDANCE_INFORMATION:PERMIT:AUTOMNV TO TRUE.
        set AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER TO EMEM_READ("THETAD").
        RNEXT_STEP().
    } ELSE IF rstep = 3 {
        IF NOT(_V06N18) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(06, 18, false).
            set ROUTINE_PROGRESSION_INHIBIT to true.
            set _V06N18 to true.
        }
        IF NOT(_trimRequest) {
            // FOR NOW DEADBAND LOCKED AT 5
            IF ABS(VANG(SHIP:FACING:VECTOR, steeringManager:target:VECTOR)) < _steerDB {
                set AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER to "kill".
                RNEXT_STEP().
            }
        }
    } ELSE IF rstep = 4 {
        IF NOT(_V50N18trim) {
            DSKY_SETFLAG("MONITORENTER", true).
            DSKY_SETFLAG("ENTERBYPASS", true).
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(50, 18, TRUE).
            SET ROUTINE_PROGRESSION_INHIBIT TO FALSE.
            set _V50N18trim to true.
        }

        IF DSKY_GETFLAG("ENTER") {
            TERMINATE_ROUTINE().
        }
    } ELSE IF rstep = 5 {
        set _trimRequest to true.
        set _V06N18 to false.
        set _V50N18trim to false.
        EMEM_WRITE("ROUTINE_STEP", 3). // GOTO4
    }
}