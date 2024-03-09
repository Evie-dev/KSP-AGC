// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


local _V50N18 is false.
local _V06N18 is false.
local _V50N25 is false. // not implimented but here anyway
local _V06N40 is false.

local _MINUS35 is false.
local _MINUS5 is false.
local TIGN is false.

local _lastUpdate is 0.
local _updateRate is 1.

FUNCTION P40_INIT {
    parameter asRestart is false.

    EMEM_WRITE().
}

LOCAL FUNCTION P40_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").

    IF pstep = 0 {
        IF NOT(_V50N18) {
            EMEM_WRITE("THETAD", orbMech_VMN(EMEM_READ("TIG")+EMEM_READ("TIME0"), EMEM_READ("DELTAVLVCZ"), EMEM_READ("DELTAVLVCY"), EMEM_READ("DELTAVLVCX"), true)).
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(50,18, TRUE).
             set ROUTINE_PROGRESSION_INHIBIT to true.
             set _V50N18 to true.
        }
        


    } ELSE IF pstep = 1 {
        IF NOT(_V06N18) {
            SAS OFF.
            set AGC_GUIDANCE_INFORMATION:PERMIT:AUTOMNV TO TRUE.
            set AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER TO EMEM_READ("THETAD").

            DSKY_SETFLAG("DSPLOCK", FALSE).
            set ROUTINE_PROGRESSION_INHIBIT to false.
            NVSUB(06,18).
            set _V06N18 to true.
        }
        IF abs(VANG(steeringManager:target:vector, ship:facing:vector)) < 1 {
            PNEXT_STEP().
        }
    } ELSE {
        IF pstep = 2 {
            IF NOT(_V06N40) {
                DSKY_SETFLAG("DSPLOCK", FALSE).
                NVSUB(06,40).
                set _V06N40 to true.
            }

            _V06N40_UPDATE().
        } ELSE IF pstep = 3 {


            _V06N40_UPDATE().
        }
    }
}

LOCAL FUNCTION _V06N40_UPDATE {
    IF time:seconds > _lastUpdate+_updateRate {
        NVSUB(06,40).
        set _lastUpdate to time:seconds.
    }
}