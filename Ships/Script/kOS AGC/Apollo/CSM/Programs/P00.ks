// P00 - IDLE PROGRAM

FUNCTION P00_INIT {
    parameter asRestart is false.
    // CMC IDLE

    // General Description:

    // TERMINATES ROUTINES
    // BLANKS DISPLAYS
    // THATS IT I THINK?

    TERMINATE_ROUTINE().
    set PROGRAM_FUNCTION TO AGC_BLANKFUNC@.

    BLANK5("R1").
    BLANK5("R2").
    BLANK5("R3").
    BLANK2("VD").
    BLANK2("ND").

    EMEM_WRITE("PROGRAM", 0).
    DSKY_SETMAJORMODE("00").

}