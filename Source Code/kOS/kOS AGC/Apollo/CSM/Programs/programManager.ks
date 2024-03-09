// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


GLOBAL PROGRAMS_ARE_AVAILABLE IS TRUE.

GLOBAL PROGRAM_PROGRESSION_INHIBIT IS TRUE. // by default enabled because most programs require automatic progression

GLOBAL PROGRAM_FUNCTION IS AGC_BLANKFUNC@.

LOAD_PROGRAMS().

LOCAL FUNCTION LOAD_PROGRAMS {
    local _progRoot is "0:/kOS AGC/Apollo/CSM/Programs".
    CD(_progRoot).
    list files in _programFileList.
    CD("1:/").
    local istring is "".
    FOR i in _programFileList {
        set istring to i:tostring.
        IF NOT(istring:contains("programManager")) {
            // DO NOT SELFREF
            local _iPath is _progRoot+"/"+istring.
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


FUNCTION CHANGE_PROGRAM {
    parameter programNumber is -1, asRestart is false.
    set PROGRAM_FUNCTION to AGC_BLANKFUNC@.
    IF NOT(asRestart) {
        EMEM_WRITE("PROGRAM_STEP", 0).
    }
    IF programNumber:istype("String") { set programNumber to programNumber:tonumber(-1). }
    set PROGRAM_PROGRESSION_INHIBIT to true.
    IF programNumber = 0 {
        P00_INIT(asRestart).
    } ELSE IF programNumber = 1 {
        P01_INIT(asRestart).
    } ELSE IF programNumber = 2 {
        P02_INIT(asRestart).
    }
    ELSE IF programNumber = 11 {
        P11_INIT(asRestart).
    } ELSE IF programNumber = 27 {
        //P27_INIT(). <- DO NOT
    } 
    ELSE IF programNumber = 30 {
        P30_INIT(asRestart).
    } ELSE IF programNumber = 40 {
        P40_INIT(asRestart).
    }
}

FUNCTION PNEXT_STEP {
    EMEM_WRITE("PROGRAM_STEP", EMEM_READ("PROGRAM_STEP")+1).
}

FUNCTION GOTO_P00H {
    set PROGRAM_FUNCTION to AGC_BLANKFUNC@.
    set RECYCLE_FUNCTION to DSKY_BLANKFUNC@.
    DSKY_SETFLAG("DSPLOCK", false).
    DSKY_SETFLAG("MONFLAG", FALSE).
    EMEM_WRITE("PROGRAM", -1).
    DSKY_SETFLAG("AWAITREL", FALSE).
    BLANK2("VD").
    BLANK2("ND").
    DSKY_SETDISPLAYDATA(LEXICON("VD", "37")).
    DSKY_DOACTION("PROCESS VERB").
}