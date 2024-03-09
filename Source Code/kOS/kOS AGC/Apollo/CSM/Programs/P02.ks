// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// PROGRAM 2

// Sets up the LIFTOFF DISCRITE LISTENER
// Setsup the 

local groundedList is LIST("PRELAUNCH", "LANDED", "SPLASHED").

FUNCTION P02_INIT {
    parameter asRestart is false.

    EMEM_WRITE("PROGRAM", 2).
    DSKY_SETMAJORMODE("02").

    set PROGRAM_FUNCTION to P02_MAINBODY@.
    
    when NOT(groundedList:contains(SHIP:STATUS)) then {
        CHANGE_PROGRAM(11).
    }
}


LOCAL FUNCTION P02_MAINBODY {

}