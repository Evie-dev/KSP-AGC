// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


local _V06N33 is false.
local _V06N81 is false.
local _V06N42 is false.
local _V16N45 is false.

FUNCTION P30_INIT {
    parameter asRestart is false.
    set _V06N33 to false.
    set _V06N42 to false.
    set _V06N81 to false.
    set _V16N45 to false.

    // temporary thing

    IF hasnode {
        local _nd is nextNode.

        local _x is _nd:prograde.
        local _y is _nd:normal.
        local _z is _nd:radialout.

        local _TIG is _nd:TIME-EMEM_READ("TIME0").

        EMEM_WRITE("TIG", _TIG).
        EMEM_WRITE("DETLAVLVC", v(_z,_y,_x)).

        remove _nd.
    } ELSE {
        return.
    }
    EMEM_WRITE("PROGRAM", 30).
    DSKY_SETMAJORMODE("30").
    set PROGRAM_FUNCTION to P30_MAINBODY@.
    set PROGRAM_PROGRESSION_INHIBIT to false.
}

LOCAL FUNCTION P30_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").

    IF pstep = 0 {
        IF NOT(_V06N33) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(6, 33, TRUE).
            set _V06N33 to true.
        }
        
    } ELSE IF pstep = 1 {
        IF NOT(_V06N81) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(6, 81, TRUE).
            set _V06N81 to true.
        }
    } ELSE IF pstep = 2{
        // calculations
        EMEM_WRITE("TEVENT", EMEM_READ("TIG")).
        local _tig_ut is EMEM_READ("TIG")+EMEM_READ("TIME0").
        local _nodeData is orbMech_VMN(_tig_ut, EMEM_READ("DELTAVLVCZ"), EMEM_READ("DELTAVLVCY"), EMEM_READ("DELTAVLVCX"), false).

        EMEM_WRITE("DVTOTAL", _nodeData:V2:mag).
        EMEM_WRITE("VGDISP", _nodeData:V1:mag-nodeData:V2:mag).
        EMEM_WRITE("HAPO", _nodeData:COE:Apoapsis:a).
        EMEM_WRITE("HPER", _nodeData:COE:Periapsis:a).
        PNEXT_STEP().
    } ELSE IF pstep = 3 {
        IF NOT(_V06N42) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(6, 42).
            set _V06N42 to true.
        }
    } ELSE IF pstep = 4 {
        IF NOT(_V16N45) {
            DSKY_SETFLAG("DSPLOCK", FALSE).
            NVSUB(16, 45).
            set _V16N45 TO TRUE.
        }
    }
}