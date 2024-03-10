// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


IF AG1 { AG1 OFF.}
IF AG2 { AG2 OFF. }

LOCAL DISPLAYABLE IS FALSE.
LOCAL TESTMODE IS FALSE.
runOncePath("0:/Common/CommonFuncWrapper.ks").
runOncePath("0:/kOS AGC/Apollo/MEM/EMEM.ks").
local _rootTextureFolder is LEXICON(
    "Base", "kOS AGC Textures/DSKY/",
    "Display", "kOS AGC Textures/DSKY/DISPLAY/",
    "Keyboard", "kOS AGC Textures/DSKY/KEYBOARD/",
    "Indicators", "kOS AGC Textures/DSKY/INDICATORS/"
).
local _digitAtlas is list("0","1","2","3","4","5","6","7","8","9").
local _indicatorAtlas is list("UPLINK ACTY", "TEMP", "NO ATT", "GIMBAL LOCK", "STBY", "PROG", "KEY REL", "RESTART", "OPR ERR", "TRACKER").
local _fileEXT is ".png".

LOCAL DSPOUT is LEXICON("MD", "00", "VD", "00", "ND", "00", "R1", "+00000", "R2", "+00000", "R3", "+00000").
LOCAL DSPTAB IS DSPOUT:COPY.
LOCAL INDTAB IS LIST(TRUE,TRUE,true,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE, TRUE, TRUE, TRUE, TRUE).
local allIndicatorsOn is INDTAB:copy.
local INDFIRSTRUN IS INDTAB:copy.
GLOBAL INDOUT IS INDTAB:copy.
LOCAL INPLOCK IS "NONE".
LOCAL RELNOUN IS 0.
LOCAL RELVERB IS 0.
LOCAL RELFLASH IS FALSE.
LOCAL AWAITREL IS FALSE.
LOCAL INPREMAIN IS 0.
LOCAL DECBRANCH IS FALSE.
LOCAL _OUT0 IS LIST().


LOCAL FLSH IS FALSE.
LOCAL NVFLASH IS FALSE.


LOCAL lastOUT0 is 0.
LOCAL OUT0index is 0.
LOCAL OUT0commit is 2.
local lastREFRESH is 0.

local OUT0rate is 0.06.
local REFRESHrate is 1/1.5.
local CHUNKrefresh is false.
LOCAL CHUNKnumber is 0.



// VERB FLAGS

LOCAL MONFLAG IS FALSE.
LOCAL MONVERB IS 0.
LOCAL MONNOUN IS 0.
LOCAL lastMON is 0.
local monRefresh is 1. // once per second iirc

// V21, 22,23 are for telling us if we have REQUESTED to load or if we are LOADING the values
local _V21 is false.
local _V22 is false.
local _V23 is false.
local _V24 is false.
local _V25 is false.
local _V37 is false.


// random stuff

local _KEYRELMONITOR is false.
local _KEYREL IS FALSE.
local _KEYRELBYPASS IS FALSE.

local _ENTERMONITOR is false.
local _ENTER is false.
local _ENTERBYPASS is false.

local _PROMONITOR IS FALSE.
LOCAL _PRO IS FALSE.
LOCAL _PROBYPASS IS FALSE.


// RECYCLE

LOCAL _ALLOW_RECYCLE IS FALSE.

GLOBAL RECYCLE_FUNCTION IS DSKY_BLANKFUNC@.

FUNCTION DSKY_BLANKFUNC {}

// N01

local MEMORY_ACCESS is LEXICON(
    "STATE", "INACTIVE",
    "STEPNAME", "SETECADR",
    "AUTO_ECADR_STEP", FALSE,
    "ECADR", -1
).

local FLAG_ACCESS IS LEXICON(
    "STATE", "INACTIVE" // insure as to how implimentation of this will work
).
// steps:

// AWAIT - NON-ACTIVE
// ECADR - (skipped if sequential under the assumption that we set the starting ecadr *****DIRECTLY***** into R3)
// DATA - DATA to commit to the ECADR

// based on https://www.nasa.gov/wp-content/uploads/static/history/afj/ap11fj/a11csmoc/a11-csmoc-f2-05.jpg

// when ENTER is pressed
// we check if the NOUN is N01 or, the N01 is in the 

// kOS AGC CONFIG HOOK
IF DEFINED(kOSAGCCONFIG) {
    IF kOSAGCCONFIG:HASKEY("REFRATE") {
        IF kOSAGCCONFIG:REFRATE {
            set REFRESHrate to 1/1.5.
        } ELSE {
            set REFRESHrate to 0.
            set CHUNKrefresh to false. // if we instantly refresh we cant do the refresh rate
        }
    }
    IF kOSAGCCONFIG:HASKEY("CHUNK") {
        IF kOSAGCCONFIG:CHUNK {
            IF NOT(REFRESHrate < 0.11) {
                set REFRESHrate to REFRESHrate/11. // 11 chunks
                set CHUNKrefresh to true.
            } ELSE {
                set CHUNKrefresh to false.
            }
        } ELSE {
            set CHUNKrefresh to false.
        }
        
    }
}


// INDICATOR HOOKS

local hook_UPLINK is DSKY_INDICATOR_UPLINK@.
local hook_TEMP is DSKY_INDICATOR_TEMP@.
local hook_NO_ATT is DSKY_INDICATOR_NO_ATT@.
local hook_GIMBALLOCK IS DSKY_INDICATOR_GIMBAL_LOCK@.
local hook_STBY is DSKY_INDICATOR_STBY@.
local hook_PROG is DSKY_INDICATOR_PROG@.
local hook_KEY_REL IS DSKY_INDICATOR_KEY_REL@.
local hook_RESTART is DSKY_INDICATOR_RESTART@.
local hook_OPR_ERR is DSKY_INDICATOR_OPR_ERR@.
local hook_TRACKER is DSKY_INDICATOR_TRACKER@.
local hook_PRIO_DISP is DSKY_INDICATOR_PRIO_DISP@.
local hook_ALT is DSKY_INDICATOR_ALT@.
local hook_NO_DAP is DSKY_INDICATOR_NO_DAP@.
local hook_VEL is DSKY_INDICATOR_VEL@.


// some presetup

FOR i in DSPTAB:keys {
    IF DSPTAB[i]:length = 2 { set DSPOUT[i] to "bb". }
    ELSE IF DSPTAB[i]:length = 6 { set DSPOUT[i] to "bbbbbb".}
}
local ____ii is 0.
FOR i in INDTAB {
    set INDOUT[____ii] to false.
    set ____ii to ____ii+1.
}
local allIndicatorsOff is INDOUT:copy.


local _DSKY is gui(200).

local _dskyGUIinfo is lexicon(
    "Spacing", lexicon(
        "TOP", 20,
        "displayBorder", 25 // multiplied by 2 for spacing between INDICATORS and MONITORs

    ),
    "Size", lexicon(
        "Panel", list(315, 150),
        "Indicator",list(40,90),
        "Keyboard", list(50,50),
        "Headers", list(10,50),
        "Text", list(50,25)
    ),
    "Padding", lexicon(
        "Display", list(0,0)
    ),
    "Margin", lexicon(
        "Display", list(0,0)
    ),
    "textures", lexicon(
        "IND", list(
            LIST(), // OFF
            LIST() // ON
        ),
        "HEAD", LIST(
            LIST(), // OFF
            LIST() // ON
        )
    )
    // contains multiple lists containing texture directories
).

// Information on the textures lexicon section of the internal info structure:

// IND, contains an array of 2 lists:
//
// The first list in the array (textures:IND[0]) contains the data for paths of elements when they are OFF, this can be applied to the second list only they are the ON condition of the element
//
// for ANY Apollo Mission, we will populate the first 9 as normal
//
// if it is the LM and the Apollo Mission is Apollo 11 or above, we shall populate index 11 and index 13
//
// if we are the LM and the Apollo Mission is apollo 15 or above, we shall populate all Indexes
local _DSKY_ELEMENTS is _DSKY:addvlayout.

// add some spacing here...

local _DSKY_TOPSPACING IS _DSKY_ELEMENTS:addspacing(_dskyGUIinfo:Spacing:TOP).


local _DSKY_DISPLAYS is _DSKY_ELEMENTS:addhlayout.

// _DSKY_DISPLAYS contains GUI elements of:
//

// Indicator Lamps
// Electro Liuminesant display unit

local _spacing_dsky_initialDisplaySpacing is _DSKY_DISPLAYS:addspacing(_dskyGUIinfo:Spacing:displayBorder).

local _DSKY_DISPLAY_INDICATORS IS _DSKY_DISPLAYS:addhlayout.

local _spacing_DSKY_displays_mid is _DSKY_DISPLAYS:addspacing(2*_dskyGUIinfo:Spacing:displayBorder).

local _DSKY_DISPLAY_MONITORS IS _DSKY_DISPLAYS:addhlayout.

// setup display widths and height

set _DSKY_DISPLAY_INDICATORS:style:height to _dskyGUIinfo:Size:Panel[0].
set _DSKY_DISPLAY_INDICATORS:style:width to _dskyGUIinfo:Size:Panel[1].

set _DSKY_DISPLAY_MONITORS:style:height to _dskyGUIinfo:Size:Panel[0].
set _DSKY_DISPLAY_MONITORS:style:width to _dskyGUIinfo:Size:Panel[1].

// add 2 columns for both the MONITOR and INDICATOR

local _DSKY_DISPLAY_INDICATOR1 is _DSKY_DISPLAY_INDICATORS:addvlayout.
local _DSKY_DISPLAY_INDICATOR2 is _DSKY_DISPLAY_INDICATORS:addvlayout.

local _DSKY_DISPLAY_MONITOR is _DSKY_DISPLAY_MONITORS:addvlayout. // overall EL display panel

local _DSKY_DISPLAY_MONITOU is _DSKY_DISPLAY_MONITOR:addhlayout. // the box containing the UPPER elements of the pannel (Major mode, ect ect)

local _DSKY_DISPLAY_MONITORU1 is _DSKY_DISPLAY_MONITOU:addvlayout.
local _DSKY_DISPLAY_MONITORU_MIDSPACING IS _DSKY_DISPLAY_MONITOU:addspacing(_dskyGUIinfo:Spacing:displayBorder).
local _DSKY_DISPLAY_MONITORU2 is _DSKY_DISPLAY_MONITOU:addvlayout.

// now lets do the initial layout

local _keyboardPRESPACE is _DSKY_ELEMENTS:addspacing(25).
local _DSKY_KEYBOARD is _DSKY_ELEMENTS:addhlayout.

// we need to add 7 different rows here
// these shall be prefixed KEYBRD_ROWCONTAINER

local _KEYBRD_ROWCONTAINER1 is _DSKY_KEYBOARD:addvlayout.
local _KEYBRD_ROWCONTAINER2 is _DSKY_KEYBOARD:addvlayout.
local _KEYBRD_ROWCONTAINER3 is _DSKY_KEYBOARD:addvlayout.
local _KEYBRD_ROWCONTAINER4 is _DSKY_KEYBOARD:addvlayout.
local _KEYBRD_ROWCONTAINER5 is _DSKY_KEYBOARD:addvlayout.
local _KEYBRD_ROWCONTAINER6 is _DSKY_KEYBOARD:addvlayout.
local _KEYBRD_ROWCONTAINER7 is _DSKY_KEYBOARD:addvlayout.


// lets start by populating GUI elements for each indicator lamp
// we will go in the following order:

// UPLINK ACTIVITY, TEMPERATURE, NO ATTITUDE, GIMBAL LOCK, STANDBY, PROGRAM ALARM, KEY RELEASE, RESTART, OPERATOR ERROR, TRACKER, PRIORITY DISPLAY, ALTITUDE, NO DIGITAL AUTOPILOT, VELOCITY

// we will handle the textures after

// these will be prefixed with INDI

// and for the programmer:

// :style:height to _dskyGUIinfo:Size:Indicator[0].
// :style:width to _dskyGUIinfo:Size:Indicator[1].

// UPLINK ACTIVITY

local INDI_UPLINK is _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_UPLINK:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_UPLINK:style:width to _dskyGUIinfo:Size:Indicator[1].

// TEMPERATURE

local INDI_TEMP IS _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_TEMP:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_TEMP:style:width to _dskyGUIinfo:Size:Indicator[1].

// NO ATTITUDE

local INDI_NO_ATT is _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_NO_ATT:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_NO_ATT:style:width to _dskyGUIinfo:Size:Indicator[1].

// GIMBAL LOCK

local INDI_GIMBAL_LOCK IS _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_GIMBAL_LOCK:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_GIMBAL_LOCK:style:width to _dskyGUIinfo:Size:Indicator[1].

// STANDBY

local INDI_STBY IS _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_STBY:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_STBY:style:width to _dskyGUIinfo:Size:Indicator[1].

// PROGRAM ALARM

local INDI_PROG is _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_PROG:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_PROG:style:width to _dskyGUIinfo:Size:Indicator[1].

// KEY RELEASE

local INDI_KEY_REL IS _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_KEY_REL:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_KEY_REL:style:width to _dskyGUIinfo:Size:Indicator[1].


// RESTART

local INDI_RESTART is _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_RESTART:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_RESTART:style:width to _dskyGUIinfo:Size:Indicator[1].

// OPERATOR ERROR

local INDI_OPR_ERR is _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_OPR_ERR:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_OPR_ERR:style:width to _dskyGUIinfo:Size:Indicator[1].

// TRACKER

local INDI_TRACKER IS _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_TRACKER:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_TRACKER:style:width to _dskyGUIinfo:Size:Indicator[1].

// PRIORITY DISPLAY

local INDI_PRIO_DISP is _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_PRIO_DISP:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_PRIO_DISP:style:width to _dskyGUIinfo:Size:Indicator[1].

// ALTITUDE

local INDI_ALT is _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_ALT:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_ALT:style:width to _dskyGUIinfo:Size:Indicator[1].

// NO DIGITAL AUTOPILOT

local INDI_NO_DAP IS _DSKY_DISPLAY_INDICATOR1:addlabel().
set INDI_NO_DAP:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_NO_DAP:style:width to _dskyGUIinfo:Size:Indicator[1].

// VELOCITY

local INDI_VEL is _DSKY_DISPLAY_INDICATOR2:addlabel().
set INDI_VEL:style:height to _dskyGUIinfo:Size:Indicator[0].
set INDI_VEL:style:width to _dskyGUIinfo:Size:Indicator[1].

// lets setup the display now...lmao

// As a reminder here,

// it is setup into 4 elements, and named _DSKY_DISPLAY_MONITOR

// the large element, containing the entire EL display contents

// this is split into an upper element which is also split in 2, containing two sides of the upper portion of the display

// as a diagram.

//  COMP ACTY       PROG
//  COMP ACTY    MD1 MD2
//  COMP ACTY    MD1 MD2
//
//  VERB            NOUN
//  VD1 VD2      ND1 ND2
//  VD1 VD2      ND1 ND2
//
// (LINE)
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// (LINE)
//
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
//
// (LINE)
// R3S R3D1 R3D2 R3D3 R3D4 R3D5
// R3S R3D1 R3D2 R3D3 R3D4 R3D5

// as we can see we are missing two specifications (actually three but LINE is hopefully omittable for the notes here)
// the specification for PROG, VERB and NOUN
// these will be called HEADERS and prefixed as _DISP_HEADER_(name)
// 
// we also note that the display "text" is images, due to a limitation with kOS i shall be presenting these in layouts (containers), these will be named according to the element objects they contain as well as prefixed with _DISP_CONTAINER, this is to prevent a GLOBAL variable _MD ect causing an error (you're welcome!)
// for example:
// the element containing MD1 and MD2 shall be named _DISP_CONTAINER_MD
//
// CONTAINERS WILL NEED TO CONFORM TO PADDING, THOUGH MARGIN I AM UNSURE ABOUT
//
// the upper contains two sides

// _DSKY_DISPLAY_MONITORU1

// COMP ACTY
// VERB

// _DSKY_DISPLAY_MONITORU2
// MAJOR MODE
// NOUN

// as with before we shall set the height and width
// for the designer:
// 
// specifications of widths and heights in display elements, with ascosiated :style:height/:style:width code below said section:
//
// OVERALL:
//
// MARGIN
//
// Height: 0
// Width: 0
//
// :style:margin:h to 0.
// :style:margin:v to 0.
//
// PADDING
//
// Height: 0
// Width: 0
// 
// :style:padding:h to 0.
// :style:padding:v to 0.
//

// COMP ACTIY
//
// Height: 50
// Width 50
//
// :style:height to 50.
// :style:width to 50.

// VERB/NOUN/PROG HEADERS

// Height: 10
// Width: 50
//
// :style:height to _dskyGUIinfo:Size:headers[0].
// :style:width to _dskyGUIinfo:Size:Headers[1].
//
// ANY NUMERICAL DISPLAY ELEMENTS (DEFINED IN GUI L)
//
// Height: 50
// Width: 25

// :style:height to _dskyGUIinfo:Size:Text[0].
// :style:width to _dskyGUIinfo:Size:Text[1].
//
// LINES:
// Height: 5
// Width: 130
// same margin and padding settings

// code is presented as follows:

// ELEMENT
// PADDING (h)
// PADDING (v)
// MARGIN (h)
// MARGIN (v)
// HEIGHT
// WIDTH

// add some spacing to MONITORU around COMPACTY

local _compACTYabove is _DSKY_DISPLAY_MONITORU1:addspacing(10).


// COMP ACTIVITY LIGHT

local _DISP_COMPACTY is _DSKY_DISPLAY_MONITORU1:addlabel().
set _DISP_COMPACTY:style:padding:h to 0.
set _DISP_COMPACTY:style:padding:v to 0.
set _DISP_COMPACTY:style:height to 50.
set _DISP_COMPACTY:style:width to 50.

local _compACTYbelow is _DSKY_DISPLAY_MONITORU1:addspacing(9).

// MAJOR MODE HEADER

local _DISP_HEADER_MD is _DSKY_DISPLAY_MONITORU2:addlabel().
set _DISP_HEADER_MD:style:padding:h to 0.
set _DISP_HEADER_MD:style:padding:v to 0.
set _DISP_HEADER_MD:style:height to _dskyGUIinfo:Size:headers[0].
set _DISP_HEADER_MD:style:width to _dskyGUIinfo:Size:Headers[1].

// MAJOR MODE CONTAINER:

local _DISP_CONTAINER_MD is _DSKY_DISPLAY_MONITORU2:addhlayout.
set _DISP_CONTAINER_MD:style:padding:h to 0.
set _DISP_CONTAINER_MD:style:padding:v to 0.

// MAJOR MODE ELEMENTS

// MD1

local _DISP_MD1 is _DISP_CONTAINER_MD:addlabel().
set _DISP_MD1:style:margin:h to 0.
set _DISP_MD1:style:margin:v to 0.
set _DISP_MD1:style:padding:h to 0.
set _DISP_MD1:style:padding:v to 0.
set _DISP_MD1:style:height to _dskyGUIinfo:Size:Text[0].
set _DISP_MD1:style:width to _dskyGUIinfo:Size:Text[1].

// MD2

local _DISP_MD2 is _DISP_CONTAINER_MD:addlabel().
set _DISP_MD2:style:margin:h to 0.
set _DISP_MD2:style:margin:v to 0.
set _DISP_MD2:style:padding:h to 0.
set _DISP_MD2:style:padding:v to 0.
set _DISP_MD2:style:height to _dskyGUIinfo:Size:Text[0].
set _DISP_MD2:style:width to _dskyGUIinfo:Size:Text[1].

// VERB HEADER

local _DISP_HEADER_VD is _DSKY_DISPLAY_MONITORU1:addlabel().
set _DISP_HEADER_VD:style:padding:h to 0.
set _DISP_HEADER_VD:style:padding:v to 0.
set _DISP_HEADER_VD:style:height to _dskyGUIinfo:Size:headers[0].
set _DISP_HEADER_VD:style:width to _dskyGUIinfo:Size:Headers[1].

// VERB DISPLAY CONTAINER:

local _DISP_CONTAINER_VD is _DSKY_DISPLAY_MONITORU1:addhlayout.
set _DISP_CONTAINER_VD:style:padding:h to 0.
set _DISP_CONTAINER_VD:style:padding:v to 0.

// VERB DISPLAY ELEMENTS:

// VD1

local _DISP_VD1 is _DISP_CONTAINER_VD:addlabel().
set _DISP_VD1:style:margin:h to 0.
set _DISP_VD1:style:margin:v to 0.
set _DISP_VD1:style:padding:h to 0.
set _DISP_VD1:style:padding:v to 0.
set _DISP_VD1:style:height to _dskyGUIinfo:Size:Text[0].
set _DISP_VD1:style:width to _dskyGUIinfo:Size:Text[1].

// VD2

local _DISP_VD2 is _DISP_CONTAINER_VD:addlabel().
set _DISP_VD2:style:margin:h to 0.
set _DISP_VD2:style:margin:v to 0.
set _DISP_VD2:style:padding:h to 0.
set _DISP_VD2:style:padding:v to 0.
set _DISP_VD2:style:height to _dskyGUIinfo:Size:Text[0].
set _DISP_VD2:style:width to _dskyGUIinfo:Size:Text[1].


// NOUN HEADER

local _DISP_HEADER_ND is _DSKY_DISPLAY_MONITORU2:addlabel().
set _DISP_HEADER_ND:style:padding:h to 0.
set _DISP_HEADER_ND:style:padding:v to 0.
set _DISP_HEADER_ND:style:height to _dskyGUIinfo:Size:headers[0].
set _DISP_HEADER_ND:style:width to _dskyGUIinfo:Size:Headers[1].

// NOUN DISPLAY CONTAINER:

local _DISP_CONTAINER_ND is _DSKY_DISPLAY_MONITORU2:addhlayout.
set _DISP_CONTAINER_ND:style:padding:h to 0.
set _DISP_CONTAINER_ND:style:padding:v to 0.

// NOUN DISPLAY ELEMENTS:

// ND1

local _DISP_ND1 is _DISP_CONTAINER_ND:addlabel().
set _DISP_ND1:style:margin:h to 0.
set _DISP_ND1:style:margin:v to 0.
set _DISP_ND1:style:padding:h to 0.
set _DISP_ND1:style:padding:v to 0.
set _DISP_ND1:style:height to _dskyGUIinfo:Size:Text[0].
set _DISP_ND1:style:width to _dskyGUIinfo:Size:Text[1].

// ND2

local _DISP_ND2 is _DISP_CONTAINER_ND:addlabel().
set _DISP_ND2:style:margin:h to 0.
set _DISP_ND2:style:margin:v to 0.
set _DISP_ND2:style:padding:h to 0.
set _DISP_ND2:style:padding:v to 0.
set _DISP_ND2:style:height to _dskyGUIinfo:Size:Text[0].
set _DISP_ND2:style:width to _dskyGUIinfo:Size:Text[1].


// now for the rows, to remind you all

// the layout is this:

// (LINE)
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// (LINE)
//
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
//
// (LINE)
// R3S R3D1 R3D2 R3D3 R3D4 R3D5
// R3S R3D1 R3D2 R3D3 R3D4 R3D5

// First we must add a LINE between the elements
// the line requires spacing to be placed between it however
// that spacing is around 12px
//
// for a reminder of programming the specifications:

// containers:
// :style:padding:h to 0.
// :style:padding:v to 0.

// Text:
// :style:padding:h to 0.
// :style:padding:v to 0.
//
// :style:margin:h to 0.
// :style:margin:v to 0.
//
// :style:height to _dskyGUIinfo:Size:text[0].
// :style:width to _dskyGUIinfo:Size:text[1].

// the lines will be called _DISP_LINE1, _DISP_LINE2, _DISP_LINE3 to not confuse it with the rows

local _DISP_CONTAINER_LINE1 is _DSKY_DISPLAY_MONITOR:addhlayout.
// add spacing
local _DISP_LINE1_SPACING IS _DISP_CONTAINER_LINE1:addspacing(12).
local _DISP_LINE1 is _DISP_CONTAINER_LINE1:addlabel().
set _DISP_LINE1:style:margin:h to 0.
set _DISP_LINE1:style:margin:v to 0.
set _DISP_LINE1:style:padding:h to 0.
set _DISP_LINE1:style:padding:v to 0.
set _DISP_LINE1:style:height to 5.
set _DISP_LINE1:style:width to 130.

// DISPLAY ROW 1
//
// Layout:
// R1S R1D1 R1D2 R1D3 R1D4 R1D5


local _DISP_CONTAINER_R1 is _DSKY_DISPLAY_MONITOR:addhlayout.
set _DISP_CONTAINER_R1:style:padding:h to 0.
set _DISP_CONTAINER_R1:style:padding:v to 0.

// R1S (ROW 1 SIGN)

local _DISP_R1S is _DISP_CONTAINER_R1:addlabel().
set _DISP_R1S:style:margin:h to 0.
set _DISP_R1S:style:margin:v to 0.
set _DISP_R1S:style:padding:h to 0.
set _DISP_R1S:style:padding:v to 0.
set _DISP_R1S:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R1S:style:width to _dskyGUIinfo:Size:text[1].

// R1D1

local _DISP_R1D1 is _DISP_CONTAINER_R1:addlabel().
set _DISP_R1D1:style:margin:h to 0.
set _DISP_R1D1:style:margin:v to 0.
set _DISP_R1D1:style:padding:h to 0.
set _DISP_R1D1:style:padding:v to 0.
set _DISP_R1D1:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R1D1:style:width to _dskyGUIinfo:Size:text[1].

// R1D2

local _DISP_R1D2 is _DISP_CONTAINER_R1:addlabel().
set _DISP_R1D2:style:margin:h to 0.
set _DISP_R1D2:style:margin:v to 0.
set _DISP_R1D2:style:padding:h to 0.
set _DISP_R1D2:style:padding:v to 0.
set _DISP_R1D2:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R1D2:style:width to _dskyGUIinfo:Size:text[1].

// R1D3

local _DISP_R1D3 is _DISP_CONTAINER_R1:addlabel().
set _DISP_R1D3:style:margin:h to 0.
set _DISP_R1D3:style:margin:v to 0.
set _DISP_R1D3:style:padding:h to 0.
set _DISP_R1D3:style:padding:v to 0.
set _DISP_R1D3:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R1D3:style:width to _dskyGUIinfo:Size:text[1].

// R1D4

local _DISP_R1D4 is _DISP_CONTAINER_R1:addlabel().
set _DISP_R1D4:style:margin:h to 0.
set _DISP_R1D4:style:margin:v to 0.
set _DISP_R1D4:style:padding:h to 0.
set _DISP_R1D4:style:padding:v to 0.
set _DISP_R1D4:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R1D4:style:width to _dskyGUIinfo:Size:text[1].

// R1D5

local _DISP_R1D5 is _DISP_CONTAINER_R1:addlabel().
set _DISP_R1D5:style:margin:h to 0.
set _DISP_R1D5:style:margin:v to 0.
set _DISP_R1D5:style:padding:h to 0.
set _DISP_R1D5:style:padding:v to 0.
set _DISP_R1D5:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R1D5:style:width to _dskyGUIinfo:Size:text[1].


// LINE 2

local _DISP_CONTAINER_LINE2 is _DSKY_DISPLAY_MONITOR:addhlayout.
local _DISP_LINE2_SPACING is _DISP_CONTAINER_LINE2:addspacing(12).
local _DISP_LINE2 is _DISP_CONTAINER_LINE2:addlabel().
set _DISP_LINE2:style:margin:h to 0.
set _DISP_LINE2:style:margin:v to 0.
set _DISP_LINE2:style:padding:h to 0.
set _DISP_LINE2:style:padding:v to 0.
set _DISP_LINE2:style:height to 5.
set _DISP_LINE2:style:width to 130.

// DISPLAY ROW 2
//
// Layout:
// R2S R2D1 R2D2 R2D3 R2D4 R2D5

local _DISP_CONTAINER_R2 is _DSKY_DISPLAY_MONITOR:addhlayout.
set _DISP_CONTAINER_R2:style:padding:h to 0.
set _DISP_CONTAINER_R2:style:padding:v to 0.

// R2S (ROW 1 SIGN)

local _DISP_R2S is _DISP_CONTAINER_R2:addlabel().
set _DISP_R2S:style:margin:h to 0.
set _DISP_R2S:style:margin:v to 0.
set _DISP_R2S:style:padding:h to 0.
set _DISP_R2S:style:padding:v to 0.
set _DISP_R2S:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R2S:style:width to _dskyGUIinfo:Size:text[1].

// R2D1

local _DISP_R2D1 is _DISP_CONTAINER_R2:addlabel().
set _DISP_R2D1:style:margin:h to 0.
set _DISP_R2D1:style:margin:v to 0.
set _DISP_R2D1:style:padding:h to 0.
set _DISP_R2D1:style:padding:v to 0.
set _DISP_R2D1:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R2D1:style:width to _dskyGUIinfo:Size:text[1].

// R2D2 - haha funny robot

local _DISP_R2D2 is _DISP_CONTAINER_R2:addlabel().
set _DISP_R2D2:style:margin:h to 0.
set _DISP_R2D2:style:margin:v to 0.
set _DISP_R2D2:style:padding:h to 0.
set _DISP_R2D2:style:padding:v to 0.
set _DISP_R2D2:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R2D2:style:width to _dskyGUIinfo:Size:text[1].

// R2D3

local _DISP_R2D3 is _DISP_CONTAINER_R2:addlabel().
set _DISP_R2D3:style:margin:h to 0.
set _DISP_R2D3:style:margin:v to 0.
set _DISP_R2D3:style:padding:h to 0.
set _DISP_R2D3:style:padding:v to 0.
set _DISP_R2D3:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R2D3:style:width to _dskyGUIinfo:Size:text[1].

// R2D4

local _DISP_R2D4 is _DISP_CONTAINER_R2:addlabel().
set _DISP_R2D4:style:margin:h to 0.
set _DISP_R2D4:style:margin:v to 0.
set _DISP_R2D4:style:padding:h to 0.
set _DISP_R2D4:style:padding:v to 0.
set _DISP_R2D4:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R2D4:style:width to _dskyGUIinfo:Size:text[1].

// R2D5

local _DISP_R2D5 is _DISP_CONTAINER_R2:addlabel().
set _DISP_R2D5:style:margin:h to 0.
set _DISP_R2D5:style:margin:v to 0.
set _DISP_R2D5:style:padding:h to 0.
set _DISP_R2D5:style:padding:v to 0.
set _DISP_R2D5:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R2D5:style:width to _dskyGUIinfo:Size:text[1].

// LINE 3

local _DISP_CONTAINER_LINE3 is _DSKY_DISPLAY_MONITOR:addhlayout.
local _DISP_LINE3_SPACING is _DISP_CONTAINER_LINE3:addspacing(12).
local _DISP_LINE3 is _DISP_CONTAINER_LINE3:addlabel().
set _DISP_LINE3:style:margin:h to 0.
set _DISP_LINE3:style:margin:v to 0.
set _DISP_LINE3:style:padding:h to 0.
set _DISP_LINE3:style:padding:v to 0.
set _DISP_LINE3:style:height to 5.
set _DISP_LINE3:style:width to 130.

// DISPLAY ROW 3

local _DISP_CONTAINER_R3 is _DSKY_DISPLAY_MONITOR:addhlayout.
set _DISP_CONTAINER_R3:style:padding:h to 0.
set _DISP_CONTAINER_R3:style:padding:v to 0.

// R3S (ROW 1 SIGN)

local _DISP_R3S is _DISP_CONTAINER_R3:addlabel().
set _DISP_R3S:style:margin:h to 0.
set _DISP_R3S:style:margin:v to 0.
set _DISP_R3S:style:padding:h to 0.
set _DISP_R3S:style:padding:v to 0.
set _DISP_R3S:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R3S:style:width to _dskyGUIinfo:Size:text[1].

// R3D1

local _DISP_R3D1 is _DISP_CONTAINER_R3:addlabel().
set _DISP_R3D1:style:margin:h to 0.
set _DISP_R3D1:style:margin:v to 0.
set _DISP_R3D1:style:padding:h to 0.
set _DISP_R3D1:style:padding:v to 0.
set _DISP_R3D1:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R3D1:style:width to _dskyGUIinfo:Size:text[1].

// R3D2

local _DISP_R3D2 is _DISP_CONTAINER_R3:addlabel().
set _DISP_R3D2:style:margin:h to 0.
set _DISP_R3D2:style:margin:v to 0.
set _DISP_R3D2:style:padding:h to 0.
set _DISP_R3D2:style:padding:v to 0.
set _DISP_R3D2:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R3D2:style:width to _dskyGUIinfo:Size:text[1].

// R3D3

local _DISP_R3D3 is _DISP_CONTAINER_R3:addlabel().
set _DISP_R3D3:style:margin:h to 0.
set _DISP_R3D3:style:margin:v to 0.
set _DISP_R3D3:style:padding:h to 0.
set _DISP_R3D3:style:padding:v to 0.
set _DISP_R3D3:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R3D3:style:width to _dskyGUIinfo:Size:text[1].

// R3D4

local _DISP_R3D4 is _DISP_CONTAINER_R3:addlabel().
set _DISP_R3D4:style:margin:h to 0.
set _DISP_R3D4:style:margin:v to 0.
set _DISP_R3D4:style:padding:h to 0.
set _DISP_R3D4:style:padding:v to 0.
set _DISP_R3D4:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R3D4:style:width to _dskyGUIinfo:Size:text[1].

// R3D5

local _DISP_R3D5 is _DISP_CONTAINER_R3:addlabel().
set _DISP_R3D5:style:margin:h to 0.
set _DISP_R3D5:style:margin:v to 0.
set _DISP_R3D5:style:padding:h to 0.
set _DISP_R3D5:style:padding:v to 0.
set _DISP_R3D5:style:height to _dskyGUIinfo:Size:text[0].
set _DISP_R3D5:style:width to _dskyGUIinfo:Size:text[1].

// Now we must do the third and final element of the display and keyboard, we have worked on the display, its time for the keyboard (im also keybored of coding this but okay)

// the keyboard is layed out as follows

//          ++++ 7777 8888 9999 CLER
//  VERB    ++++ 7777 8888 9999 CLER ENTR
// (VERB)                           (ENTR)
//  VERB    ---- 4444 5555 6666 PROC ENTR
//  NOUN    ---- 4444 5555 6666 PROC RSET
//  (NOUN)                           (RSET)
//  NOUN    0000 1111 2222 3333 KEYR RSET
//          0000 1111 2222 3333 KEYR

// to remind you of the work we have done at the first step of initilization:
//
// created the keyboard container
// created the 7 rows

// now we shall create the buttons and such for each row

// buttons shall be named
// KEYBRD_(button)

// for the first row we must add spacing, oh we also should mention that buttons require padding

// styling guide
//
// :Style:padding:h to 0.
// :Style:padding:v to 0.
// :Style:height to _dskyGUIinfo:Size:Keyboard[0].
// :Style:width to _dskyGUIinfo:Size:Keyboard[1].

local _KEYBRD_spacing1 is _KEYBRD_ROWCONTAINER1:addspacing(0.5*_dskyGUIinfo:Size:keyboard[0]).

// now lets add the buttons

// VERB

local _KEYBRD_VERB is _KEYBRD_ROWCONTAINER1:addbutton().
set _KEYBRD_VERB:style:padding:h to 0.
set _KEYBRD_VERB:style:padding:v to 0.
set _KEYBRD_VERB:style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_VERB:style:width to _dskyGUIinfo:Size:Keyboard[1].

// NOUN

local _KEYBRD_NOUN is _KEYBRD_ROWCONTAINER1:addbutton().
set _KEYBRD_NOUN:Style:padding:h to 0.
set _KEYBRD_NOUN:Style:padding:v to 0.
set _KEYBRD_NOUN:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_NOUN:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ROW 2

// PLUS

local _KEYBRD_PLUS is _KEYBRD_ROWCONTAINER2:addbutton().
set _KEYBRD_PLUS:Style:padding:h to 0.
set _KEYBRD_PLUS:Style:padding:v to 0.
set _KEYBRD_PLUS:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_PLUS:style:width to _dskyGUIinfo:Size:Keyboard[1].

// MINUS

local _KEYBRD_MINUS is _KEYBRD_ROWCONTAINER2:addbutton().
set _KEYBRD_MINUS:Style:padding:h to 0.
set _KEYBRD_MINUS:Style:padding:v to 0.
set _KEYBRD_MINUS:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_MINUS:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ZERO

local _KEYBRD_0 is _KEYBRD_ROWCONTAINER2:addbutton().
set _KEYBRD_0:Style:padding:h to 0.
set _KEYBRD_0:Style:padding:v to 0.
set _KEYBRD_0:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_0:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ROW 3

// SEVEN

local _KEYBRD_7 is _KEYBRD_ROWCONTAINER3:addbutton().
set _KEYBRD_7:Style:padding:h to 0.
set _KEYBRD_7:Style:padding:v to 0.
set _KEYBRD_7:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_7:style:width to _dskyGUIinfo:Size:Keyboard[1].

// FOUR

local _KEYBRD_4 is _KEYBRD_ROWCONTAINER3:addbutton().
set _KEYBRD_4:Style:padding:h to 0.
set _KEYBRD_4:Style:padding:v to 0.
set _KEYBRD_4:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_4:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ONE

local _KEYBRD_1 is _KEYBRD_ROWCONTAINER3:addbutton().
set _KEYBRD_1:Style:padding:h to 0.
set _KEYBRD_1:Style:padding:v to 0.
set _KEYBRD_1:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_1:style:width to _dskyGUIinfo:Size:Keyboard[1].


// ROW 4

// EIGHT

local _KEYBRD_8 is _KEYBRD_ROWCONTAINER4:addbutton().
set _KEYBRD_8:Style:padding:h to 0.
set _KEYBRD_8:Style:padding:v to 0.
set _KEYBRD_8:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_8:style:width to _dskyGUIinfo:Size:Keyboard[1].

// FIVE

local _KEYBRD_5 is _KEYBRD_ROWCONTAINER4:addbutton().
set _KEYBRD_5:Style:padding:h to 0.
set _KEYBRD_5:Style:padding:v to 0.
set _KEYBRD_5:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_5:style:width to _dskyGUIinfo:Size:Keyboard[1].

// TWO

local _KEYBRD_2 is _KEYBRD_ROWCONTAINER4:addbutton().
set _KEYBRD_2:Style:padding:h to 0.
set _KEYBRD_2:Style:padding:v to 0.
set _KEYBRD_2:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_2:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ROW 5

// NINE

local _KEYBRD_9 is _KEYBRD_ROWCONTAINER5:addbutton().
set _KEYBRD_9:Style:padding:h to 0.
set _KEYBRD_9:Style:padding:v to 0.
set _KEYBRD_9:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_9:style:width to _dskyGUIinfo:Size:Keyboard[1].

// SIX

local _KEYBRD_6 is _KEYBRD_ROWCONTAINER5:addbutton().
set _KEYBRD_6:Style:padding:h to 0.
set _KEYBRD_6:Style:padding:v to 0.
set _KEYBRD_6:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_6:style:width to _dskyGUIinfo:Size:Keyboard[1].

// THREE

local _KEYBRD_3 is _KEYBRD_ROWCONTAINER5:addbutton().
set _KEYBRD_3:Style:padding:h to 0.
set _KEYBRD_3:Style:padding:v to 0.
set _KEYBRD_3:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_3:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ROW 6

// CLEAR

local _KEYBRD_CLR is _KEYBRD_ROWCONTAINER6:addbutton().
set _KEYBRD_CLR:Style:padding:h to 0.
set _KEYBRD_CLR:Style:padding:v to 0.
set _KEYBRD_CLR:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_CLR:style:width to _dskyGUIinfo:Size:Keyboard[1].

// PROCED

local _KEYBRD_PRO is _KEYBRD_ROWCONTAINER6:addbutton().
set _KEYBRD_PRO:Style:padding:h to 0.
set _KEYBRD_PRO:Style:padding:v to 0.
set _KEYBRD_PRO:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_PRO:style:width to _dskyGUIinfo:Size:Keyboard[1].

// KEY RELEASE

local _KEYBRD_KEYREL is _KEYBRD_ROWCONTAINER6:addbutton().
set _KEYBRD_KEYREL:Style:padding:h to 0.
set _KEYBRD_KEYREL:Style:padding:v to 0.
set _KEYBRD_KEYREL:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_KEYREL:style:width to _dskyGUIinfo:Size:Keyboard[1].

// ROW 7

// spacing

local _KEYBRD_spacing2 is _KEYBRD_ROWCONTAINER7:addspacing(0.5*_dskyGUIinfo:Size:keyboard[0]).

// ENTER

local _KEYBRD_ENTR is _KEYBRD_ROWCONTAINER7:addbutton().
set _KEYBRD_ENTR:Style:padding:h to 0.
set _KEYBRD_ENTR:Style:padding:v to 0.
set _KEYBRD_ENTR:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_ENTR:style:width to _dskyGUIinfo:Size:Keyboard[1].

// RESET

local _KEYBRD_RSET is _KEYBRD_ROWCONTAINER7:addbutton().
set _KEYBRD_RSET:Style:padding:h to 0.
set _KEYBRD_RSET:Style:padding:v to 0.
set _KEYBRD_RSET:Style:height to _dskyGUIinfo:Size:Keyboard[0].
set _KEYBRD_RSET:style:width to _dskyGUIinfo:Size:Keyboard[1].
// setup the hooks

set _KEYBRD_0:onclick to {KEYBOARD_INPUT("10000").}.

set _KEYBRD_1:onclick to {KEYBOARD_INPUT("00001").}.
set _KEYBRD_2:onclick to {KEYBOARD_INPUT("00010").}.
set _KEYBRD_3:onclick to {KEYBOARD_INPUT("00011").}.

set _KEYBRD_4:onclick to {KEYBOARD_INPUT("00100").}.
set _KEYBRD_5:onclick to {KEYBOARD_INPUT("00101").}.
set _KEYBRD_6:onclick to {KEYBOARD_INPUT("00110").}.

set _KEYBRD_7:onclick to {KEYBOARD_INPUT("00111").}.
set _KEYBRD_8:onclick to {KEYBOARD_INPUT("01000").}.
set _KEYBRD_9:onclick to {KEYBOARD_INPUT("01001").}.

set _KEYBRD_PLUS:onclick to {KEYBOARD_INPUT("11010").}.
set _KEYBRD_MINUS:onclick to {KEYBOARD_INPUT("11011").}.

set _KEYBRD_VERB:onclick to {KEYBOARD_INPUT("10001"). }.
set _KEYBRD_NOUN:onclick to {KEYBOARD_INPUT("11111"). }.

set _KEYBRD_ENTR:onclick to {KEYBOARD_INPUT("11100").}.
set _KEYBRD_CLR:onclick to {KEYBOARD_INPUT("11110").}.
set _KEYBRD_PRO:onclick to {KEYBOARD_INPUT("PRO").}.
set _KEYBRD_RSET:onclick to {KEYBOARD_INPUT("10010").}.
set _KEYBRD_KEYREL:onclick to {KEYBOARD_INPUT("11001").}.


// Now we can set the textures
FUNCTION setAGCtextures {
    parameter forVehicle is "CSM", forMission is 17.
    set _DSKY:style:bg to _rootTextureFolder:Base + "background.png".
    set _DSKY_DISPLAY_MONITOR:style:bg to _rootTextureFolder:Display+ "background.png".
    

    // Indicators

    IF forVehicle = "CSM" or forMission < 11 {
        _indicatorAtlas:add("NULL").
        _indicatorAtlas:add("NULL").
        _indicatorAtlas:add("NULL").
        _indicatorAtlas:add("NULL").
    } ELSE {
        IF forMission < 15 {
            _indicatorAtlas:add("NULL").
            _indicatorAtlas:add("ALT").
            _indicatorAtlas:add("NULL").
            _indicatorAtlas:add("VEL").
        } ELSE {
            _indicatorAtlas:add("PRIO DISP").
            _indicatorAtlas:add("ALT").
            _indicatorAtlas:add("NO DAP").
            _indicatorAtlas:add("VEL").
        }
    }
    // do a single pass of the indicator update


    // keyboard

    set _KEYBRD_0:image to _rootTextureFolder:Keyboard+_digitAtlas[0]+_fileEXT.
    set _KEYBRD_1:image to _rootTextureFolder:Keyboard+_digitAtlas[1]+_fileEXT.
    set _KEYBRD_2:image to _rootTextureFolder:Keyboard+_digitAtlas[2]+_fileEXT.
    set _KEYBRD_3:image to _rootTextureFolder:Keyboard+_digitAtlas[3]+_fileEXT.
    set _KEYBRD_4:image to _rootTextureFolder:Keyboard+_digitAtlas[4]+_fileEXT.
    set _KEYBRD_5:image to _rootTextureFolder:Keyboard+_digitAtlas[5]+_fileEXT.
    set _KEYBRD_6:image to _rootTextureFolder:Keyboard+_digitAtlas[6]+_fileEXT.
    set _KEYBRD_7:image to _rootTextureFolder:Keyboard+_digitAtlas[7]+_fileEXT.
    set _KEYBRD_8:image to _rootTextureFolder:Keyboard+_digitAtlas[8]+_fileEXT.
    set _KEYBRD_9:image to _rootTextureFolder:Keyboard+_digitAtlas[9]+_fileEXT.

    set _KEYBRD_PLUS:image to _rootTextureFolder:Keyboard+"PLUS"+_fileEXT.
    set _KEYBRD_MINUS:image to _rootTextureFolder:Keyboard+"MINUS"+_fileEXT.
    set _KEYBRD_CLR:image to _rootTextureFolder:Keyboard+"CLR"+_fileEXT.
    set _KEYBRD_ENTR:image to _rootTextureFolder:Keyboard+"ENTR"+_fileEXT.
    set _KEYBRD_KEYREL:image to _rootTextureFolder:Keyboard+"KEYREL"+_fileEXT.
    set _KEYBRD_RSET:image to _rootTextureFolder:Keyboard+"RSET"+_fileEXT.
    set _KEYBRD_PRO:image to _rootTextureFolder:Keyboard+"PRO"+_fileEXT.

    set _KEYBRD_VERB:image to _rootTextureFolder:Keyboard+"VERB"+_fileEXT.
    set _KEYBRD_NOUN:image to _rootTextureFolder:Keyboard+"NOUN"+_fileEXT.

    // Display

    set _DISP_COMPACTY:image to _rootTextureFolder:Indicators + "OFF/COMP ACTY"+_fileEXT.
    set _DISP_HEADER_MD:image to _rootTextureFolder:DISPLAY + "PROG ON" +_fileEXT.
    set _DISP_HEADER_VD:image to _rootTextureFolder:DISPLAY + "VERB ON" + _fileEXT.
    set _DISP_HEADER_ND:image to _rootTextureFolder:DISPLAY + "NOUN ON" + _fileEXT.
    set _DISP_LINE1:image to _rootTextureFolder:Display+"line"+_fileEXT.
    set _DISP_LINE2:image to _rootTextureFolder:Display+"line"+_fileEXT.
    set _DISP_LINE3:image to _rootTextureFolder:Display+"line"+_fileEXT.

    set DISPLAYABLE to true.
}





// PINBALL

GLOBAL UPRUPT_WORDS is LIST(
    "1 10000 01111 10000",
    "1 00001 11110 00001",
    "1 00010 11101 00010",
    "1 00011 11100 00011",
    "1 00100 11011 00100",
    "1 00101 11001 00110",
    "1 00111 11000 00111",
    "1 01000 10111 01000",
    "1 01001 10110 01001",
    "1 10001 01110 10001",
    "1 11111 00000 11111",
    "1 11100 00011 11100",
    "1 10010 01101 10010",
    "1 11110 00001 11110",
    "1 11001 00110 11001",
    "1 11010 00101 11010",
    "1 11011 00100 11011"
).
GLOBAL KEYRUPT_WORDS IS LIST(
    "10000",
    "00001",
    "00010",
    "00011",
    "00100",
    "00101",
    "00110",
    "00111",
    "01000",
    "01001",
    "10001",
    "11111",
    "11100",
    "10010",
    "11110",
    "11001",
    "11010",
    "11011"
).
global TERMINAL_WORDS IS list("0", "1","2","3","4","5","6","7","8","9","V", "N", "E", "R", "C", "K", "+", "-").
GLOBAL _KEYRUPT_VALUES is list("0", "1","2","3","4","5","6","7","8","9","VERB", "NOUN", "ENTR", "RSET", "CLR", "KEY REL", "+", "-").
GLOBAL DSPLOCK IS FALSE.
FUNCTION KEYBOARD_INPUT {
    parameter keycode is "".
    print keycode.
    IF keycode = "PRO" or keycode = "P" {
        KEYRUPT1("PRO").
        return.
    }
    KEYRUPT1(PINBALL_KEYBOARD_WORDS(keycode)).
}

FUNCTION UPLINK_INPUT {
    parameter keycode is "".
    local _keycode is PINBALL_UPLINK_WORDS(keycode).
    print "_keycode: " + _keycode.
    KEYRUPT1(_keycode).
}

LOCAL FUNCTION KEYRUPT1 {
    parameter keypress is "".
    set DSPLOCK to true.
    local pressnumb is 0.
    print "kEYRUPT1" + keypress.
    IF keypress:istype("String") {
        IF keypress = "PRO" {
            set pressnumb to -1.
        } ELSE {
            set pressnumb to keypress:tonumber(-1).
        }
    } ELSE {
        set pressnumb to -1.
    }
    
    if pressnumb = -1 {
        IF keypress = "+" or keypress = "-" { SIGN(keypress). }
        ELSE IF keypress = "RSET" { RESET(). }
        ELSE IF keypress = "CLR" { CLEAR(). }
        ELSE IF keypress = "KEY REL" { KEY_RELEASE(). }
        ELSE IF keypress = "ENTR" { ENTER(). }
        ELSE IF keypress = "PRO" { PRO(). }
        IF keypress = "VERB" or keypress = "NOUN" {
            set DECBRANCH to true.
            set INPREMAIN to 2.
            IF keypress = "VERB" {
                set INPLOCK TO "VD".
                BLANK2("VD").
            } ELSE IF keypress = "NOUN" {
                set INPLOCK TO "ND".
                BLANK2("ND").
            }
        }
    } else {
        // 8-9 test
        IF NOT(INPLOCK = "MD" or (INPLOCK = "VD" or INPLOCK = "ND")) and (NOT(DECBRANCH) and pressnumb > 7) { return. }
        IF INPREMAIN = 0 { return. }
        set INPREMAIN TO INPREMAIN-1.
        IF INPLOCK:startswith("R") {
            IF NOT(DECBRANCH) {
                IF NOT(DSPOUT[INPLOCK] = "bbbbbb") { _OUT0:add(LIST(INPLOCK, "b")). }
            }
        }
        _OUT0:add(LIST(INPLOCK, pressnumb)).

    }
}

LOCAL FUNCTION KEYRUPT2 {
    parameter keypress is "".
    KEYRUPT1(keypress).
}

// key specific

LOCAL FUNCTION ENTER {
    set NVFLASH to false.
    IF _ENTERMONITOR {
        set _ENTER TO TRUE.
        IF _ENTERBYPASS { return. } // only used in bypass
    }

    // N01-N03 PROCESSING...
    local D2 is DSPOUT:COPY.
    IF NOUN_PROCESSOR_CONTROL() {
        NOUN_PROCESSOR().
    } ELSE {
        VERB_PROCESSOR(DSPOUT:VD, true).
    }
}

LOCAL FUNCTION PRO {
    IF _PROMONITOR {
        set _PRO to true.
        IF _PROBYPASS { return. }
    }
    IF DEFINED ROUTINES_ARE_AVAILABLE {
        IF NOT(EMEM_READ("ROUTINE") = -1){
            RNEXT_STEP().
        }
    }
    IF DEFINED PROGRAMS_ARE_AVAILABLE {
        IF NOT(EMEM_READ("PROGRAM") = -1) {
            PNEXT_STEP().
        }
    }
}

LOCAL FUNCTION RESET {
    set INDOUT to allIndicatorsOff.
}

LOCAL FUNCTION KEY_RELEASE {
    set DSPLOCK TO FALSE.
    IF MEMORY_ACCESS:STEPNAME = "POST" {
        set MEMORY_ACCESS:STATE TO "INACTIVE".
        set MEMORY_ACCESS:STEPNAME TO "SETECADR".
        set MEMORY_ACCESS:AUTO_ECADR_STEP to false.
        set MEMORY_ACCESS:ECADR to "-1".
    }
    IF _KEYRELMONITOR { 
        SET _KEYREL TO TRUE.
        IF _KEYRELBYPASS { return. }
    }
    IF AWAITREL {
        // key release -> off
        // key rel is indexed to 6
        set INDOUT[6] to false.
        NVSUB(RELVERB, RELNOUN).
        set AWAITREL to false.
    }
}

LOCAL FUNCTION CLEAR {
    IF INPLOCK:startswith("R") {
        BLANK5(INPLOCK).
    }
}

LOCAL FUNCTION SIGN {
    parameter sgn is "+".
    IF NOT(DECBRANCH) or ((INPLOCK = "MD" or INPLOCK = "ND") or INPLOCK = "VD") { return. }
    IF DECBRANCH {
        IF NOT(DSPOUT[INPLOCK]:startswith("+") or DSPOUT[INPLOCK]:startswith("-")) { _OUT0:add(LIST(INPLOCK, sgn)). }
    }
}

LOCAL FUNCTION NOUN_PROCESSOR_CONTROL {
    parameter displayState is DSPOUT:COPY.

    // returns a boolan based upon if NOUN_PROCESSOR should handle the specific ENTER passed

    local _vd is displayState:VD.
    local _nd is displayState:ND.

    // we first get the list of applicable nouns we can use here

    local _applicableNouns is LIST(
        "01","02","03", // memory access
        "15" // incriment machine address
    ).
    local _overrideVerbs is LIST("32","33","34","37","69","70","71","72","75").
    IF _overrideVerbs:contains(_vd) { return false. }
    IF _applicableNouns:contains(_nd) {
        IF LIST("01","02","03"):contains(_nd) {
            return true.
        }
        IF _nd = "15" and NOT(MEMORY_ACCESS:ECADR = -1) {
            return true.
        } ELSE {
            return false.
        }
    }
}


local _N01ECADR is false.
local _N01DATA is false.


local _donePost is false.
LOCAL FUNCTION NOUN_PROCESSOR {
    parameter displayState is DSPOUT:COPY.

    local _vd is displayState:VD.
    local _nd is displayState:ND.

    // provides an override for the verb processor to allow for the capability to modify nouns
    local _processingMode is "READ".
    IF LIST("01","02","03"):contains(_vd) {
        // what step are we in?
        set _processingMode to "READ".
    }
    ELSE IF _vd = "21" or _vd = "25" { // unsure as to why you'd need other things that arent 21 or 25 for this (25 for N07)
        set _processingMode to "WRITE".
    }

    // both modes have the same access point, its just the end that differs

    IF MEMORY_ACCESS:STATE = "INACTIVE" {
        set MEMORY_ACCESS:STATE TO "ACTIVE".
        set MEMORY_ACCESS:STEPNAME TO "SETECADR".
        set MEMORY_ACCESS:AUTO_ECADR_STEP to false.
        set MEMORY_ACCESS:ECADR to "-1".
    }

    IF MEMORY_ACCESS:STATE = "ACTIVE" {
        set _donePost to false.
        IF MEMORY_ACCESS:STEPNAME = "POST" {


            set _donePost to true.
        }
        ELSE IF MEMORY_ACCESS:STEPNAME = "SETECADR" {
            IF NOT(_N01ECADR) {
                BLANK5("R1").
                set INPLOCK to "R1".
                set INPREMAIN TO 5.

                set _N01ECADR to true.
            } ELSE {

                // now we diverge

                
                

                // we now need to set the ECADR data

                local _r1data is displayState:R1.

                local _ECADRdata is "".

                FOR i in _r1data {
                    IF NOT(i = "b") { set _ECADRdata to _ECADRdata+i. }
                }
                set MEMORY_ACCESS:ECADR to _ECADRdata.
                

                set DSPOUT:R3 to "b"+stringLengthener(MEMORY_ACCESS:ECADR, 5, "b").

                IF _processingMode = "READ" {
                    set MEMORY_ACCESS:STEPNAME TO "POST".

                    // put the data address stuff into R1

                    set DSPOUT:R1 to EMEM_READ(MEMORY_ACCESS:ECADR:tonumber(0)).
                } ELSE {
                    set MEMORY_ACCESS:STEPNAME TO "SETDATA".
                }
            }
        }

        IF MEMORY_ACCESS:STEPNAME = "SETDATA" {
            IF NOT(_N01DATA) {
                BLANK5("R1").
                SET INPLOCK to "R1".
                set INPREMAIN to 5.

                set _N01DATA to true.

                // ENSURE that the ecadr is going to be displayed

                set DSPOUT:R3 to "b"+stringLengthener(MEMORY_ACCESS:ECADR, 5, "b").
            }


        }
        IF MEMORY_ACCESS:STEPNAME = "POST" AND NOT(_donePost) {

        }
    }
}

// Unsure which part this should be, assuming that this should be 

LOCAL FUNCTION VERB_PROCESSOR {
    parameter processingVerb is DSPOUT:VD, fromEnter is false.

    // Noun Processin has been moved to various locations

    // here we are including the regular verbs

    IF NOT(processingVerb:istype("Scalar")) { set processingVerb to processingVerb:tonumber(-1). }
    IF processingVerb = -1 { return. } // ????

    IF processingVerb < 20 {
        IF processingVerb > 10 {
            set processingVerb to processingVerb-10.
            IF NOT(MONFLAG) { set MONFLAG to true.}
            set MONNOUN to DSPOUT:ND.
            set MONVERB to DSPOUT:VD.
        } ELSE { 
            set MONFLAG to false. 
            set MONNOUN to "".
            set MONVERB to "".
        }
        local currentDisplay is DSPTAB:copy.
        local newDisplayOutput is LIST(DSPTAB:R1, DSPTAB:R2, DSPTAB:R3).
        set newDisplayOutput to NOUN_READ(currentDisplay).
        set DSPOUT:R1 to newDisplayOutput[0].
        set DSPOUT:R2 to newDisplayOutput[1].
        SET DSPOUT:R3 to newDisplayOutput[2].
        IF fromEnter { set DSPLOCK to false. }
        return.
    } ELSE { set MONFLAG to false. } // again, just to make sure its false 
    IF processingVerb < 27 {
        IF processingVerb = 21 {
            set INPLOCK to "NONE".
            IF NOT(_V21) {
                BLANK5("R1").
                SET INPLOCK to "R1".
                set INPREMAIN to 5.
                set _V21 to true.
                set NVFLASH to true.
            } ELSE {
                set _V21 to false.
                IF NOT(_V24 or _V25) {
                    
                    NOUN_WRITE(DSPOUT:COPY).
                } ELSE {
                    set DSPOUT:VD to "22".
                    VERB_PROCESSOR().
                }
                
            } 
        } ELSE IF processingVerb = 22 {
            set INPLOCK to "NONE".
            IF NOT(_V22) {
                BLANK5("R2").
                set INPLOCK TO "R2".
                set NVFLASH to true.
                set INPREMAIN to 5.
                set _V22 to true.
            } ELSE {
                set _V22 to false.
                IF NOT(_V25) {
                    local eFlag is 0.
                    IF _V24 {
                        set eFlag to 2.
                        set _V24 TO FALSE.
                    }
                    NOUN_WRITE(DSPOUT:COPY, eFlag).
                } ELSE {
                    set DSPOUT:VD TO "23".
                    VERB_PROCESSOR().
                }
                
            }
        } ELSE IF processingVerb = 23 {
            set INPLOCK to "NONE".
            IF NOT(_V23) {
                BLANK5("R3").
                set NVFLASH to true.
                set INPLOCK to "R3".
                set INPREMAIN to 5.
            } ELSE {
                set _V23 TO FALSE.
                local eFlag is 0.
                IF _V25 {
                    set eFlag to 3.
                    set _V25 TO FALSE.
                }
                NOUN_WRITE(DSPTAB:COPY, eFlag).
            }
        } ELSE IF processingVerb = 24 or processingVerb = 25 {
            set DSPOUT:VD to "21".
            IF processingVerb = 24 { SET _V24 to true. }
            ELSE { set _V25 to true. }
            VERB_PROCESSOR().
        }
    } ELSE {
        

        IF processingVerb = 27 {
            // 27 is for displaying fixed memory - NOT IMPLIMENTED
        } ELSE IF processingVerb = 30 {

        } ELSE IF processingVerb = 31 {

        } ELSE IF processingVerb = 32 {

        } ELSE IF processingVerb = 33 {
            IF EMEM_READ("PROGRAM") = 27 and EMEM_READ("PROGRAM_STEP") = 3 {
                // commit!
                set _N01_AUTOSEQUENTIAL to false.
                P27_COMMIT().
            }
            GOTO_P00H().
        } ELSE IF processingVerb = 34 {
            ERASABLE_FRESH_START().
        } ELSE IF processingVerb = 35 {
            // lamp test
            local _tst2 is "88".
            local _tst5 is "+88888".
            local _isP00 is DSPOUT:MD = "00".
            local t0 is time:seconds.
            local t1 is time:seconds+6.
            set NVFLASH to true.
            set DSPOUT to LEXICON("MD", _tst2, "VD", _tst2, "ND", _tst2, "R1", _tst5, "R2", _tst5, "R3", _tst5).
            set INDOUT to allIndicatorsOn.
            when time:seconds > t1 then {
                RESET().
                set NVFLASH TO FALSE.
                IF _isP00 {
                    BLANK2("VD").
                    BLANK2("ND").
                    set DSPOUT:MD to "00".
                }
            }
        } ELSE IF processingVerb = 36 {
            // fresh start
        } ELSE IF processingVerb = 37 AND DEFINED PROGRAMS_ARE_AVAILABLE {
            IF NOT(_V37) {
                set _V37 to true.
                set NVFLASH to true.
                KEYRUPT1("NOUN").
            } ELSE {
                set _V37 to false.
                set NVFLASH to false.
                set INPLOCK to "NONE".
                CHANGE_PROGRAM(DSPOUT:ND).
            }
        } ELSE IF DEFINED EXTENDED_VERBS_ARE_AVAILABLE {
            VERB_PROCESSOR_EXTENDED(processingVerb).
        }
    }
}

FUNCTION NVSUB {
    parameter _verb is MONVERB, _noun is MONNOUN, doFlash is false.
    IF DSPLOCK {
        set AWAITREL to true.
        set RELVERB TO _verb.
        set RELNOUN to _noun.
        set RELFLASH to doFlash.
        // KEYREL IS 6
        set INDOUT[6] to true.
    } ELSE {
        IF _verb:istype("Scalar") {
            IF _verb < 10 {
                set _verb to "0" + _verb:tostring.
            } ELSE { set _verb to _verb:tostring. }
        }
        IF _noun:istype("Scalar") {
            IF _noun < 10 {
                set _noun to "0"+_noun:tostring.
            } ELSE {
                set _noun to _noun:tostring.
            }
        }
        set DSPOUT:VD to _verb.
        set DSPOUT:ND to _noun.
        set NVFLASH to doFlash.
        ENTER().
        
    }
}

// non key specific universal input

// Some notes on the two different refresh rate types:

// without chunk loading, we refresh the DSKY all at once, with all registers being updated
// With chunk loading we do it in 11 separate chunks, aproximately once every 0.03 seconds

// here are the chunks, with the entire DSKY display being in this format too, groups are referenced in code as (group)-1 to index them from zero

//  COMP ACTY       PROG
//  COMP ACTY    MD1 MD2
//  COMP ACTY    MD1 MD2
//
//  VERB            NOUN
//  VD1 VD2      ND1 ND2
//  VD1 VD2      ND1 ND2
//
// (LINE)
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// (LINE)
//
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
//
// (LINE)
// R3S R3D1 R3D2 R3D3 R3D4 R3D5
// R3S R3D1 R3D2 R3D3 R3D4 R3D5

// -- 1 
// MD1, MD2

// -- 2
// VD1, VD2

// -- 3

// ND1, ND2

// -- 4 

// R1D1

// -- 5

// R1S, R1D2, R1D3

// -- 6

// R1D4, R1D5

// -- 7

// R2S, R2D1, R2D2

// -- 8

// R2D3, R2D4

// -- 9

// R2D5, R3D1

// -- 10

// R3S, R3D2, R3D3

// -- 11

// R3D4, R3D5

FUNCTION DSKY_UPDATE {
    checkForUI().
    IF time:seconds > lastOUT0+OUT0rate {
        // Here we look for inputs
        OUT0().
        set lastOUT0 to time:seconds.
    }
    IF time:seconds > lastREFRESH+REFRESHrate {
        // here we refresh the display
        DSKY_REFRESH().
        IF NOT(CHUNKrefresh) { INDICATOR_REFRESH(). }
        // during chunk refresh, INDICATOR is handled within the function itself
        set lastREFRESH to time:seconds.
    }
    IF MONFLAG and time:seconds > lastMON+monRefresh {
        // here we are updating MONITOR functionality
        NVSUB(MONVERB, MONNOUN).
        set lastMON to time:seconds.
    }
}

local uicurrentlyvisible is false.
local vPart is 0.
local whatVech2 is "undefined".
local uiDisplayMode is "undefined".
local _uiAG is 1.
local _uiKey is false.
local UIrun1 is true.
LOCAL FUNCTION checkForUI {

    IF NOT(uicurrentlyvisible) {
        clearScreen.
        print "Press AG1 to show the DSKY".

        IF AG1 {
            set uicurrentlyvisible to true.
            _DSKY:show.
            AG1 OFF.
        }
    } ELSE {
        clearScreen.
        print "Press AG1 to hide the DSKY".

        IF AG1 {
            set uicurrentlyvisible to false.
            _DSKY:hide.
            AG1 OFF.
        }
    }
    IF uiDisplayMode = "undefined" {
        set whatVech2 to whatVech().
        set vPart to whatCommand().
        IF vPart:istype("String") {
            IF vPart = "unknown" { set uiDisplayMode to "Legacy". }
        }
        IF NOT(vPart:istype("Part")) { set uiDisplayMode to "Legacy". }
        IF NOT(uiDisplayMode = "undefined") { return. }
        IF partHasField(vPart, "DSKY") {
            set uiDisplayMode to "PM".
        } ELSE { set uiDisplayMode to "Legacy". }
    } ELSE IF uiDisplayMode = "Legacy" {
        IF UIrun1 {
            clearScreen.
            IF whatVech2 = "CSM" { 
                set _uiAG to 1.
                print "Press AG" + _uiAG:tostring + " to display the DSKY UI". 
            }
            ELSE IF whatVech2 = "LM" {
                set _uiAG to 2.
                print "Press AG" + _uiAG:tostring + " to display the DSKY UI". 
            }
            
            set UIrun1 to false.
        } ELSE {
            IF whatVech2 = "CSM" { 
                set _uiKey to AG1.
                AG1 OFF.
            } ELSE IF whatVech2 = "LM" {
                set _uiKey to AG2.
                AG2 OFF.
            }
            IF _uiKey {
                IF uicurrentlyvisible {
                    _DSKY:hide.
                    set uicurrentlyvisible to false.
                    clearScreen.
                    print "Press AG" + _uiAG:tostring + " to display the DSKY UI".
                } ELSE {
                    _DSKY:show.
                    set uicurrentlyvisible to true.
                    clearScreen.
                    print "Press AG" + _uiAG:tostring + " to hide the DSKY UI".
                }
                set _uiKey to false.
            }
        }
    } ELSE IF uiDisplayMode = "PM" or uiDisplayMode = "PartModule" {
        set _uiKey to getPartField(vPart, "DSKY").
        IF NOT(uicurrentlyvisible = _uiKey) {
            IF NOT(uicurrentlyvisible) { _DSKY:show. }
            ELSE { _DSKY:hide. }
            set uicurrentlyvisible to _uiKey.
        }
    }
}

LOCAL FUNCTION OUT0 {
    local _O0 is _OUT0:COPY.
    local OI is OUT0index.
    IF _O0:empty { return. }
    ELSE {
        IF OI < _O0:length {
            local _working is _O0[OI].
            local INPto is _working[0].
            local _mlength is 2.
            IF INPto:startswith("R") { set _mlength to 6. }
            local INPing is _working[1].
            IF NOT(INPing:istype("String")) { set INPing to INPing:tostring. }
            local _cs is DSPOUT[INPto].
            local _splitIndx is 0.
            IF _cs = "bb" or _cs = "bbbbbb" {
                set _cs to "".
            } ELSE {
                set _splitIndx to _cs:FINDAT("b", 1).
                local _splitted is _cs:substring(0, _splitIndx).
                local _appendStart is "".
                if _CS:STARTSWITH("b") { set _appendStart to "b". }
                set _cs to _appendStart+_splitted.
            }
            set _cs to _cs+INPing.
            set DSPOUT[INPto] to stringlengthener(_cs, _mlength, "b", false).
            set OUT0index to OUT0index+1.
        } ELSE {
            set OUT0index to 0.
            set _OUT0 to LIST().
        }
    }
}

LOCAL FUNCTION DSKY_REFRESH {
    parameter asChunk is CHUNKrefresh.
    IF NOT(asChunk) {
        set FLSH to NOT(FLSH).
        local _Dout is DSPOUT:copy.
        local _Dtab is DSPTAB:copy.
        local ____REGISTER is "MD".
        local _registers is list("MD", "VD", "ND", "R1", "R2", "R3").
        FOR i in _registers {
            set ____REGISTER to i.
            IF NOT(_Dout[____REGISTER] = _Dtab[____REGISTER]) or ((____REGISTER = "ND" or ____REGISTER = "VD") and NVFLASH) {
                IF ((____REGISTER = "ND" or ____REGISTER = "VD") and NVFLASH) {
                    IF FLSH {
                        displayDriver(____REGISTER, _Dout[____REGISTER]). 
                        set DSPTAB[____REGISTER] to _Dout[____REGISTER].
                    } ELSE {
                        displayDriver(____REGISTER, "bb").
                    }
                } ELSE {
                    displayDriver(____REGISTER, _Dout[____REGISTER]). 
                    set DSPTAB[____REGISTER] to _Dout[____REGISTER].
                }
                
            }
        }
        IF kOSAGCCONFIG:JSONoutput AND DISPLAYABLE {
            DSKY_JSON_OUTPUT().
        }
        IF kOSAGCCONFIG:TERMinput AND DISPLAYABLE {
            DSKY_JSON_INPUT().
        }
    } ELSE {
        // we do this by chunks, see top of file
        local _Dout is DSPOUT:COPY.
        local _Dtab is DSPTAB:COPY.
        local _Dchunk is CHUNKnumber.
        // we just gotta trust its the correct data type
        chunkDisplayDriver(CHUNKnumber).

        set CHUNKnumber to CHUNKnumber+1.
        IF kOSAGCCONFIG:JSONoutput AND DISPLAYABLE {
            DSKY_JSON_OUTPUT().
        }
        IF kOSAGCCONFIG:TERMinput and CHUNKnumber = 5 or chunkNumber = 10  {
            DSKY_JSON_INPUT().
        }
        IF CHUNKnumber >= 11 {
            // (because we are indexing from zero)
            set FLSH to NOT(FLSH).
            set CHUNKnumber to 0.
        }
    }
}

local indicatorHooks is list(hook_UPLINK, hook_TEMP, hook_NO_ATT,hook_GIMBALLOCK, hook_STBY,hook_PROG,hook_KEY_REL,hook_RESTART,hook_OPR_ERR, hook_TRACKER, hook_PRIO_DISP, hook_ALT, hook_NO_DAP, hook_VEL).
LOCAL FUNCTION INDICATOR_REFRESH {
    local _indout is INDOUT:copy.
    local _indtab is INDTAB:copy.

    local _indiID is 0.
    local _indiDISPSTATE is _indtab.
    local _indiOUTSTATE is _indout.
    FOR i in _indiDISPSTATE {
        IF _indiID = 6 or _indiID = 8 { indicatorHooks[_indiID]:call. }
        ELSE {
            IF NOT(_indiDISPSTATE = _indiOUTSTATE){
                indicatorHooks[_indiID]:call.
            }
        }
        set _indiID to _indiID+1.
    }
}

FUNCTION BLANK5 {
    parameter register is "r1".
    IF register:endswith("D") { return. }
    IF DSPOUT:haskey(register) {
        set DSPOUT[register] to "bbbbbb".
    }
}

FUNCTION BLANK2 {
    parameter register is "VD".
    IF register:startswith("R") { return. }
    IF DSPOUT:haskey(register) {
        set DSPOUT[register] to "bb".
    }
}

FUNCTION SET_INPLOCK {
    parameter newInplock is "R1".

    IF LIST("MD", "VD", "ND"):contains(newInplock) {
        BLANK2(newInplock).
        set INPLOCK to newInplock.
        set INPREMAIN to 2.
    } ELSE IF LIST("R1","R2","R3"):contains(newInplock) {
        BLANK5(newInplock).
        set INPLOCK to newInplock.
        set INPREMAIN to 5.
    }
}


LOCAL FUNCTION updateAllDisplays {
    local dout is DSPOUT:copy.
    displayDriver("MD", dout:MD).
    displayDriver("VD", dout:VD).
    displayDriver("ND", dout:ND).
    displayDriver("R1", dout:R1).
    displayDriver("R2", dout:R2).
    displayDriver("R3", dout:R3).
    set DSPTAB to dout.
}

LOCAL FUNCTION displayDriver {
    parameter forDisp is "R1", displayInfo is "". // EXPECTS AND REQUIRES display info to be a length of 
    // potential change - change to support chunk numbers too
    if NOT(displayInfo:length >=2) { return. }
    IF forDisp = "MD" {
        set _DISP_MD1:image to getDisplayImage(displayInfo[0]).
        set _DISP_MD2:image to getDisplayImage(displayInfo[1]).
    }
    ELSE IF forDisp = "VD" {
        set _DISP_VD1:image to getDisplayImage(displayInfo[0]).
        set _DISP_VD2:image to getDisplayImage(displayInfo[1]). 
    } ELSE IF forDisp = "ND" {
        set _DISP_ND1:image to getDisplayImage(displayInfo[0]).
        set _DISP_ND2:image to getDisplayImage(displayInfo[1]). 
    }
    IF NOT(displayInfo:length >= 6) { return. }
    IF forDisp = "R1" {
        set _DISP_R1S:image to getDisplayImage(displayInfo[0]).
        set _DISP_R1D1:image to getDisplayImage(displayInfo[1]).
        set _DISP_R1D2:image to getDisplayImage(displayInfo[2]).
        set _DISP_R1D3:image to getDisplayImage(displayInfo[3]).
        set _DISP_R1D4:image to getDisplayImage(displayInfo[4]).
        set _DISP_R1D5:image to getDisplayImage(displayInfo[5]).
    } ELSE IF forDisp = "R2" {
        set _DISP_R2S:image to getDisplayImage(displayInfo[0]).
        set _DISP_R2D1:image to getDisplayImage(displayInfo[1]).
        set _DISP_R2D2:image to getDisplayImage(displayInfo[2]).
        set _DISP_R2D3:image to getDisplayImage(displayInfo[3]).
        set _DISP_R2D4:image to getDisplayImage(displayInfo[4]).
        set _DISP_R2D5:image to getDisplayImage(displayInfo[5]).
    } ELSE IF forDisp = "R3" {
        set _DISP_R3S:image to getDisplayImage(displayInfo[0]).
        set _DISP_R3D1:image to getDisplayImage(displayInfo[1]).
        set _DISP_R3D2:image to getDisplayImage(displayInfo[2]).
        set _DISP_R3D3:image to getDisplayImage(displayInfo[3]).
        set _DISP_R3D4:image to getDisplayImage(displayInfo[4]).
        set _DISP_R3D5:image to getDisplayImage(displayInfo[5]).
    }
}

LOCAL FUNCTION chunkDisplayDriver {
    parameter chunkNumb is 0.
    local _chunkOUT is convertIntoChunks(DSPOUT:COPY).
    local _chunkTAB is convertIntoChunks(DSPTAB:COPY).

    IF chunkNumb >= 0 and (chunkNumb > _chunkOUT:length-1 or chunkNumb > _chunkTAB:length-1) { return. }
    IF chunkNumb = 1 {
        INDICATOR_REFRESH().
    }
    IF (_chunkOUT[chunkNumb] = _chunkTAB[chunkNumb]) AND NOT(((chunkNumb = 1 or chunkNumb = 2) and NVFLASH)) { return. }

    local _cn is chunkNumb+1.
    IF _cn = 1 {
        set _DISP_MD1:IMAGE TO getDisplayImage(_chunkOUT[0][0]).
        set _DISP_MD2:IMAGE to getDisplayImage(_chunkOUT[0][1]).
    } ELSE IF _cn = 2 {
        IF NVFLASH {
            IF FLSH {
            set _DISP_VD1:image to getDisplayImage(_chunkOUT[1][0]).
            set _DISP_VD2:image to getDisplayImage(_chunkOUT[1][1]).
            }
            ELSE {
                set _DISP_VD1:IMAGE to getDisplayImage("b").
                set _DISP_VD2:IMAGE to getDisplayImage("b").
                set _chunkOUT[1] to "bb".
            }
            
        } ELSE {
            set _DISP_VD1:image to getDisplayImage(_chunkOUT[1][0]).
            set _DISP_VD2:image to getDisplayImage(_chunkOUT[1][1]).
        }
        
        
    } ELSE IF _cn = 3 {
        IF NVFLASH {
            IF FLSH {
            set _DISP_ND1:image to getDisplayImage(_chunkOUT[2][0]).
            set _DISP_ND2:image to getDisplayImage(_chunkOUT[2][1]).
            }
            ELSE {
                set _DISP_ND1:IMAGE to getDisplayImage("b").
                set _DISP_ND2:IMAGE to getDisplayImage("b").
                set _chunkOUT[2] to "bb".
            }
            
        } ELSE {
            set _DISP_ND1:image to getDisplayImage(_chunkOUT[2][0]).
            set _DISP_ND2:image to getDisplayImage(_chunkOUT[2][1]).
        }
    } ELSE IF _cn = 4 {
        set _DISP_R1D1:IMAGE to getDisplayImage(_chunkOUT[3]).
    } ELSE IF _cn = 5 {
        set _DISP_R1S:IMAGE to getDisplayImage(_chunkOUT[4][0]).
        set _DISP_R1D2:IMAGE TO getDisplayImage(_chunkOUT[4][1]).
        set _DISP_R1D3:IMAGE to getDisplayImage(_chunkOUT[4][2]).
    } ELSE IF _cn = 6 {
        set _DISP_R1D4:IMAGE to getDisplayImage(_chunkOUT[5][0]).
        set _DISP_R1D5:IMAGE to getDisplayImage(_chunkOUT[5][1]).
    } ELSE IF _cn = 7 {
        set _DISP_R2S:IMAGE TO getDisplayImage(_chunkOUT[6][0]).
        set _DISP_R2D1:IMAGE to getDisplayImage(_chunkOUT[6][1]).
        set _DISP_R2D2:IMAGE to getDisplayImage(_chunkOUT[6][2]).
    } else if _cn = 8 {
        set _DISP_R2D3:IMAGE to getDisplayImage(_chunkOUT[7][0]).
        set _DISP_R2D4:IMAGE to getDisplayImage(_chunkOUT[7][1]).
    } ELSE IF _cn = 9 {
        set _DISP_R2D5:IMAGE to getDisplayImage(_chunkOUT[8][0]).
        set _DISP_R3D1:IMAGE to getDisplayImage(_chunkOUT[8][1]).
    } ELSE IF _cn = 10 {
        set _DISP_R3S:IMAGE to getDisplayImage(_chunkOUT[9][0]).
        set _DISP_R3D2:IMAGE to getDisplayImage(_chunkOUT[9][1]).
        set _DISP_R3D3:IMAGE to getDisplayImage(_chunkOUT[9][2]).
    } ELSE IF _cn = 11 {
        set _DISP_R3D4:IMAGE to getDisplayImage(_chunkOUT[10][0]).
        set _DISP_R3D5:IMAGE TO getDisplayImage(_chunkOUT[10][1]).
    }
    set _chunkTAB[chunkNumb] to _chunkOUT[chunkNumb].
    set DSPTAB to convertFromChunks(_chunkTAB).
}

LOCAL FUNCTION getDisplayImage {
    parameter forChar is "".
    return _rootTextureFolder:Display + forChar +_fileEXT.
}

FUNCTION PINBALL_UPLINK_WORDS {
    parameter wordAction is "NOUN".

    IF _KEYRUPT_VALUES:contains(wordAction) {
        return UPRUPT_WORDS[_KEYRUPT_VALUES:FIND(wordAction)].
    } ELSE IF UPRUPT_WORDS:contains(wordAction) {
        print _KEYRUPT_VALUES[UPRUPT_WORDS:FIND(wordAction)].
        return _KEYRUPT_VALUES[UPRUPT_WORDS:FIND(wordAction)].
    } ELSE {
        return "0".
    }
    
}

FUNCTION PINBALL_KEYBOARD_WORDS {
    parameter wordAction is "NOUN".

    IF _KEYRUPT_VALUES:contains(wordAction) {
        return KEYRUPT_WORDS[_KEYRUPT_VALUES:FIND(wordAction)].
    } ELSE IF KEYRUPT_WORDS:contains(wordAction) {
        return _KEYRUPT_VALUES[KEYRUPT_WORDS:find(wordAction)].
    } ELSE IF TERMINAL_WORDS:contains(wordAction) {
        return KEYRUPT_WORDS[TERMINAL_WORDS:find(wordAction)].
    }
}

FUNCTION PINBALL_TERMINAL_WORDS {
    parameter wordAction is "N".

    IF TERMINAL_WORDS:contains(wordAction) {
        return KEYRUPT_WORDS[TERMINAL_WORDS:find(wordAction)].
    }
}


// INDICATOR FUNCTIONS

FUNCTION DSKY_INDICATOR {
    parameter ID is 0, newState is false.
    IF ID < 0 or ID >= INDOUT:length { return. }
    set INDOUT[ID] to newState.
}

LOCAL FUNCTION DSKY_INDICATOR_UPLINK {
    parameter state is INDOUT[0].
    local _ID is 0.
    IF _indicatorAtlas[_ID] = "BLANK" and NOT(INDFIRSTRUN[_ID]) { return. }
    IF _indicatorAtlas[_ID] = "NULL" {
        set INDTAB[_ID] to state.
        return.
    }
    IF state {
        set INDI_UPLINK:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_UPLINK:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    IF INDFIRSTRUN[_ID] { set INDFIRSTRUN[_ID] to false. }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_TEMP {
    parameter state is INDOUT[1].
    local _ID is 1.
    IF _indicatorAtlas[_ID] = "BLANK" and NOT(INDFIRSTRUN[_ID]) { return. }
    IF _indicatorAtlas[_ID] = "NULL" {
        set INDTAB[_ID] to state.
        return.
    }
    IF state {
        set INDI_TEMP:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_TEMP:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}




LOCAL FUNCTION DSKY_INDICATOR_NO_ATT {
    parameter state is INDOUT[2].
    local _ID is 2.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_NO_ATT:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_NO_ATT:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_GIMBAL_LOCK {
    parameter state is INDOUT[3].
    local _ID is 3.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_GIMBAL_LOCK:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_GIMBAL_LOCK:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}

LOCAL FUNCTION DSKY_INDICATOR_STBY {
    parameter state is INDOUT[4].
    local _ID is 4.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_STBY:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_STBY:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_PROG {
    parameter state is INDOUT[5].
    local _ID is 5.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_PROG:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_PROG:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}

LOCAL FUNCTION DSKY_INDICATOR_KEY_REL {
    parameter state is INDOUT[6].
    local _ID is 6.
    local state2 is state.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        IF NOT(FLSH) { set state to false. }
    }
    IF state {
        set INDI_KEY_REL:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_KEY_REL:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state2.
}

LOCAL FUNCTION DSKY_INDICATOR_RESTART {
    parameter state is INDOUT[7].
    local _ID is 7.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_RESTART:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_RESTART:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}

LOCAL FUNCTION DSKY_INDICATOR_OPR_ERR {
    parameter state is INDOUT[8].
    local _ID is 8.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    local state2 is state.
    IF state {
        IF NOT(FLSH) { set state to false. }
    }
    IF state {
        set INDI_OPR_ERR:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_OPR_ERR:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state2.
}
LOCAL FUNCTION DSKY_INDICATOR_TRACKER {
    parameter state is INDOUT[9].
    local _ID is 9.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_TRACKER:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_TRACKER:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_PRIO_DISP {
    parameter state is INDOUT[10].
    local _ID is 10.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_PRIO_DISP:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_PRIO_DISP:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_ALT {
    parameter state is INDOUT[11].
    local _ID is 11.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_ALT:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_ALT:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_NO_DAP {
    parameter state is INDOUT[12].
    local _ID is 12.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_NO_DAP:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_NO_DAP:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    IF INDFIRSTRUN[_ID] { set INDFIRSTRUN[_ID] to false. }
    set INDTAB[_ID] to state.
}
LOCAL FUNCTION DSKY_INDICATOR_VEL {
    parameter state is INDOUT[13].
    local _ID is 13.
    IF DSKY_INDICATOR_NULLCHECK(_ID, state) { return. }
    IF state {
        set INDI_VEL:IMAGE TO _rootTextureFolder:Indicators +"ON/"+ _indicatorAtlas[_ID]+_fileEXT.
    } ELSE {
        set INDI_VEL:IMAGE TO _rootTextureFolder:Indicators +"OFF/"+ _indicatorAtlas[_ID]+_fileEXT.
    }
    set INDTAB[_ID] to state.
}

LOCAL FUNCTION DSKY_INDICATOR_NULLCHECK {
    parameter ID is 0, state is "N".

    IF state:istype("String") {
        IF state = "N" {
            set state to INDOUT[ID].
        }
    }
    

    IF _indicatorAtlas[ID] = "BLANK" and NOT(INDFIRSTRUN[ID]) { return false. }
    IF INDFIRSTRUN[ID] { set INDFIRSTRUN[ID] to false. }
    IF _indicatorAtlas[ID] = "NULL" { return false. }
    ELSE { return false. }
}

// GET FUNCTIONS

FUNCTION DSKY_GETDSPTAB {
    return DSPTAB:COPY.
}

FUNCTION DSKY_GETDSPOUT {
    return DSPOUT:COPY.
}

// SETFUNCTIONS

FUNCTION DSKY_SETMAJORMODE {
    parameter mm is "bb".
    set DSPOUT:MD to mm.
}

FUNCTION DSKY_SETDISPLAYDATA {
    parameter displayData is LEXICON().
    local ___MD is DSPOUT:MD.
    local ___VD is DSPOUT:VD.
    local ___ND is DSPOUT:ND.
    local ___R1 is DSPOUT:R1.
    local ___R2 is DSPOUT:R2.
    local ___R3 is DSPOUT:R3.
    IF displayData:haskey("MD") {
        set ___MD to displayData:MD.
    }
    IF displayData:haskey("VD") {
        set ___VD to displayData:VD.
    }
    IF displayData:haskey("ND") {
        set ___ND to displayData:ND.
    }
    IF displayData:haskey("R1") {
        set ___R1 to displayData:R1.
    }
    IF displayData:haskey("R2") {
        set ___R2 to displayData:R2.
    }
    IF displayData:haskey("R3") {
        set ___R3 to displayData:R3.
    }

    SET DSPOUT to LEXICON("MD", ___MD, "VD", ___VD, "ND", ___ND, "R1", ___R1, "R2", ___R2, "R3", ___R3).
}

FUNCTION DKSY_GETDISPLAYDATA {
    parameter ofitem is "MD".

    IF DSPOUT:haskey(ofItem) {
        return DSPOUT[ofitem].
    }
    return "bb".
}

FUNCTION DSKY_SETINDICATORDATA {
    parameter indicatorData is LIST().
    local ___i is 0.
    local ___ival is FALSE.
    FOR i in indicatorData {
        set ___ival to i.
        DSKY_INDICATOR(___i, ___ival).
        set ___i to ___i+1.
    }
}

FUNCTION DSKY_GETINDICATORDATA {
    parameter ofID is 0.

    IF INDOUT:length-1 < ofID { return false. }
    ELSE IF ofID < 0 { return false. }

    return INDOUT[ofID].
}


// for specific variables

FUNCTION SETDSPLOCK {
    parameter va is false.
    set DSPLOCK TO va.
}

FUNCTION DSKY_SETFLAG {
    parameter flagName is "MONFLAG", newValue is false.

    IF flagName = "MONFLAG" { set MONFLAG to newValue. }
    ELSE IF flagname = "DSPLOCK" { set DSPLOCK to newValue. }
    ELSE IF flagname = "NVFLASH" { 
        set NVFLASH to newValue.
        IF NOT(newValue) {
            displayDriver("VD", DSPOUT:VD).
            displayDriver("ND", DSPOUT:ND).
        }
    }
    
    ELSE IF flagname = "MEMACCESS_ECADR" { set MEMORY_ACCESS:ECADR to newValue. }
    ELSE IF flagname = "MEMACCESS_STEPNAME" { set MEMORY_ACCESS:STEPNAME to newValue. }
    ELSE IF flagname = "MEMACCESS_AUTOSTEP" { set MEMORY_ACCESS:AUTO_ECADR_STEP to newValue. }

    ELSE IF flagname = "MONITORKEYREL" { set _KEYRELMONITOR to newValue. }
    ELSE IF flagname = "KEYRELBYPASS" { set _KEYRELBYPASS to newValue. }

    ELSE IF flagname = "AWAITREL" { 
        set AWAITREL to newValue.
        IF NOT(newValue) {
            SET INDOUT[6] to false.
        } 
    }

    ELSE IF flagname = "MONITORENTER" { set _ENTERMONITOR to newValue. }
    ELSE IF flagname = "ENTERBYPASS" { set _ENTERBYPASS to newValue. }

    ELSE IF flagname = "MONITORPRO" { set _PROMONITOR to newValue. }
    ELSE IF flagname = "PROBYPASS" { set _PROBYPASS to newValue. }

    ELSE IF flagname = "V37" { set _V37 to newValue. }
    ELSE IF flagname = "INPLOCK" { set INPLOCK to newValue. }
    ELSE IF flagname = "AVERAGEG" {} // not implimented

    ELSE IF flagname = "DECBRANCH" { set DECBRANCH to newValue. }
}

FUNCTION DSKY_GETFLAG {
    parameter flagName is "MONFLAG".

    local rflag is false.
    IF flagName = "MONFLAG" { set rflag to MONFLAG. }
    ELSE IF flagname = "DSPLOCK" { set rflag to DSPLOCK. }
    ELSE IF flagname = "NVFLASH" { set rflag to NVFLASH. }
    ELSE IF flagname = "KEYREL" { 
        set rflag to _KEYREL.
        IF _KEYREL { set _KEYREL TO FALSE. }
    }
    ELSE IF flagname = "ENTER" {
        set rflag to _ENTER.
        IF _ENTER { set _ENTER TO FALSE. }
    } ELSE IF flagname = "PRO" {
        set rflag to _PRO.
        IF _PRO { set _PRO TO FALSE. }
    }
    ELSE IF flagname = "AVERAGEG" { set rflag to true. } // not implimented, so always true!

    ELSE IF flagname = "DECBRANCH" { set rflag to DECBRANCH. }
    return rflag.
}

FUNCTION DSKY_DOACTION {
    parameter actionName is "PROCESS VERB".
    IF actionName = "PROCESS VERB" { VERB_PROCESSOR(). }
}


local _inputPath is "0:/kOS AGC/DSKY/AGCinput.json".
local _outputPath is "0:/kOS AGC/DSKY/AGCoutput.json".
FUNCTION DSKY_JSON_OUTPUT {
    // outputs to a file named "DSKY.json"
    local _Doutput is DSPOUT:COPY.
    local _Ioutput is INDTAB:COPY.

    // Send NVFLASH
    // Replicate the segments relevant and modify _Doutput to reflect this

    IF NVFLASH {
        IF NOT(FLSH) {
            set _Doutput:VD to "bb".
            set _Doutput:ND to "bb".
        }
    }

    IF _Ioutput[6] {
        IF NOT(FLSH) { set _Ioutput[6] to false. }
    }
    IF _Ioutput[8] {
        IF NOT(FLSH) { set _Ioutput[8] to false. }
    }
    local _writelex is LEXICON(
        "FLASH", FLSH,
        "NVFLASH", NVFLASH,

        "COMP_ACTY", false,

        "MD1", _Doutput:MD[0],
        "MD2", _Doutput:MD[1],
        "VD1", _Doutput:VD[0],
        "VD2", _Doutput:VD[1],
        "ND1", _Doutput:ND[0],
        "ND2", _Doutput:ND[1],
        "R1S", _Doutput:R1[0],
        "R1D1", _Doutput:R1[1],
        "R1D2", _Doutput:R1[2],
        "R1D3", _Doutput:R1[3],
        "R1D4", _Doutput:R1[4],
        "R1D5", _Doutput:R1[5],

        "R2S", _Doutput:R2[0],
        "R2D1", _Doutput:R2[1],
        "R2D2", _Doutput:R2[2],
        "R2D3", _Doutput:R2[3],
        "R2D4", _Doutput:R2[4],
        "R2D5", _Doutput:R2[5],

        "R3S", _Doutput:R3[0],
        "R3D1", _Doutput:R3[1],
        "R3D2", _Doutput:R3[2],
        "R3D3", _Doutput:R3[3],
        "R3D4",_Doutput:R3[4],
        "R3D5",_Doutput:R3[5],

        "I1", FALSE, // see top of file documentation
        "I2", FALSE,
        "I3", FALSE,
        "I4", FALSE,
        "I5", FALSE,
        "I6", FALSE,
        "I7", FALSE,

        "I8", FALSE,
        "I9", FALSE,
        "I10", FALSE,
        "I11", FALSE,
        "I12", FALSE,
        "I13", FALSE,
        "I14", FALSE
    ).
    local iindx is 1.
    FOR i in _Ioutput {
        set _writelex["I" + iindx:tostring] to i.
        set iindx to iindx+1.
    }
    WRITEJSON(_writelex, _outputPath).


}

// a value specific for input



FUNCTION DSKY_JSON_INPUT {
    IF kOSAGCCONFIG:TERMinput {
        IF TERMINAL:INPUT:haschar {
            local _ichar is TERMINAL:INPUT:getchar().

            KEYRUPT1(PINBALL_TERMINAL_WORDS(_ichar)).
        }
    }
}



// Specific function for getting display chunk based data, for reference



//  COMP ACTY       PROG
//  COMP ACTY    MD1 MD2
//  COMP ACTY    MD1 MD2
//
//  VERB            NOUN
//  VD1 VD2      ND1 ND2
//  VD1 VD2      ND1 ND2
//
// (LINE)
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// R1S R1D1 R1D2 R1D3 R1D4 R1D5
// (LINE)
//
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
// R2S R2D1 R2D2 R2D3 R2D4 R2D5
//
// (LINE)
// R3S R3D1 R3D2 R3D3 R3D4 R3D5
// R3S R3D1 R3D2 R3D3 R3D4 R3D5

// -- 1 
// MD1, MD2

// -- 2
// VD1, VD2

// -- 3

// ND1, ND2

// -- 4 

// R1D1

// -- 5

// R1S, R1D2, R1D3

// -- 6

// R1D4, R1D5

// -- 7

// R2S, R2D1, R2D2

// -- 8

// R2D3, R2D4

// -- 9

// R2D5, R3D1

// -- 10

// R3S, R3D2, R3D3

// -- 11

// R3D4, R3D5

local _ChunkerrorReturn is LIST("00", "00", "00", "0", "000", "00", "000", "00", "00", "000", "00").
LOCAL FUNCTION convertIntoChunks {
    parameter displayData is DSPOUT:COPY.
    local _md is displayData:MD.
    local _vd is displayData:VD.
    local _nd is displayData:ND.

    local _r1 is displayData:R1.
    local _r2 is displayData:R2.
    local _r3 is displayData:R3.

    // length check

    IF (NOT(_md:length >=2) or NOT(_vd:length >= 2)) or NOT(_nd:length >=2 ) {

        // find the offender
        IF NOT(_md:length >= 2) {
            kuniverse:DEBUGLOG("[kOS AGC|CHUNK REFRESH] MAJOR MODE LENGTH IS: " + _md:length).
        }
        IF NOT(_vd:length >= 2) {
            kuniverse:DEBUGLOG("[kOS AGC|CHUNK REFRESH] VERB DISPLAY LENGTH IS: " + _vd:length).
        }

        IF NOT(_nd:length >= 2) {
            kuniverse:DEBUGLOG("[kOS AGC|CHUNK REFRESH] NODE DISPLAY LENGTH IS: " + _nd:length).
        }
        return _ChunkerrorReturn.
    }
    IF (NOT(_r1:length >= 6) or NOT(_r2:length >=6)) or NOT(_r3:length >=6) {
        IF NOT(_r1:length >=6) {
            kuniverse:DEBUGLOG("[kOS AGC|CHUNK REFRESH] REGISTER 1 LENGTH IS: " + _r1:length).
        }
        IF NOT(_r2:length >=6) {
            kuniverse:DEBUGLOG("[kOS AGC|CHUNK REFRESH] REGISTER 2 LENGTH IS: " + _r2:length).
        }
        IF NOT(_r3:length >=6) {
            kuniverse:DEBUGLOG("[kOS AGC|CHUNK REFRESH] REGISTER 3 LENGTH IS: " + _r3:length).
        }
        return _ChunkerrorReturn.
    }
    local chunk1 is _md.
    local chunk2 is _vd.
    local chunk3 is _nd.

    local chunk4 is _r1[1].
    local chunk5 is _r1[0]+_r1[2]+_r1[3].
    local chunk6 is _r1[4]+_r1[5].

    local chunk7 is _r2[0]+_r2[1]+_r2[2].
    local chunk8 is _r2[3]+_r2[4].
    local chunk9 is _r2[5]+_r3[1].
    local chunk10 is _r3[0]+_r3[2]+_r3[3].
    local chunk11 is _r3[4]+_r3[5].


    return LIST(chunk1,chunk2,chunk3,chunk4,chunk5,chunk6,chunk7,chunk8,chunk9,chunk10,chunk11).
}

LOCAL FUNCTION convertFromChunks {
    parameter chunkData is convertIntoChunks().
    local _md is chunkData[0].
    local _vd is chunkData[1].
    local _nd is chunkData[2].

    local _r1 is chunkData[4][0]+chunkData[3]+chunkData[4][1]+chunkData[4][2]+chunkData[5].
    local _r2 is chunkData[6]+chunkData[7]+chunkData[8][0].
    local _r3 is chunkData[9][0]+chunkData[8][1]+chunkData[9][1]+chunkData[9][2]+chunkData[10].
    return lexicon(
        "MD", _md,
        "VD", _vd,
        "ND", _nd,
        "R1", _r1,
        "R2", _r2,
        "R3", _r3
    ).
}

