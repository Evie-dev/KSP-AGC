GLOBAL _COMMONFUNC_USEFUL_AVAILABLE IS TRUE.


// converts from x base into y base supports:

// base 2-10

// https://www.tutorialspoint.com/computer_logical_organization/number_system_conversion.htm

// for the default settings, we should get 1010

FUNCTION Tobase {
    parameter inputBase is 10, outputBase is 2, _Inputvalue is 10, givemeastring is false.
    IF NOT(inputBase = 10) {
        // we can assume (for once, that we are converting to a base, therefore we must convert to a base 10 system)
        set _Inputvalue to FromBase(inputBase, 10, _Inputvalue).
    }
    local _resultant is "".
    local _remainingValue is _Inputvalue.
    // this does require some very weird schenanegans with strings and typeconversion, as we are going from least signifigance to most signifigance, we could get an error where we end up in an infinite loop i think somewhere?

    local _itterations is 0.

    local _stepResult is _Inputvalue.
    local _lastStepResult is 0.
    local _stepRemainder is 0.
    local _lastStepRemainder is 0.

    UNTIL _remainingValue = 0 {
        set _stepResult to _remainingValue/outputBase.
        set _stepRemainder to MOD(_remainingValue, outputBase).

        set _resultant to _stepRemainder:tostring + _resultant.
        set _remainingValue to FLOOR(_stepResult).
        set _lastStepResult to _stepResult.
        set _lastStepRemainder to _stepRemainder.
        set _itterations to _itterations+1.
    }
    IF givemeastring { return _resultant. }
    return _resultant:tonumber(0). // we can safely return this as a number now, as 0 = 0 in all cases so we dont need to trail the whitespace!
}

FUNCTION FromBase {
    parameter inputBase is 2, outputBase is 10, _InputValue is 1010, givemeastring is false.
    // we should get 10 from this
    IF _InputValue:istype("String") {
        set _InputValue to _InputValue:tonumber(0).
    }
    local _iChar is "0".
    local iNumb is 0.
    local _exponent is 0.

    set _InputValue to abs(_InputValue). // i dont think anyone but myself is using this so im going to just abs this value to reduce some issues that could arise

    set _InputValue to _InputValue:tostring.

    local _itterations is 0.
    local _remainingChars is _InputValue:length-_itterations. // should come out correctly

    // in this case we are doing

    // ((1*2^3)+(0*2^2)+(1*2^1)+(0*2^0))

    IF NOT(_remainingChars:istype("Scalar")) {
        set _remainingChars to _remainingChars:tonumber(0).
    }
    set _exponent to abs(_remainingChars)-1.

    local _resultant is 0.
    UNTIL _exponent = -1 {
        set _resultant to _resultant+(_InputValue[_itterations]:tonumber(0)*inputBase^_exponent).





        set _itterations to _itterations+1.
        set _remainingChars to _InputValue:length-_itterations.
        IF NOT(_remainingChars:istype("Scalar")) {
            set _remainingChars to _remainingChars:tonumber(0).
        }
        set _exponent to abs(_remainingChars)-1.
    }
    IF givemeastring { return _resultant:tostring. }
    return _resultant.
}

FUNCTION removeDecimalPoint {
    parameter fromNumb is 0.01.
    local _returnNumb is 0.
    IF NOT(fromNumb:istype("String")) {
        set fromNumb to fromNumb:tostring.
    }
    set _returnNumb to fromNumb.
    IF fromNumb:contains(".") {
        set _returnNumb to fromNumb:replace(".", "").
    }
    set _returnNumb to _returnNumb:tonumber(0).
    return _returnNumb.
}


FUNCTION stringLengthener {
    parameter toLengthen is "", lengthenTo is 3, useChar is "", fromBegining is false.
    IF NOT(toLengthen:istype("String")) {
        set toLengthen to toLengthen:tostring.
    }
    local _lengthened is toLengthen.
    UNTIL _lengthened:length >= lengthenTo {
        IF fromBegining {
            set _lengthened to useChar+_lengthened.
        } ELSE {
            set _lengthened to _lengthened+useChar.
        }
    }
    return _lengthened.
}

local function sign{parameter x. return choose -1 if x < 0 else 1.}
function newton {
    parameter f, fp, x0. 
    local x is x0. 
    local err is f(x). 
    local steps is 0. 
    until abs(err)< 1e-12 or steps > 20 
    { 
        local deriv is fp(x). 
        local step is err/deriv. 
        // only allow a maximum change of half a radian at a time to prevent small derivatives from throwing off the 
        // stability of the algorithm. 
        if abs(step) > 0.5 set step to 0.5 * sign(step). 
        set x to x - step. 
        set steps to steps+1. 
        set err to f(x). 
    }
    return x.
}

// https://www.youtube.com/watch?v=rFQ6RRi9nIw
FUNCTION fractionalDecimalToOctal {
    parameter decimalFractional is 0.

    local _majorDecimal is 0.
    local _minorDecimal is 0.

    local _minorOctal is 0.
    local _majorOctal is 0.

    set _majorDecimal to FLOOR(decimalFractional).
    set _minorDecimal to _majorDecimal-decimalFractional.

    // get major decimal into octal first

    set _majorOctal to Tobase(10,8,_majorDecimal).

    local _8multiplier is 0.
    local _8multiplierResult is 0.
    local _8remainder is random. // set to a random number because its rare its going to equal that at the first itteration
    local _8itterator is 0.

    local _octalResult is "". // as a string so we dont mess up the sequence

    set _8multiplier to _minorDecimal.
    UNTIL (_8multiplierResult = _8remainder) or _8itterator = 5 {
        set _8multiplierResult to _8multiplier*8.
        set _8remainder to FLOOR(_8multiplierResult).

        set _octalResult to _octalResult+Tobase(10, 8, _8remainder):tostring.

        set _8multiplier to _8remainder.
        set _8itterator to _8itterator+1.
    }

    set _minorOctal to _octalResult:tonumber(9).

    // if its 9 theres an error

    return LIST(_majorOctal, _minorOctal).

}

// in an ideal world this function needn't exist, however kos is fucking stupid and doesnt like big numbers, use this function if your conversion goes ary!
function scuffedBinaryToDecimalConverter {
    parameter inp is "0".

    // okay so the input is a string

    local _returnNumber is 0.

    local _inpLength is inp:length-1.

    local _startFlag is inp:contains(".").
    local _returnNumber is 0.

    FOR i in inp {
        IF i = "." {
            set _startFlag to true.
        }
        if _startFlag {
            set _returnNumber to _returnNumber+(i:tonumber(0)*2^_inpLength).
        }
        set _inpLength to _inpLength-1.
    }
    return _returnNumber.
}