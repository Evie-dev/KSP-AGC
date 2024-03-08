// Interupts

runOncePath("0:/kOS AGC/Apollo/MEM/EMEM.ks").
FUNCTION TIMR_UPDATE {
    parameter time0 is EMEM_READ("TIME0").

    local time2 is time:seconds-time0.
    local tevent is EMEM_READ("TEVENT").
    IF NOT(tevent = 0) {
        // update TTOGO

        EMEM_WRITE("TTOGO", time2-tevent).
    }

    EMEM_WRITE("TIME2", time2).
}