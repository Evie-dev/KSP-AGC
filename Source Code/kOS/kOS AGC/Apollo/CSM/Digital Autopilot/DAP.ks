// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// main DAP program

// I separated this from the main routines because of a few things... mainly to do with the idea that I do actually want to make my own steering manager so to speak for the spacecraft

runOncePath("0:/kOS AGC/Apollo/CSM/Digital Autopilot/DAP_functions.ks").

GLOBAL DAP IS LEXICON(
    "WEIGHT", 0

).