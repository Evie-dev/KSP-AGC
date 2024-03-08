// EXTENDED VERBS

GLOBAL EXTENDED_VERBS_ARE_AVAILABLE IS TRUE. // tells the DSKY program that EVERBS are available

FUNCTION VERB_PROCESSOR_EXTENDED {
    parameter processingVerb is "00".

    IF processingVerb:istype("Scalar") { set processingVerb to processingVerb:tostring. }
    ELSE IF NOT(processingVerb:istype("String")) { return. }

    IF processingVerb = 48 {
        START_ROUTINE(3).
    } ELSE IF processingVerb = 49 {
        START_ROUTINE(62).
    } ELSE IF processingVerb = 55 {
        // CMC DELTATIME UPDATE
        DSKY_SETFLAG("DSPLOCK", FALSE).
        NVSUB(06, 24).
        DSKY_SETFLAG("DSPLOCK", FALSE).
        NVSUB(25, 24).
    }
    ELSE IF processingVerb = 69 {
        DSKY_INDICATOR(7, true).
        DSKY_SETFLAG("MONFLAG", FALSE).
        local reboottime is time:seconds+6.
        when time:seconds > reboottime then {
            EMEM_CREATE("INDOUT").
            EMEM_WRITE("INDOUT", INDOUT).
            EMEM_SAVE().
            reboot.
        }
        
        // nice
    }
    // 70, 71 and 72 moved
    ELSE IF processingVerb = 74 {
        EMEM_SAVE().
    } ELSE IF processingVerb = 75 {
        // backup liftoff
        CHANGE_PROGRAM(11).
    } ELSE IF processingVerb = 82 {
        START_ROUTINE(30).
    }

    ELSE IF EMEM_READ("PROGRAM") = 27 {
        IF processingVerb = 70 {
            P27_VERBSET(0).
        } ELSE IF processingVerb = 71 {
            P27_VERBSET(1).
        } ELSE IF processingVerb = 72 {
            P27_VERBSET(2).
        }
    }


    // special P27 BLOCK

    IF DEFINED PROGRAMS_ARE_AVAILABLE {
        IF EMEM_READ("PROGRAM") = 27 {
            IF processingVerb = 70 {
                // liftoff stuff
            } ELSE IF processingVerb = 71 {
                // contiguous data
            } ELSE IF processingVerb = 72 {
                // non-contiguous
            }
        }
    }
}