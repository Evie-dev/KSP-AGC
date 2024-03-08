GLOBAL _COMMONFUNC_TIME_AVAILABLE IS TRUE.


FUNCTION getLogTimingPrefix {
    parameter byModule is "Null".
    local lPrefix is "[" + time:clock.
    IF NOT(byModule = "Null") {
        set lPrefix to lPrefix+"/"+byModule.
    }
    set lPrefix to lPrefix+"] ".
    return lPrefix.
}

FUNCTION convertTimeLEX {
    parameter inputTime is 0.
    // if the input is lexicon, the output will be scalar, if the input is scalar the output will be lexicon
    local outputTime is 0.
    IF inputTime:istype("Lexicon") {
        local tempOutput is LEXICON("H", 0, "M", 0, "S", 0).
        FOR i in timeConversionLexiconAliases:H {
            IF inputTime:haskey(i) {
                set tempOutput:H to inputTime[i].
                break.
            }
        }
        FOR i in timeConversionLexiconAliases:M {
            IF inputTime:haskey(i) {
                set tempOutput:M to inputTime[i].
                break.
            }
        }
        FOR i in timeConversionLexiconAliases:S {
            IF inputTime:haskey(i) {
                set tempOutput:S to inputTime[i].
                break.
            }
        }
        set outputTime to outputTime+(tempOutput:H*3600)+(tempOutput:M*60)+tempOutput:S.
        IF inputTime:haskey("Sign") {
            IF inputTime:Sign = "-" {
                set outputTime to -outputTime.
            }
        }
    }
    return outputTime.
}