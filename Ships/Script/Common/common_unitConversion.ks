//Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// Copyrighted under the MIT License

GLOBAL _COMMONFUNC_UNIT_AVAILABLE IS TRUE.


// contains unit conversion from x to y

// for example can convert meters into ft and ft into meters

// it is simple to use this (in theory) though i am awaiting about 10k github issues on when i actually forget how my own functions work

// lets say we wanted to convert 10lbs from the CSMMAS to store it as a nice KSP friendly metric value 
// so we have about maybe 26000lbs
// so we want to convert this into tonnes (because KSP just go with it for now ok)
// our input unit will be "lbs"
// and our output unit will be "t"
// our unit value can be 26000

// now if this works correctly, according to windows 11 we should get 11.7934
FUNCTION convertUnit {
    parameter inputUnit is "me", outputUnit is "ft", unitValue is 0.

    local convertedValue is 0.
    IF _CONVERSIONLEX:HASKEY(inputUnit) {
        IF _CONVERSIONLEX[inputUnit]:haskey(outputUnit) {
            set convertedValue to unitValue*_CONVERSIONLEX[inputUnit][outputUnit].
            // we are multiplying because i dont want some nerd flexing on me that they can force a NaN into the stack error
            // also if i really wanted to mess with these people i would just impliment the AGC's DIV functionality which would thwart their insanity
            // yes im insulting the people who intentionally try and break things, although we'd be nowhere without them, keep it up bugtesters i love you all!
        }
    }

    return convertedValue.
}


// for converting of units
// reference: 
// me - meters
// mi = miles
// ft - feet
// nmi - nautical miles

// t - tonnes (as in KSP, not short or long no idea where they'd be used anyway)
// kg - kilograms
// gR - anyone using this is clearly trying to use an ion thruster (and doesnt want their burn done in the lifetime of the universe :) I am using gR as notation because 9.81 exists and this is a space game (i know gR can be gravity too but ok)
// lbs - sadly not money (Pounds)

// all of these are actually taken from the windows calculator so report inaccuracies to the developers of windows not me, though garbage in garbage out applies to make this work as if we convert using the same dataset we should come out with the same answer regardless even if one of the values has been converted incorrectly, converting it back should still give the original value!

// 1 g = 9.80665 m/s
LOCAL _CONVERSIONLEX is LEXICON(
    "ft", LEXICON(
        "ft", 1,
        "me", 0.3048,
        "mi", 0.000189,
        "nmi", 0.000165
    ),
    "me", LEXICON(
        "me", 1,
        "ft", 3.28084,
        "g", 1/9.80665,
        "mi", 0.000621,
        "nmi", 0.00054
    ),
    "mi", lexicon(
        "mi", 1,
        "nmi", 0.868976,
        "me", 1609.344,
        "ft", 5280

    ),
    "nmi", LEXICON(
        "nmi", 1,
        "mi", 1.150779,
        "ft", 6076.115,
        "me", 1852
    ),
    "g", LEXICON(
        "me", 9.80665
    ),

    // weights

    "t", lexicon(
        "t", 1,
        "kg", 1000,
        "lbs", 2204.623,
        "gR", 1000000 // i am once again asking why
    ),
    "kg", lexicon(
        "kg", 1,
        "lbs", 2.204623, // bonus fact: i know this one from memory because i was around 1kg when i was born
        "gR", 1000,
        "t", 0.001
    ),
    "lbs", lexicon(
        "lbs", 1,
        "t", 0.000454,
        "kg", 0.453592,
        "gR", 453.5924
    )
).