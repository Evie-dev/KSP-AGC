// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// Some usage guidelines

// before using any new memory location, it is up to the program or code you wish to use the variable to first save it. its henceforth recomended to place EMEM_CREATE
// for example
// if you wished to read a value called "helpme", you would, at the top of the file, call "EMEM_CREATE("helpme", "null")"
// to then write the value, you would call EMEM_WRITE("helpme", false)





// future additions: 
// Enhance memory locations


// init vars
runOncePath("0:/Common/CommonFuncWrapper.ks").
runOncePath("0:/kOS AGC/Apollo/MEM/EMEM_utils.ks").
LOCAL _CMPART IS LIST("bluedog.Apollo.CrewPod", "bluedog.Apollo.CrewPod.5crew").
LOCAL _LMPART IS LIST("bluedog.LM.Taxi", "bluedog.LM.Shelter", "bluedog.LM.Ascent.Cockpit").
LOCAL _BLANKDISP is LEXICON("MD", "bb", "VD", "bb", "ND", "bb", "R1", "bbbbbb", "R2", "bbbbbb", "R3", "bbbbbb").

local _vech is whatVehicle().

// EMEM INTERNAL STUFF

LOCAL EMEM_ASAVE IS FALSE.
local EMEM_ASAVEINTERVAL is 120.
local last_ASAVE is 0.

local _rootSaveData is "0:/kOS AGC/Apollo/" + _vech + "/MEM/" + CORE:PART:UID.
local EMEM_files is getFileData().

GLOBAL EMEM_DEBUG IS FALSE.

GLOBAL EMEM IS LEXICON().
GLOBAL ADDRASSIGN IS LEXICON().
GLOBAL VNMEM IS LEXICON().

// scale factors:
// refer to this when writing new values

local maxK2 is (99999*3600)+(59*60)+59.
// these are taken from various agc listings
GLOBAL scaleFactors is LEXICON(
    "A", LIST("OCTAL", "XXXXX", 0, "OCTAL"),
    "B", LIST("FRACTIONAL", ".XXXXX", .99996, "raw"),
    "C", LIST("WHOLE", "XXXXX", 16383, "raw"),
    "D", LIST("CDU DEGREES", "XXX.XX", 359.99, "raw"),
    "E", LIST("ELEVATION DEGREES", "XX.XXX", 89.999, "raw"),
    "F", LIST("DEGREES (180)", "XXX.XX", 179.999, "raw"),
    "G", LIST("DP DEGREES (90)", "XX.XXX", 89.999, "raw"),
    "H", LIST("DP DEGREES (360)", "XXX.XX", 359.99, "raw"),
    "J", LIST("Y OPTICS DEGREES", "XX.XXX", 0, "raw"),
    "K", LIST("TIME (HR/MIN/SEC)", LIST("00XXX", "000XX", "0XX.XX"), 2684354.55, "HMS"),
    "K2", LIST("TIME (HR/MIN/SEC)", LIST("XXXXX", "000XX", "0XX.XX"), maxK2, "HMS"), // used for setting TIME0, PLEASE PLEASE PLEASE ONLY DO THIS IF YOU REALLY KNOW WHAT YOU'RE DOING...
    "L", LIST("TIME (MIN/SEC)", "XXBXX", 3599, "MS"),
    "M", LIST("TIME (SEC)", "XXX.XX", 163.83, "raw"),
    "N", LIST("TIME (SEC) DP", "XXX.XX", 0, "raw"),
    "P", LIST("VELOCITY 2", "XXXXX", 41994, "ft"),
    "Q", LIST("POSITION 4", "XXXX.X", 0, "nmi"),
    "S", LIST("VELOCITY 3", "XXXX.X", 0, "ft"),
    "T", LIST("G", "XXX,XX", 163.83, "g"),
    "FF", LIST("TRIM DEGREES", "XXX.XX", 388.69, "raw"),
    "GG", LIST("Inertia", "XXXXX", 7733, "raw"),
    "II", LIST("Thrust Moment", "XXXXX", 7733, "raw"),
    "JJ", LIST("POSITION5", "XXX.XX", 0, "nmi"),
    "KK", LIST("WEIGHT2", "XXXXX", 0, "lbs"),
    "LL", LIST("POSITION6", "XXXX.X", 0, "nmi"),
    "MM", LIST("DRAG ACCELERATION", "XXX.XX", 24.99, "g"),
    "PP", LIST("2 INTEGERS", "XXBXX", 99_99, "raw"),
    "UU", LIST("VELOCITY/2VS", "XXXXX", 51532, "ft"),
    "VV", LIST("POSITION 8", "XXXX.X", 0, "nmi"),
    "XX", LIST("POSITION 9", "XXXXX", 0, "ft"),
    "YY", LIST("VELOCITY 4", "XXXX.X", 328.0, "ft"),
    "ZZ", LIST("DP FRACTIONAL", ".XXXXX", 0, "raw")
).


// three functions provided:


// EMEM_CREATE(ADDR, octalOnly, allowLoad)
// EMEM_READ(ADDR, forDisplay [false])
// EMEM_WRITE(ADDR, newValue)

FUNCTION EMEM_CREATE {
    parameter ADDR,scaleFactor is "raw", isOctal is false, allowLoad is true.
    IF ADDR:istype("List") {
        // indicates an array
        local lLENGTH IS 0.
        FOR i in ADDR {
            IF i:length = 1 {
                EMEM_CREATE(i[0]).
            } ELSE IF i:length = 2 {
                EMEM_CREATE(i[0], i[1]).
            } ELSE IF i:length = 3{
                EMEM_CREATE(i[0], i[1], i[2]).
            }
        }
        return.
    }
    IF NOT(ADDR:istype("String")) { set ADDR to ADDR:tostring. }
    IF NOT(EMEM:haskey(ADDR)) {
        EMEM:add(ADDR, LEXICON("value", 0, "DECBRANCH", NOT(isOctal), "preventLoad", NOT(allowLoad))).
    }
}

// allows the assignment of actual proper addresses, assigned to the memomics created above, for a more realistic AGC, though both are natively supported for the use of the programmer who has no awareness of the agc itself
FUNCTION EMEM_ADDRESS {
    //      NUMERIC ADDRESS MEMONIC
    parameter ADDR1 is 0, ADDR2 is "".
    local cValues is ADDRASSIGN:values.
    local cKeys is ADDRASSIGN:keys.

    IF NOT(ADDR1:ISTYPE("STRING")) {
        set ADDR1 to ADDR1:TOSTRING.
    }
    IF NOT(EMEM:haskey(ADDR2)) { return. } // invalid assigning!!!!
    
    IF ckeys:contains(ADDR1) or cValues:contains(ADDR2) { return. } // also invalid!!!

    ADDRASSIGN:add(ADDR1, ADDR2).

}

FUNCTION EMEM_READ {
    parameter ADDR, asRaw is true.
    local rval is false.
    IF ADDR:istype("Scalar") {
        // numeric address!
        IF ADDRASSIGN:haskey(ADDR:tostring) {
            set ADDR to ADDRASSIGN[ADDR:tostring].
        }
    }
    IF EMEM:haskey(ADDR) {
        
        set rval to EMEM[ADDR]:value.
    } ELSE IF (ADDR:ENDSWITH("X") or ADDR:ENDSWITH("Y")) or ADDR:ENDSWITH("Z") {
        local _addr is ADDR.
        IF (_addr:endswith("X") or (_addr:endswith("y") or _addr:endswith("z"))) {
            local _removd is _addr:remove(_addr:length-1, 1).
            set _addr to _removd.
            IF EMEM:haskey(_addr) and EMEM[_addr]:value:istype("Vector") {
                IF ADDR:endswith("X") { set rval to EMEM[_addr]:value:X. }
                ELSE IF ADDR:endswith("Y") { set rval to EMEM[_addr]:value:Y. }
                ELSE IF ADDR:endswith("Z") { set rval to EMEM[_addr]:value:Z. }
                return rval.
            }
        }
    } ELSE IF (ADDR:ENDSWITH("_PITCH") or ADDR:ENDSWITH("_HEADING")) or (ADDR:ENDSWITH("_YAW") or ADDR:ENDSWITH("_ROLL")) {
        local _addr is ADDR:SPLIT("_")[0].
        IF EMEM:HASKEY(_addr) and EMEM[_addr]:value:istype("Vector") {
            IF ADDR:ENDSWITH("PIT") { set rval to pitch_for(ship, EMEM[_addr]:value). }
            ELSE IF ADDR:ENDSWITH("HEA") or ADDR:ENDSWITH("YAW") { set rval to compass_for(ship, EMEM[_addr]:value). }
            ELSE IF ADDR:ENDSWITH("ROL") { set rval to roll_for(ship, EMEM[_addr]:value). }
        }
        
    }
    return rval.
}

FUNCTION EMEM_WRITE {
    parameter ADDR, newData, asRaw is true.
    IF NOT(ADDR:TONUMBER(-1) = -1) {
        set ADDR TO ADDR:TONUMBER(-1).
    }
    IF ADDR:istype("Scalar") {
        // numeric address!
        IF ADDRASSIGN:haskey(ADDR:tostring) {
            set ADDR to ADDRASSIGN[ADDR:tostring]. // set back to memomic!
        }
    }
    IF NOT(asRaw) {

    }
    IF EMEM:HASKEY(ADDR) {
        
        set EMEM[addr]:value to newData.
    } ELSE IF (ADDR:ENDSWITH("X") OR ADDR:ENDSWITH("Y")) OR ADDR:ENDSWITH("Z") {
        local _addr is ADDR.
        IF ((_addr:endswith("X") or _addr:endswith("Y")) or _addr:endswith("Z")) {
            local _removd is _addr:remove(_addr:length-2,1).
            set _addr to _removd.
            IF EMEM:haskey(_addr) and EMEM[_addr]:value:istype("Vector") {
                IF ADDR:endswith("X") { set EMEM[_addr]:value:X to newData. }
                ELSE IF ADDR:endswith("Y") { set EMEM[_addr]:value:Y to newData. }
                ELSE IF ADDR:endswith("Z") { set EMEM[_addr]:value:Z to newData. }
                ELSE { set EMEM[_addr]:value to newData. }
                return.
            }
        }
    } ELSE IF (ADDR:ENDSWITH("PIT") or (ADDR:ENDSWITH("HEA") or ADDR:ENDSWITH("YAW"))) OR ADDR:ENDSWITH("ROL") {
        local _addr is ADDR.
        local _remvd is _addr:remove(_addr:length-3, 3).
        set _addr to _remvd.

        IF EMEM:HASKEY(_addr) and EMEM[_addr]:value:istype("Vector") {
            local _oldData is EMEM[_addr]:value.
            local _oldHeading is compass_for(ship, _oldData).
            local _oldPitch is pitch_for(ship, _oldData).
            local _oldRoll is roll_for(ship, _oldData).

            local _newHeading is _oldHeading.
            local _newPitch is _oldPitch.
            local _newRoll is _oldRoll.

            IF ADDR:ENDSWITH("PIT") {
                set _newPitch to newData.
            } ELSE IF ADDR:ENDSWITH("HEA") or ADDR:ENDSWITH("YAW") {
                set _newHeading to newData.
            } ELSE IF ADDR:ENDSWITH("ROL") {
                set _newRoll to newData.
            }

            set EMEM[_addr]:value to heading(_newHeading, _newPitch, _newRoll):vector.
        }
    }
}


FUNCTION NOUN_CREATE {
    parameter nounData is LEXICON().
    
    IF nounData:istype("List") {
        FOR i in nounData {
            NOUN_CREATE(i).
        }
        return.   
    }
    local nN is "".
    local infR1 is LIST().
    local infR2 is list().
    local infR3 is list().

    IF nounData:haskey("NOUN") {
        set nN to nounData:NOUN.
        IF NOT(nN:istype("String")) {
            set nN to nN:tostring.
        }
    }
    IF nounData:haskey("R1") {
        set infR1 to nounData:R1.
    } ELSE IF nounData:haskey("Register 1") {
        set infR1 to nounData:Register_1.
    }

    IF nounData:haskey("R2") {
        set infR2 to nounData:R2.
    } ELSE IF nounData:haskey("Register 2") {
        set infR2 to nounData:Register_2.
    }

    IF nounData:haskey("R3") {
        set infR3 to nounData:R3.
    } ELSE IF nounData:haskey("Register 3") {
        set infR3 to nounData:Register_3.
    }

    local nullReg is LEXICON("ADDR", "null", "SF", "null").
    local NounStruct is LEXICON(
        "R1", nullReg:copy, // ADDR, DISPUNIT
        "R2", nullReg:copy, 
        "R3", nullReg:copy,
        "validLoad", true
    ).
    
    if NOT(infR1:empty) {
        set NounStruct:R1:ADDR to infR1[0].
        set NounStruct:R1:SF to infR1[1].
    }
    if NOT(infR2:empty) {
        set NounStruct:R2:ADDR to infR2[0].
        set NounStruct:R2:SF to infR2[1].
    }
    if NOT(infR3:empty) {
        set NounStruct:R3:ADDR to infR3[0].
        set NounStruct:R3:SF to infR3[1].
    }

    IF NOT(VNMEM:haskey(nN:tostring)) { VNMEM:add(nN:tostring, NounStruct:values). }
}

FUNCTION NOUN_READ {
    parameter currentDisp is _BLANKDISP:COPY.
    // returns a list, r1,r2,r3

    local rval is list(currentDisp:R1, currentDisp:R2,currentDisp:R3).
    local loadComps is list(currentDisp:R1, currentDisp:R2,currentDisp:R3).
    local read1 is false.
    local read2 is false.
    local read3 is false.

    local verbNumb is 0.
    local nounNumb is 0.
    local verbNumber is 0.
    local nounNumber is 0.
    set verbNumb to currentDisp:VD:tonumber(-1).
    set nounNumb to currentDisp:ND:tonumber(-1).
    set nounNumb to nounNumb:tostring.
    set verbNumber to verbNumb.
    set nounNumber to nounNumb.

    local containsOctal is false.
    IF verbNumb = -1 { } // lets see what i need for this this shouldnt actually fail :sweat:
    IF nounNumb = -1 { }

    IF verbNumb > 10 { set verbNumb to verbNumb-10. } // noun 11 and noun 1 are literally the same thing, its just that 11 sets the MONFLAG which isnt needed here

    IF VNMEM:haskey(nounNumber) {
        local _r1raw is 0.
        local _r2raw is 0.
        local _r3raw is 0.
        local nounDataset is VNMEM[nounNumber].
        local _r1scaled is "+00000".
        local _r2scaled is "+00000".
        local _r3scaled is "+00000".

        IF nounDataset:length >= 1 { set _r1raw to EMEM_READ(nounDataset[0]:ADDR). }
        ELSE { set _r1raw to false. }
        IF nounDataset:length >= 2 { set _r2raw to EMEM_READ(nounDataset[1]:ADDR). }
        ELSE { set _r2raw to false. }
        IF nounDataset:length >= 3 { set _r3raw to EMEM_READ(nounDataset[2]:ADDR). }
        ELSE { set _r3raw to false. }
        IF NOT(_r1raw:istype("Boolean")) {
            IF nounDataset[0]:SF = "A" { set containsOctal to true. }
            set _r1scaled to NOUN_SCALE_ENCODER(_r1raw, nounDataset[0]:SF, true, 1).
        }
        IF NOT(_r2raw:istype("Boolean")) {
            IF nounDataset[1]:SF = "A" { set containsOctal to true. }
            set _r2scaled to NOUN_SCALE_ENCODER(_r2raw, nounDataset[1]:SF, true, 2).
        }
        IF NOT(_r3raw:istype("Boolean")) {
            IF nounDataset[2]:SF = "A" { set containsOctal to true. }
            set _r3scaled to NOUN_SCALE_ENCODER(_r3raw, nounDataset[2]:SF, true, 3).
        }
        set loadComps to list(_r1scaled, _r2scaled, _r3scaled).
        
    }
    IF NOT(DSKY_GETFLAG("DECBRANCH") = NOT(containsOctal)) {
        DSKY_SETFLAG("DECBRANCH", NOT(containsOctal)).
    }

    IF verbNumb = 1 { set rval[0] to loadComps[0]. }
    ELSE IF verbNumb = 2 { set rval[0] to loadComps[1]. }
    ELSE IF verbNumb = 3 { set rval[0] to loadComps[2]. }
    ELSE IF verbNumb = 4 { 
        set rval[0] to loadComps[0].
        set rval[1] to loadComps[1].
    } ELSE IF verbNumb = 5 or verbNumb = 6 {
        set rval[0] to loadComps[0].
        set rval[1] to loadComps[1].
        set rval[2] to loadComps[2].
    }
    return rval.
}

local _savethreecomplist is LIST(36). // a list of nouns where we should do all three components to save
FUNCTION NOUN_WRITE {
    parameter currentDisp is _BLANKDISP:COPY, extraFlag is 0. // 0 - take the noun as desired, 1 - load component 1 too, 2 - load components 1 and 2, 3 (only implimeted for safety) load components 1, 2 and 3

    local nounNumb is currentDisp:ND:tonumber(-1).
    print "NOUN: " + nounNumb.
    IF nounNumb = -1 { return. }
    set nounNumb to nounNumb:tostring.
    if NOT(VNMEM:haskey(nounNumb)) {
        print "CANNOT WRITE TO A NON-EXISTANT NOUN!".
        return.
    }
    local load1 is false.
    local load2 is false.
    local load3 is false.

    local lval1 is 0.
    local lval2 is 0.
    local lval3 is 0.

    local val1Inf is false.
    local val2Inf is false.
    local val3inf is false.

    IF VNMEM:haskey(nounNumb) {
        IF VNMEM[nounNumb]:length >= 1 { set val1Inf to VNMEM[nounNumb][0]. }
        IF VNMEM[nounNumb]:length >= 2 { set val2Inf to VNMEM[nounNumb][1]. }
        IF VNMEM[nounNumb]:length >= 3 { set val3inf to VNMEM[nounNumb][2]. }
    } ELSE { return. }

    IF currentDisp:VD:tonumber(0) = 21 { set load1 to true. }
    ELSE IF currentDisp:VD:tonumber(0) = 22 { set load2 to true. }
    ELSE IF currentDisp:VD:tonumber(0) = 23 { set load3 to true. }

    IF extraFlag = 0 {}
    ELSE IF extraFlag = 1 { set load1 to true. }
    ELSE IF extraFlag = 2 { 
        set load1 to true. 
        set load2 to true.
    } ELSE IF extraFlag = 3 {
        set load1 to true.
        set load2 to true.
        set load3 to true.
    }

    IF load1 and NOT(val1Inf:istype("Boolean")) {
        set lval1 to NOUN_SCALE_ENCODER(currentDisp:R1, val1Inf:SF, false).
        EMEM_WRITE(val1Inf:ADDR, lval1).
    }
    IF load2 and NOT(val2Inf:istype("Boolean")) {
        set lval2 to NOUN_SCALE_ENCODER(currentDisp:R2, val2Inf:SF, false).
        EMEM_WRITE(val2Inf:ADDR, lval2).
    }
    IF load3 and NOT(val3Inf:istype("Boolean")) {
        set lval3 to NOUN_SCALE_ENCODER(currentDisp:R3, val3inf:SF, false).
        EMEM_WRITE(val3Inf:ADDR, lval3).
    }
}


// whatVehicle returns a string:

// "CSM" for CSM
// "LM" for LM

// NOUN STUFF

LOCAL FUNCTION NOUN_SCALE_ENCODER {
    parameter valu, scalfac, direct is true, forComponent is 0. // direct = true gives the SCALED value, direct false converts scaled to unscaled
    local _originalSF is scalfac. // expects scale factor to be a letter
    IF scalfac:istype("String") {
        IF scaleFactors:haskey(scalfac) { set scalfac to scaleFactors[scalfac].}
    }
    local _form is "".
    local _max is 0.
    local _units is "raw".

    set _form to scalfac[1].
    set _max to scalfac[2].
    set _units to scalfac[3].

    local rval is 0.
    IF direct {
        local _workingValue is valu.
        local _nflag is false.
        IF _workingValue:istype("Scalar") {
            set _nflag to _workingValue < 0.
            set _workingValue to abs(_workingValue).
            set valu to abs(valu).
        }
        IF NOT(_units = "raw2") {
            IF _units = "HMS" {
                local valuTS is timespan(abs(valu)).
                IF forComponent = 1 {
                    local aval is FLOOR(valuTS:hours).
                    set rval to "00".
                    IF aval < 100 {
                        set rval to rval+"0".
                    } 
                    IF aval < 10 {
                        set rval to rval+"0".
                    }
                    set rval to rval+aval:tostring.
                } ELSE IF forComponent = 2 {
                    set rval to "000".
                    local aval is valuTS:minute.
                    if aval < 10 {
                        set rval to rval+"0".
                    }
                    set rval to rval+aval:tostring.
                } ELSE IF forComponent = 3{
                    set rval to "0".
                    local _scnd is valuTS:second.
                    if _scnd < 10 { set rval to rval+"0". }
                    local _scnds is valuTS:seconds-floor(valuTS:seconds).
                    set _scnds to ROUND(_scnds, 2).
                    local _scndDisp is (_scnd+_scnds)*100.
                    set rval to rval+_scndDisp:tostring.
                    set rval to stringLengthener(rval, 4, "0", true).
                }
                set rval to stringLengthener(rval, 5, "0", false).
                set rval to sgnAppend(_nflag)+rval.
            } ELSE IF _units = "MS" {
                local valuTS is timespan(abs(valu)).
                
                local _MM is valuTS:minute.
                IF valuTS:minutes >= 60 {
                    set _MM to 59.
                }
                local _SS is 0.
                local _scnd is valuTS:second.
                IF _MM < 10 { set _MM to "0"+_MM:tostring. }
                ELSE { set _MM to _MM:tostring. }
                IF _scnd < 10 { set _SS to "0" + _scnd:tostring. }
                ELSE { set _SS to _scnd:tostring. }
                set rval to _MM + "B" + _SS.
                set rval to sgnAppend(_nflag)+rval.
            } ELSE IF NOT(scalfac[0] = "OCTAL") {
                local _inp is "".
                IF _units = "lbs" { set _inp to "t". }
                ELSE { set _inp to "me". }
                local rvalTEMP is convertUnit(_inp, _units, valu).
                local _DP is 0.
                IF _form:contains(".") {
                    set _DP to (_form:length-1)-_form:indexof(".").
                }
                set rvalTEMP to ROUND(rvalTEMP, _DP).
                IF NOT(_max = 0) {
                    set rvalTEMP to min(rvalTEMP, _max).
                }
                set rvalTEMp to rvalTEMP*10^_DP.
                set rval to rvalTEMP:tostring.
                local sgn is "+".
                IF rvalTEMP < 0 { set sgn to "-". }
                set rval to stringLengthener(rval, 5, "0", true).
                set rval to sgnAppend(_nflag)+rval.
            } ELSE IF _units = "raw" {
                local _DP is 0.
                IF _form:contains(".") {
                    set _DP to (_form:length-1)-_form:indexof(".").
                }
                local rvaltemp is ROUND(valu, _DP).
                set rvalTEMP to rvalTEMP*10^_DP.
                local sgn is "+".
                IF rvaltemp < 0 { set sgn to "-". }
                set rval to stringLengthener(rvaltemp, 5, "0", true).
                set rval to sgnAppend(_nflag)+rval.
            } ELSE IF _units = "OCTAL" {
                IF NOT(valu:istype("String")) { set valu to valu:tostring. }
                local _valuRemoved is valu:replace("+", "b").
                set valu to _valuRemoved:replace("-", "b").
                IF NOT(valu:startswith("b")) {
                    set valu to "b"+valu.
                }
                set rval to valu.
            }
            ELSE {
                IF NOT(valu:istype("String")) { set valu to valu:tostring. }
                local _val2 is valu:replace("+", "b").
                set valu to _val2:replace("-", "b").
                IF NOT(valu:startswith("b")) {
                    set rval to "b" + valu:tostring.
                }
            }   

        } ELSE {
            set rval to "+"+valu:tostring.
        }
    } ELSE {
        local _workingValue is valu.
        IF NOT(_units = "raw") {
            IF _units = "HMS" {
                set valu to valu:tonumber(0).
                local hh is 0.
                local mm is 0.
                local ss is 0.

                IF forComponent = 1 {
                    set hh to valu.
                } ELSE IF forComponent = 2 {
                    set mm to valu.
                } ELSE {
                    set ss to valu.
                }
                set rval to (hh*3600)+(mm*60)+(ss*1).
            } ELSE IF NOT(scalfac[0] = "OCTAL") {
                set valu to valu:tonumber(0).
                local _oup is "".
                IF _units = "lbs" { set _oup to "t". } // ill probably change this to kg eventually, but for now tonnes
                ELSE { set _oup to "me". }
                local _DP is 0.
                if _form:contains(".") {
                    set _DP to (_form:length-1)-_form:indexof(".").
                }
                set rvalTEMP to valu*10^(-abs(_DP)).
                set rval to convertUnit(_units, _oup, rvalTEMP).
            } ELSE {
                local _value is valu:remove(0,1).
                set valu to _value.
                set rval to valu.
                
            }
        } ELSE {
            set rval to valu:tonumber(0).
        }
    }
    return rval.
}

LOCAL FUNCTION sgnAppend {
    parameter isNeg is false.
    IF isNeg { return "-". }
    ELSE { return "+". }
}


// I/O

LOCAL FUNCTION getFileData {
    local _filert is _rootSaveData.
    local _fileEMEM is "ERASABLE MEMORY.json".
    local _fileNOUN is "NOUNS.json".
    local _fileADDRESSES is "ADDRESSES.json".

    local _filemissionInfo is "MISSION.txt". // for future use when its public, basically contains a description of the craft file so the user can somewhat navigate the landscape
    local _fileTEMEM is _filert+"/t"+_fileEMEM.
    local _fileTNOUN is _filert+"/t"+_fileNOUN.
    local _fileTADDRESS is _filert+"/t"+_fileADDRESSES.
    set _fileEMEM to _filert+"/"+_fileEMEM.
    set _fileNOUN to _filert+"/"+_fileNOUN.
    set _fileADDRESSES to _filert+"/"+_fileADDRESSES.
    set _filemissionInfo to _filert+"/"+_filemissionInfo.

    return LEXICON("root", _filert, "EMEM", _fileEMEM, "NOUN", _fileNOUN, "ADDRESS", _fileADDRESSES, "MI", _filemissionInfo,
    "tEMEM", _fileTEMEM, "tNOUN", _fileTNOUN, "tADDRESS", _fileTADDRESS).
}

FUNCTION EMEM_SAVE {
    parameter saveItem is "ALL".
    IF saveItem = "All" {
        EMEM_SAVE("EMEM").
        EMEM_SAVE("NOUN").
        EMEM_SAVE("ADDRESS").
    } ELSE {
        local _saveObject is lexicon("null", "null reference").
        local fileInfo is getFileData().
        local _savelocation is "0:/UNKNOWN SPACECRAFT.json".
        local _tSavelocation is "0:/tUNKNOWN SPACECRAFT.json".
        IF saveItem = "EMEM" {
            set _savelocation to fileInfo:EMEM.
            set _tSavelocation to fileInfo:tEMEM.
            set _saveObject to EMEM:COPY.
        } ELSE IF saveItem = "NOUN" {
            set _savelocation to fileInfo:NOUN.
            set _tSavelocation to fileInfo:tNOUN.
            set _saveObject to VNMEM:COPY.
        } ELSE IF saveItem = "ADDRESS" {
            set _savelocation to fileInfo:ADDRESS.
            set _tSavelocation to fileInfo:tADDRESS.
            set _saveObject to ADDRASSIGN:COPY.
        }
        IF NOT(_saveObject:haskey("kOS AGC version")){
            _saveObject:add("kOS AGC version", _KOSAGCVERSION).
        } ELSE {
            set _saveObject["kOS AGC version"] to _KOSAGCVERSION.
        }
        
        IF EXISTS(_savelocation) {
            // write the temp file first incase we get clobbered somehow
            IF EXISTS(_tSavelocation) {
                deletePath(_tSavelocation). // just in case, should never happen in normal operations
            }
            writeJson(_saveObject, _tSavelocation).
            deletePath(_savelocation).
            writeJson(_saveObject, _savelocation).
            deletePath(_tSavelocation).
        } ELSE {
            writeJson(_saveObject, _savelocation).
        }
    }
}

// A small look into the EMEM save ideas

// In order to save on processing time, i shant do this every time the EMEM is modified, but at specific points:

// 1. Upon Entering a program
// 2. Upon completing a program's restart section (restart protection!)

FUNCTION EMEM_LOAD {
    parameter loadItem is "ALL", expectVersion is _KOSAGCVERSION.
    print loadItem.
    IF NOT(loadItem = "EMEM") {
        IF NOT(loadItem = "ADDRESS") {
            IF NOT(loadItem) = "NOUN" {
                IF loadItem = "ALL" {
                    local _successEMEM is EMEM_LOAD("EMEM").
                    local _successNOUN is EMEM_LOAD("NOUN").
                    local _successADDRESS is EMEM_LOAD("ADDRESS").
                    return.
                    
                } ELSE {
                    DEBUG_MESSAGE("NO VALID LOAD ITEM FOUND!", 1).
                }
            }
        }
    }
    // if we call all, the calling line should EXPECT a lexicon of values, otherwise it should expect it RAW, i dont recomend loading all however because i think that MAY cause some issues
    local _retrievedData is LEXICON().
    local _fileinf is getFileData().
    local _exists is EXISTS(_fileinf[loadItem]).
    local _tExists is EXISTS(_fileinf["t"+loadItem]).
    print "exists " + _exists.
    print _tExists.
    IF _exists {
        set _retrievedData to readJson(_fileinf[loadItem]).
    } ELSE IF NOT(_tExists) {
        return false.
    } ELSE {
        set _retrievedData to readJson(_fileinf["t"+loadItem]).
    }
    
    IF loadItem = "EMEM" {
        SET EMEM to _retrievedData:copy.

        set _retrievedData to lexicon(). // clear it
        return true.
    } ELSE IF loadItem = "NOUN" {
        set VNMEM to _retrievedData:copy.
        set _retrievedData to lexicon().
        return true.
    } ELSE IF loadItem = "ADDRESS" {
        set ADDRASSIGN to _retrievedData:copy.
        set _retrievedData to lexicon().
        return true.
    }
    
    return false.
}