// haha funny

// plays 1 (one) click every second
local _lastClick is 0.
local _clickInterval is 1.
UNTIL FALSE {
    IF time:seconds > _lastClick+_clickInterval {
        ADDONS:AGC:AGCCLICK.
    }
}