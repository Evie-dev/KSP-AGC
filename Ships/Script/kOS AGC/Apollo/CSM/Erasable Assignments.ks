// Special file for the initilization of erasable assigning


// A note on the assignments of the proper addresses
// In making this i have consulted numerous documents to deduce the arraingement of the addresses used within the AGC,
// most notibly and usable are the multiple prelaunch pad erasables https://www.ibiblio.org/apollo/links2.html#PadLoads&gsc.tab=0
// and the https://www.ibiblio.org/apollo/NARA-SW/R-577-sec2-rev2.pdf document describing uplinks
ASSIGN_ERASABLES().

FUNCTION ERASABLE_FRESH_START {
    ASSIGN_ERASABLES(true).
}
LOCAL FUNCTION ASSIGN_ERASABLES {
    parameter freshStart is false.
    local _MEMset is false.
    local _FRESHset is false.

    


    local _loadSuccessEMEM is false.
    local _loadSuccessNOUN is false.
    local _loadSuccessADDRESS is false.

    local _expectedVersion is _KOSAGCVERSION.


    IF NOT(EMEM_DEBUG) and NOT(freshStart) {
        set _loadSuccessEMEM to EMEM_LOAD("EMEM").
        set _loadSuccessNOUN to EMEM_LOAD("NOUN").
        set _loadSuccessADDRESS to EMEM_LOAD("ADDRESS").
        // quick check to see if we are in a debug mode for the memory
        IF _loadSuccessADDRESS and (_loadSuccessNOUN and _loadSuccessEMEM) {
            local _foundVersionADDR is "THIS ISNT A VERSION RECOGNISED".
            local _foundVersionNOUN is "THIS ISNT A VERSION RECOGNISED".
            local _foundVersionEMEM is "THIS ISNT A VERSION RECOGNISED".
            // check all three
            IF ADDRASSIGN:haskey("kOS AGC version") {
                set _foundVersionADDR to ADDRASSIGN["kOS AGC version"].
            }
            IF EMEM:haskey("kOS AGC version") {
                set _foundVersionEMEM to EMEM["kOS AGC version"].
            }
            IF VNMEM:haskey("kOS AGC version") {
                set _foundVersionNOUN to VNMEM["kOS AGC version"].
            }

            local fList is LIST(_foundVersionADDR,_foundVersionEMEM,_foundVersionNOUN).
            IF NOT(fList:contains("THIS ISNT A VERSION RECOGNISED")) {
                set fList to LIST().
                IF (_foundVersionADDR = _foundVersionNOUN) and ((_foundVersionNOUN = _foundVersionEMEM) and (_foundVersionADDR = _foundVersionEMEM)) {
                    // all are equal, now test the version
                    IF _foundVersionADDR = _expectedVersion {
                        IF EMEM:HASKEY("INDOUT") { DSKY_SETINDICATORDATA(EMEM_READ("INDOUT")). }
                        return.
                    }
                }
            }
        }
    }
    // otherwise, clear all three
    set EMEM to LEXICON().
    set ADDRASSIGN to LEXICON().
    set VNMEM to LEXICON().

    local t0 is time:seconds.
    local ddap is "00000".

    //LEXICON("NOUN", 36, "R1", LIST("TIME2", "K"), "R2", LIST("TIME2", "K"), "R3", LIST("TIME2", "K")),

    local NL is list().
    // Erasable Assignments based on NOUN


    // N01-N03
    EMEM_CREATE("N01_INPUT",true).
    EMEM_CREATE("N01_ECADR",true).
    local N01 is LEXICON("NOUN", 1, "R1", LIST("N01_INPUT", "A"), "R3", LIST("N01_ECADR", "A")).
    NL:add(N01).
    // N18

    EMEM_CREATE("THETAD").
    local N18 is LEXICON("NOUN", 18, "R1", LIST("THETAD_YAW", "D"), "R2", LIST("THETAD_PITCH", "D"), "R3", LIST("THETAD_ROLL", "D")).
    NL:ADD(N18).
    // N20

    EMEM_CREATE("CDU").
    local N20 is LEXICON("NOUN", 20, "R1", LIST("CDU_YAW", "D"), "R2", LIST("CDU_PITCH", "D"), "R3", LIST("CDU_ROLL", "D")).
    NL:ADD(N20).
    // N21 (unsure)

    // N22

    local N22 is N18:COPY.

    set N22:NOUN to 22.
    NL:add(N22).

    // N24

    EMEM_CREATE("TIME0").

    local N24 is LEXICON("NOUN", 24, "R1", LIST("TIME0", "K2"), "R2", LIST("TIME0", "K2"), "R3", LIST("TIME0", "K2")).

    // 32

    EMEM_CREATE("TPER").

    local N32 IS LEXICON("NOUN", 32, "R1", LIST("TPER", "K"), "R2", list("TPER", "K"), "R3", LIST("TPER", "K")).
    NL:ADD(N32).
    // N33

    EMEM_CREATE("TIG").
    local N33 IS LEXICON("NOUN", 33, "R1", LIST("TIG", "K"), "R2", list("TIG", "K"), "R3", LIST("TIG", "K")).
    NL:ADD(N33).
    // n34 - unsure of implimentation, but i have some vauge idea?

    EMEM_CREATE("TEVENT").
    local N34 is LEXICON("NOUN", 34, "R1", LIST("TEVENT", "K"), "R2", LIST("TEVENT", "K"), "R3", LIST("TEVENT", "K")).
    NL:ADD(N34).
    
    // N35

    EMEM_CREATE("TTOGO").
    local N35 IS LEXICON("NOUN", 35, "R1", LIST("TTOGO", "K"), "R2", LIST("TTOGO", "K"), "R3", LIST("TTOGO", "K")).
    NL:ADD(N35).
    // 36

    EMEM_CREATE("TIME2").
    local N36 is LEXICON("NOUN", 36, "R1", LIST("TIME2", "K"), "R2", LIST("TIME2", "K"), "R3", LIST("TIME2", "K")).
    NL:ADD(N36).
    // 40

    //TTOOGO
    EMEM_CREATE("VGDISP").
    EMEM_CREATE("DVTOTAL").

    local N40 is LEXICON("NOUN", 40, "R1", LIST("TTOGO", "L"), "R2", LIST("VGDISP", "S"), "R3", LIST("DVTOTAL", "S")).
    NL:ADD(N40).

    // 42

    EMEM_CREATE("HAPO").
    EMEM_CREATE("HPER").
    //VGDISP

    local N42 is LEXICON("NOUN", 42, "R1", LIST("HAPO", "Q"), "R2", LIST("HPER", "Q"), "R3", LIST("VGDISP", "S")).
    NL:ADD(N42).
    // 43

    EMEM_CREATE("LAT").
    EMEM_CREATE("LONG").
    EMEM_CREATE("ALT"). // idk tbh

    local N43 is LEXICON("NOUN", 43, "R1", LIST("LAT", "F"), "R2", LIST("LONG", "F"), "R3", LIST("ALT", "Q")).

    NL:ADD(N43).

    // 44

    EMEM_CREATE("HAPOX").
    EMEM_CREATE("HAPERX").
    EMEM_CREATE("TFF").

    local N44 is LEXICON("NOUN", 44, "R1", LIST("HAPOX", "Q"), "R2", LIST("HPERX","Q"), "R3", LIST("TFF", "L")). // #blessed
    NL:ADD(N44).
    // 45

    EMEM_CREATE("VHFCNT").
    // TTOGO
    EMEM_CREATE("MGA").

    local N45 is LEXICON("NOUN", 45, "R1", LIST("VHFCNT", "PP"), "R2", LIST("TTOGO", "L"), "R3", LIST("MGA", "H")).
    NL:ADD(N45).
    // 46

    EMEM_CREATE("DAPDATR1", true).
    EMEM_CREATE("DAPDATR2", true).

    local N46 is lexicon("NOUN", 46, "R1", LIST("DAPDATR1", "A"), "R2", LIST("DAPDATR2", "A")).
    NL:ADD(N46).
    // 47

    EMEM_CREATE("CSMMAS").
    EMEM_CREATE("LEMMAS").

    local N47 is LEXICON("NOUN", 47, "R1", LIST("CSMMAS", "KK"), "R2", LIST("LEMMAS", "KK")).
    NL:ADD(N47).
    // 48

    EMEM_CREATE("PACTOFF").
    EMEM_CREATE("YACTOFF").
    
    local N48 is LEXICON("NOUN", 48, "R1", LIST("PACTOFF", "F"), "R2", LIST("YACTOFF", "F")).
    NL:ADD(N48).
    // 62

    EMEM_CREATE("VMAGI").
    EMEM_CREATE("HDOT").
    EMEM_CREATE("ALTI").

    local N62 is LEXICON("NOUN", 62, "R1", LIST("VMAGI", "P"), "R2", LIST("HDOT", "P"), "R3", LIST("ALTI", "Q")).
    NL:ADD(N62).
    // N65

    local N65 is N36:copy.

    SET N65:NOUN TO 65.

    NL:ADD(N65).

    // N80

    // TTOGO
    // VGDISP
    // DVTOTAL

    // acctually just noun 40 with a few differences


    local N80 is N40:COPY.
    set N80:R2 TO LIST("VGDISP", "P").
    SET N80:R3 TO LIST("DVTOTAL", "P").

    SET N80:NOUN TO 80.

    NL:ADD(N80).

    // N81/N82/N86

    EMEM_CREATE("DELTAVLVC").

    local N81 IS LEXICON("NOUN", 81, "R1", LIST("DELTAVLVCZ", "S"), "R2", LIST("DELTAVLVCY", "S"), "R3", LIST("DELTAVLVCX", "S")).
    NL:ADD(N81).
    local N82 is N81:COPY.
    SET N82:NOUN TO 82.
    NL:ADD(N82).


    // N83

    EMEM_CREATE("DELTAVBOD").

    local N83 is LEXICON("NOUN", 83, "R1", LIST("DELTAVBODZ", "S"), "R2", LIST("DELTAVBODY", "S"), "R3", LIST("DELTAVBODX", "S")).
    NL:ADD(N83).

    // N84

    EMEM_CREATE("DELTAVOV").

    local N84 is LEXICON("NOUN", 84, "R1", LIST("DELTAVOVZ", "S"), "R2", LIST("DELTAVOVY", "S"), "R3", LIST("DELTAVOVX", "S")).
    NL:ADD(N84).

    // N85 - residuals!

    // N86

    local N86 is N81:COPY.
    set N86:NOUN TO 86.

    NL:ADD(N86).

    //N95

    local N95 is LEXICON("NOUN", 95, "R1", LIST("TTOGO", "L"), "R2", LIST("VGDISP", "P"), "R3", LIST("VMAGI", "P")).

    local nounList is NL:copy.

    // Some other stuff
    EMEM_CREATE("V").
    EMEM_CREATE("R").
    EMEM_CREATE("DAP").
    EMEM_CREATE("TCO").
    EMEM_CREATE("PADALTI").

    EMEM_CREATE("TIG_ADJUSTED_BY_P40").
    EMEM_WRITE("TIG_ADJUSTED_BY_P40", false).

    EMEM_CREATE("PROGRAM").
    EMEM_CREATE("PROGRAM_STEP").

    EMEM_CREATE("ROUTINE").
    EMEM_CREATE("ROUTINE_STEP").


    // create UPBUFF - ADDRESS 304(8) to 300(8)+20(10)
    
    local _UB is "UPBUFF".
    local _currentUpbuff is 0.
    local _maxUpbuff is 20. // 24 octal
    local _decAddress is tobase(8,10,304).
    local _octAddress is tobase(10,8,304).

    UNTIL _currentUpbuff > _maxUpbuff {
        set _octAddress to tobase(10,8,_decAddress).
        set _UB to "UPBUFF" + _currentUpbuff:tostring.
        EMEM_CREATE(_UB).
        EMEM_ADDRESS(_octAddress, _UB).
        set _decAddress to _decAddress+1.
        set _currentUpbuff to _currentUpbuff+1.
    }

    // assign

    EMEM_WRITE("PROGRAM", -1). // null program
    
    EMEM_WRITE("TIME0", t0).
    EMEM_WRITE("V", ship:velocity:orbit).
    EMEM_WRITE("R", ship:body:position).
    EMEM_WRITE("DAP", false).
    EMEM_WRITE("DAPDATR1", ddap).
    EMEM_WRITE("DAPDATR2", ddap).
    EMEM_WRITE("PADALTI", 137).
    EMEM_WRITE("DELTAVLVC", v(0,0,0)).
    EMEM_WRITE("THETAD", v(0,0,0)).
    EMEM_WRITE("CDU", v(0,0,0)).

    

    // assign actual "addresses" to these items

    EMEM_ADDRESS(2023, "PACTOFF").
    EMEM_ADDRESS(2024, "YACTOFF").
    EMEM_ADDRESS(3065, "DAPDATR1").
    EMEM_ADDRESS(3066, "DAPDATR2").
    EMEM_ADDRESS(3072, "LEMMAS").
    EMEM_ADDRESS(3073, "CSMMAS").


    NOUN_CREATE(nounList).

    set NL to LIST().
    set nounList to LIST().

    EMEM_SAVE().
}