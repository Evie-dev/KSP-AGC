// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


// for now P27 will:

// 

FUNCTION P27_INIT {
    
    IF hasnode {
        local _nd is nextNode.

        local _x is _nd:prograde.
        local _y is _nd:normal.
        local _z is _nd:radialout.

        local _TIG is _nd:TIME-EMEM_READ("TIME0").

        EMEM_WRITE("TIG", _TIG).
        EMEM_WRITE("TIG_INST", _TIG).
        EMEM_WRITE("DELTAVLVC", v(_z,_y,_x)).

        wait 1.

        remove _nd.
    } ELSE {
        return.
    }

    EMEM_SAVE(). // mandatory hardcoded savepoint
}