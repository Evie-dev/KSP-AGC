// before we do anything
GLOBAL AGC_GUIDANCE_INFORMATION IS LEXICON(
    "PERMIT", LEXICON("AUTOMNV", FALSE, "IGNITION", FALSE),
    "CONTROLINFO", LEXICON("STEER", ship:facing, "STEER_LOCKED", FALSE, "THROTTLE", 0)
).


DEBUG_MESSAGE("GUIDANCE COMPUTER IN MAIN.ks").
clearguis().
runOncePath("0:/kOS AGC/settings.ks").
AGC_CSM_INIT().

LOCAL FUNCTION AGC_CSM_INIT {
    runOncePath("0:/kOS AGC/Apollo/MEM/EMEM.ks").
    runOncePath("0:/kOS AGC/Apollo/GUI/DSKY.ks").
    
    runOncePath("0:/kOS AGC/Apollo/CSM/Erasable Assignments.ks").
    runOncePath("0:/kOS AGC/Apollo/CSM/extended verbs.ks").
    runOncePath("0:/kOS AGC/Apollo/CSM/Interupts.ks").

    
    runOncePath("0:/kOS AGC/Apollo/CSM/Routines/routineManager.ks").
    runOncePath("0:/kOS AGC/Apollo/CSM/Programs/programManager.ks").
    setAGCtextures().
    UNTIL FALSE {
        DSKY_UPDATE().
        TIMR_UPDATE().
        DAP_MANV_TESTER().
        PROGRAM_FUNCTION:call.
        ROUTINE_FUNCTION:call.
        wait 0.
    }
}

LOCAL FUNCTION DAP_MANV_TESTER {
    IF NOT(SAS) {
        IF AGC_GUIDANCE_INFORMATION:PERMIT:AUTOMNV {
            if not(AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER_LOCKED) { 
                LOCK STEERING TO AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER.
                set AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER_LOCKED to true.
            }
        }
    } ELSE IF AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER_LOCKED {
        set AGC_GUIDANCE_INFORMATION:CONTROLINFO:STEER_LOCKED TO FALSE.
        UNLOCK STEERING.
    }
}


FUNCTION DEBUG_MESSAGE {
    parameter msg is "", msgPriority is 1.
    IF NOT(DEFINED debugPriority) {
        kuniverse:debuglog("[kOS AGC (kOS)] " + msg).
    } ELSE IF msgPriority < debugPriority {
        kuniverse:debuglog("[kOS AGC (kOS)] " + msg).
    }
    
}

FUNCTION AGC_BLANKFUNC {
}