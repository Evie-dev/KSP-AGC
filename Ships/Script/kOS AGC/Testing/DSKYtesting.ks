runOncePath("0:/kOS AGC/Apollo/GUI/DSKY.ks").

setAGCtextures("LM", 15).

UNTIL FALSE {
    DSKY_UPDATE().
    wait 0.
}