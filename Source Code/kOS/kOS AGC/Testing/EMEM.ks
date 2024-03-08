FUNCTION EMEM_TEST {
    runOncePath("0:/kOS AGC/Apollo/MEM/EMEM.ks").
    local t0 is time:seconds.
    local tC is time:seconds-t0.
    EMEM_CREATE("TIME0", "raw").
    EMEM_CREATE("TIME2", "K").
    EMEM_WRITE("TIME0", t0).
    EMEM_WRITE("TIME2", tC).

    UNTIL FALSE {
        clearScreen.
        print "R1: " + EMEM_READ("TIME2", false,1).
        print "R2: " + EMEM_READ("TIME2", false, 2).
        print "R3: " + EMEM_READ("TIME2", false, 3).
        UPDATE_TIMERS().
        wait 0.
    }
}

FUNCTION UPDATE_TIMERS {
    local T0 is EMEM_READ("TIME0", true).
    EMEM_WRITE("TIME2", time:seconds-T0).
}