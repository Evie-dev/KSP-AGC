runOncePath("0:/kOS AGC/Apollo/MEM/EMEM.ks").

local _lastupdt is 0.
local _padAlt is altitude.
local _nounValue is "00".
NOUN_TESTER().

LOCAL FUNCTION NOUN_TESTER {
    EMEM_CREATE("TIME0").
    EMEM_WRITE("TIME0", time:seconds).
    EMEM_CREATE("TIME2").

    EMEM_CREATE("VMAGI").
    EMEM_CREATE("HDOT").
    EMEM_CREATE("ALT1").

    NOUN_CREATE("62", LIST("VMAGI", "P"), LIST("HDOT", "P"), LIST("ALT1", "Q")).
    NOUN_CREATE("36", LIST("TIME2", "K"), LIST("TIME2", "K"), LIST("TIME2", "K")).

    UNTIL FALSE {
        local _datr is NOUN_READ(_nounValue).
        clearScreen.
        print "Verb: 16   Noun: " + _nounValue.
        print "R1: " + _datr[0].
        print "R2: " + _datr[1].
        print "R3: " + _datr[2].

        TIMR_UPDT().
        N62_UPDT().

        NN().
        wait 0.
    }
}

LOCAL FUNCTION TIMR_UPDT {
    local t0 is EMEM_READ("TIME0").
    EMEM_WRITE("TIME2", time:seconds-t0).
}

LOCAL FUNCTION NN {
    IF AG3 AND AG6 {
        set _nounValue to "36".
        ag3 off.
        ag6 off.
    } else if AG6 AND AG2 {
        set _nounValue to "62".
        ag3 off.
        ag6 off.
    }
}

LOCAL FUNCTION N62_UPDT {
    IF time:seconds > _lastupdt+2 {
        EMEM_WRITE("VMAGI", ship:velocity:surface:mag).
        EMEM_WRITE("HDOT", ship:verticalspeed).
        EMEM_WRITE("ALT1", altitude-_padAlt).
        set _lastupdt to time:seconds.
    }
}