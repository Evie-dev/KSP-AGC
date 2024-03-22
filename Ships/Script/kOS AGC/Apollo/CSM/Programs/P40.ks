// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// P40 variables

local _R62 is false. // for now i will use R62 which i know works

// P40 trim exists to ensure that we are on the right path, as it will ensure manuvers done at lower altitudes will be a bit more correct based upon what P30 gives
local _V50N18 is false.
local _V06N18 is false.
local _V50N25 is false. // gimbal test option* inop but it exists

local _V06N40 is false.

local _MINUS35_BLANK is false.
local _MINUS30MARK is false.

local _MINUS5_V99 is false.

local _MINUS_ZERO is false.

local _V16N40 is false.
local _V16N85 is false.

local _TIG is 0.
local _TCO is 0.

FUNCTION P40_INIT {
    parameter asRestart is false.

    set _V50N18 to false.
    set _V06N18 to false.
    set _V06N40 to false.
    set _MINUS35_BLANK to false.
    set _MINUS30MARK to false.
    set _MINUS5_V99 to false.
    set _MINUS_ZERO to false.

    set _V16N40 to false.
    set _V16N85 to false.

    set _TIG to 0.
    set _TCO to 0.

    EMEM_WRITE("PROGRAM", 40).
    DSKY_SETMAJORMODE("40").
    set PROGRAM_FUNCTION to P40_MAINBODY@.
}



LOCAL FUNCTION P40_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").
    IF pstep = 0 {
        local _tig1 is EMEM_READ("TIG").
        local _t0 is EMEM_READ("TIME0").

        local _TIG1UT is _tig1+_t0.

        local _SPSthrust is 0.
        local _SPSisp is 0.
        local _SPSflow is 0.

        local _vehicleWeight is 0.

        local _DAPDATR1 is EMEM_READ("DAPDATR1").
        local _THISWEIGHT is EMEM_READ("CSMMAS").
        local _OTHERWEIGHT is EMEM_READ("LEMMAS").

        // above values are in tonnes, but inputted in LBS

        // quick n dirty calculator for the weight thing

        // if the vehicle config isnt the saturn (3) we procede

        local _wMass is 0.

        local _vehicleConfig is _DAPDATR1[0]:tonumber(0).

        IF _vehicleConfig = 1 {
            // CSM ONLY
            set _wMass to _THISWEIGHT.
        } ELSE IF _vehicleConfig = 2 or _vehicleConfig = 6 {
            set _wMass to _THISWEIGHT+_OTHERWEIGHT.
        }

        local _dv is EMEM_READ("DELTAVLVC"):mag.
        local _ve is _SPSisp*constant:g0.
        local _tr is _SPSthrust.

        set _SPSflow to _tr/_ve.
        local m0 is _wMass.
        local m1 is m0/constant:e^(_dv/_ve).

        local mp5 is m0-m1.
        local _bT is mp5/_SPSflow.

        local _newTIG is _TIG1UT-(0.5*_bT).
        set _TIG to _newTIG.
        set _TCO to _TIG+_bT.
        
        local _TIG0 is _TIG-_t0.
        EMEM_WRITE("TIG", _TIG0).

        PNEXT_STEP().
    }
    ELSE IF pstep = 1 {
        IF NOT(_R62) {
            START_ROUTINE(62).
            set _R62 TO true.
        } ELSE {
            IF EMEM_READ("ROUTINE") = -1 {
                PNEXT_STEP().
            }
        }
    } ELSE IF pstep = 2 {
        IF NOT(_V06N40) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(6, 40).
            set _V06N40 to true.
        }
        IF _TIG-time:seconds <= 5 {
            PNEXT_STEP().
        }
        
    } ELSE IF pstep = 3 {
        IF NOT(_MINUS5_V99) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(99,40, TRUE).
            set _MINUS5_V99 to true.
            set PROGRAM_PROGRESSION_INHIBIT to false.
        }
    } ELSE IF pstep = 4 {
        IF NOT(_MINUS_ZERO) {
            set PROGRAM_PROGRESSION_INHIBIT to TRUE.
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(6,40).
            set _MINUS_ZERO to true.
            lock throttle to 1.
        }

    }
}
local _lastP40update is time:seconds.
local _p40updateinterval is 1.


LOCAL FUNCTION P40_STEP2_PLUS_UPDATE_DISPLAY {
    
    IF time:seconds >= _lastP40update+5 {
        IF _TIG-TIME:SECONDS <= 35 and _TIG-TIME:SECONDS >= 30  {
            BLANK5("R1").
            BLANK5("R2").
            BLANK5("R3").
        } ELSE {
            NVSUB(6,40).
        }
    }
}