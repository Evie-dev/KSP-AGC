// settings loader, uses kOSAGCextras
GLOBAL _KOSAGCVERSION IS "0.1". // used to determine how we load the memory structure (DO NOT CHANGE THIS UNLESS YOU WANT TO EXPERIMENT OR REALLY MESS STUFF UP!)


// Debug priority scheme:

// 1- MINIMAL, ONLY CRITICAL INFO IS LOGGED
// 5 - ALL THINGS ARE LOGGED
GLOBAL debugPriority is 5. 
GLOBAL kOSAGCCONFIG is lexicon(
    "UNITS", TRUE,
    "REFRATE", TRUE,
    "CHUNK", FALSE,
    "JSONoutput", FALSE,
    "TERMinput", FALSE
).
IF NOT(addons:AGC:Available) {
    local terminalPart is core:part.
    clearScreen.
    print "KOS AGC EXTRAS ADDON NOT LOCATED!".
    print "kOS AGC WILL WORK CORRECTLY, HOWEVER WILL HAVE LIMITATIONS TO ITS FULL OPERATION!".
    print "kOS AGC EXTRAS SHOULD BE BUNDLED WITH THE .ZIP CONTAINING THESE SCRIPTS, HOWEVER IF NOT.  CONTACT ME AND ALSO DOWNLOAD THEM FROM THE REPO".
    print "FOR YOUR CONVENIENCE I HAVE CREATED A FILE WITH THE LINK!".
    FOR i in terminalPart:modules {
        IF terminalPart:getmodule(i):hasevent("Open Terminal") {
            terminalPart:getmodule(i):doevent("Open Terminal").
        }
    }
    print "FULL DESCRIPTION OF LIMITATIONS: ".
    print "YOU WILL HAVE TO USE AG1 OR AG2 TO ACCESS THE GUI".
    print "THERE IS NO OPTION TO OUTPUT DATA OR READ FROM THE TERMINAL".
    print "LOCKED TO HISTORICAL UNIT CONFIG".
    print "LOCKED TO HISTORICAL REFRESH RATE".
    print "CHUNK LOADING NOT ACTIVE".
} ELSE {
    set kOSAGCCONFIG:UNITS to ADDONS:AGC:UNITS.
    set kOSAGCCONFIG:REFRATE to ADDONS:AGC:REFRATE.
    set kOSAGCCONFIG:CHUNK to ADDONS:AGC:REFTYPE.
    set kOSAGCCONFIG:JSONoutput to ADDONS:AGC:JSONoutput.
    set kOSAGCCONFIG:TERMinput to ADDONS:AGC:TERMINALINPUT.
}