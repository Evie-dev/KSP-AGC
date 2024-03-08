// designed to run once upon the update of kOS-AGC
LOCAL _CMPART IS LIST("bluedog.Apollo.CrewPod", "bluedog.Apollo.CrewPod.5crew").
LOCAL _LMPART IS LIST("bluedog.LM.Taxi", "bluedog.LM.Shelter", "bluedog.LM.Ascent.Cockpit").

FUNCTION whatVehicle {
    parameter cPART is CORE:PART.
    local _iscsm is isCSM(cPART).
    local _isLM is isLM(cPART).
    IF _iscsm { return "CSM". }
    ELSE IF _isLM { return "LM". }
    ELSE { return "unknown". }
}

FUNCTION whatVech {
    parameter cPART is core:part.
    return whatVehicle(cPART).
}

FUNCTION whatCommand {
    local _vech is whatVehicle().
    IF _vech = "CSM" {
        return getCSMpart().
    } ELSE IF _vech = "LM" {
        return getLMpart().
    } ELSE { return "unknown". }
}

LOCAL FUNCTION getCSMpart {
    local rPart is 0.
    FOR i in ship:parts {
        if _CMPART:contains(i:name) { 
            set rPart to i.
            break.
        }
    }
    return rPart.
}

LOCAL FUNCTION getLMpart {
    local rPart is 0.
    FOR i in ship:parts {
        if _LMPART:contains(i:name) {
            set rPart to i.
            break.
        }
    }
    return rPart.
}

LOCAL FUNCTION isCSM {
    parameter cPART is CORE:PART.
    local csmfound is false.
    local cParent is cPART:hasparent.
    IF _CMPART:contains(cPART:NAME) {
        set csmfound to true.
    } ELSE IF cParent {
        set csmfound to _CMPART:contains(cPART:parent:name).
    }
    return csmfound.
}

LOCAL FUNCTION isLM {
    parameter cPART is CORE:PART.
    local cParent is cPART:hasparent.
    local lmfound is false.
    IF _LMPART:contains(cPART:NAME) {
        set lmFound to true.
    } ELSE IF cParent {
        set lmfound to _LMPART:contains(cPART:parent:name).
    } 
    return lmfound.
}
