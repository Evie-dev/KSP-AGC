
local _V50N18 is false.
local _V06N18 is false.
local _V50N25 is false. // not implimented but here anyway
local _V06N40 is false.

local _MINUS35 is false.
local _MINUS5 is false.
local TIGN is false.



FUNCTION P40_INIT {
    parameter asRestart is false.


}

LOCAL FUNCTION P40_MAINBODY {
    local pstep is EMEM_READ("PROGRAM_STEP").

    IF pstep = 0 {
        
    }
}