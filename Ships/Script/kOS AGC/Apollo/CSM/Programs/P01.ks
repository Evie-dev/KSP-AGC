// PROGRAM 1 - Honestly somewhat useless at the moment

local IMUbaseAlignmenttime is 90. // the default alignment time
local IMUalignment_randomness is 10. // the alignment time that we can vary by (+/-) () also used as the switchover time

local IMUalignmentTime is 0.
local IMUalignmentAdditor is 0.
local _noattflag is false.

local step2time is 0.
local IMUrandomnmess is 0.

FUNCTION P01_INIT {
    parameter asRestart is false.
    // TODO: NODOP01 flag!
    EMEM_WRITE("PROGRAM", 1).
    DSKY_SETMAJORMODE("01").
    set IMUalignmentAdditor to IMUalignment_randomness*2.
    set IMUalignmentTime to IMUbaseAlignmenttime.

    set IMUrandomnmess to IMUalignmentAdditor*random().
    set IMUrandomnmess to IMUrandomnmess-IMUalignment_randomness.
    set IMUalignmentTime to IMUalignmentTime+IMUrandomnmess.
    set IMUalignmentTime to time:seconds+IMUalignmentTime.
    set step2time to IMUalignmentTime+IMUalignment_randomness.
    print "IMU ALIGNMENT: " + (IMUalignmentTime-time:seconds):tostring.
    print "RANDOMNESS: " + IMUrandomnmess.
    print "PROGRAM 2 IN: " + (step2time-time:seconds):tostring.
    set PROGRAM_FUNCTION to P01_MAINBODY@.
}



LOCAL FUNCTION P01_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").
    IF pstep = 0 {
        IF NOT(_noattflag) {
            DSKY_INDICATOR(2, true).
            set _noattflag to true.
        }

        IF time:seconds >= IMUalignmentTime {
            PNEXT_STEP().
        }
    } ELSE IF pstep = 1 {
        IF _noattflag {
            DSKY_INDICATOR(2, false).
            set _noattflag to false.
        }
        IF time:seconds >= step2time {
            print "step2".
            PNEXT_STEP().
        }
        
    } ELSE IF pstep = 2 {
        // go to P02
        print "P02".
        CHANGE_PROGRAM(2).
    }
}