runOncePath("0:/Common/common_orbMech.ks").

local _blankspace is " ".

local _outputs is list().


AG1 OFF.

clearScreen.
IF NOT(hasnode) { print "NEEDS A NODE!". }
wait until hasnode.

UNTIL AG1 {
    clearScreen.
    print "NODE DETECTED, AG1 WHEN FINISHED!".
    wait 0.
}
local _currentNode is nextNode.

local _cnodePrograde is _currentNode:prograde.
local _cnodeNormal is _currentNode:Normal.
local _cnodeRadialout is _currentNode:radialout.
local _cTIME is _currentNode:time.


// aproximates
local _V1 is velocityAt(SHIP, _currentNode:time-1).
local _V2 is velocityAt(SHIP, _currentNode:time+1).

_outputs:add("------ NODE DATA ------ ").
_outputs:add(_blankspace).
_outputs:add("RAW NODE COLLECTED DATA").
_outputs:add("PROGRADE: " + _cnodePrograde:tostring).
_outputs:add("NORMAL: " + _cnodeNormal:tostring).
_outputs:add("RADIALOUT: " + _cnodeRadialout:tostring).
_outputs:add(_blankspace).
_outputs:add("TIME: " + _cTIME:tostring).
_outputs:add("BURN VECTOR: v(" + _currentNode:deltav:x:tostring + "," + _currentNode:deltav:y + "," + _currentNode:deltav:z:tostring + ")").
_outputs:add(_blankspace).
_outputs:add("V1: " + _V1:orbit:mag:tostring).
_outputs:add("v(" + _V1:orbit:x:tostring + "," + _V1:orbit:Y:tostring + "," + _V1:orbit:Z:TOSTRING + ")").
_outputs:add(_blankspace).
_outputs:add("V2: " + _V2:orbit:mag:tostring).
_outputs:add("v(" + _V2:orbit:x:tostring + "," + _V2:orbit:Y:tostring + "," + _V2:orbit:Z:TOSTRING + ")").
wait 0.

remove nextNode.

wait 0.

local virtualNode is orbMech_VMN(_cTIME, _cnodePrograde, _cnodeNormal, _cnodeRadialout, FALSE).
LOG virtualNode:COE to "0:/COE.txt".
_outputs:add("----- VIRTUAL NODE DATA ------").
_outputs:add(_blankspace).
_outputs:add("COLLECTED:").
_outputs:add("V1: " + virtualNode:V1:mag:tostring).
_outputs:add("v(" + virtualNode:V1:x:tostring + "," + virtualNode:V1:Y:tostring + "," + virtualNode:V1:Z:TOSTRING + ")").
_outputs:add(_blankspace).
_outputs:add("V2: " + virtualNode:V2:mag:tostring).
_outputs:add("v(" + virtualNode:V2:x:tostring + "," + virtualNode:V2:Y:tostring + "," + virtualNode:V2:Z:TOSTRING + ")").
_outputs:add(_blankspace).
_outputs:add("Resultant Orbit:").
_outputs:add("R1: " + virtualNode:COE:Apoapsis:a:tostring).
_outputs:add("R2: " + virtualNode:COE:Periapsis:a:tostring).


local _outputFile is "0:/virtualNodeData.txt".
FOR i in _outputs {
    LOG i to _outputFile.
}

wait 0.
local _addNodeReadd is NODE(_cTIME, _cnodeRadialout, _cnodeNormal, _cnodePrograde).
add _addNodeReadd.