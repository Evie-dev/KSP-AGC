// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

GLOBAL ROUTINES_ARE_AVAILABLE IS TRUE.

GLOBAL ROUTINE_PROGRESSION_INHIBIT IS FALSE.

GLOBAL ROUTINE_FUNCTION is AGC_BLANKFUNC@.

LOAD_ROUTINES().

LOCAL FUNCTION LOAD_ROUTINES {
    EMEM_WRITE("ROUTINE", -1). // if this is -1, theres no routine running!
    local _routineRout is "0:/kOS AGC/Apollo/CSM/Routines".
    cd(_routineRout).

    list files in _routineFiles.

    cd("1:/").
    local istring is "".
    FOR i in _routineFiles {
        // DO NOT SELFREF
        set istring to i:tostring.
        IF NOT(istring:contains("RoutineManager")) {
            local _iPath is _routineRout+"/"+istring.
            if istring:endswith(".ks") {
                runOncePath(_iPath).
                DEBUG_MESSAGE("PROGRAM MANAGER LOADED PROGRAM " + istring, 1).
            } ELSE {
                set _iPath to _iPath+".ks".
                runOncePath(_iPath).
                DEBUG_MESSAGE("PROGRAM MANAGER LOADED PROGRAM " + istring, 1).
            }
        }
    }
}

FUNCTION START_ROUTINE {
    parameter routineNumber is 0.
    EMEM_WRITE("ROUTINE_STEP", 0).
    IF routineNumber:istype("String") { set routineNumber to routineNumber:tonumber(0). }
    set ROUTINE_PROGRESSION_INHIBIT to false.
    SET RECYCLE_FUNCTION to DSKY_BLANKFUNC@.
    IF routineNumber = 3 {
        R03_INIT().
    } ELSE IF routineNumber = 30 {
        R30_INIT().
    } ELSE IF routineNumber = 62 {
        R62_INIT().
    }
}

FUNCTION RNEXT_STEP {
    print "rnextstep".
    EMEM_WRITE("ROUTINE_STEP", EMEM_READ("ROUTINE_STEP")+1).
}


FUNCTION TERMINATE_ROUTINE {
    parameter doSave is false.

    set ROUTINE_FUNCTION to AGC_BLANKFUNC@.
    EMEM_WRITE("ROUTINE", -1).
    DSKY_SETFLAG("MONITORKEYREL", false).
    DSKY_SETFLAG("KEYRELBYPASS", FALSE).
    DSKY_SETFLAG("NVFLASH", false).
    DSKY_SETFLAG("MONITORENTER", false).
    DSKY_SETFLAG("ENTERBYPASS", false).
    DSKY_SETFLAG("MONITORPRO", false).
    DSKY_SETFLAG("PROBYPASS", false).
    IF doSave {

    }
}