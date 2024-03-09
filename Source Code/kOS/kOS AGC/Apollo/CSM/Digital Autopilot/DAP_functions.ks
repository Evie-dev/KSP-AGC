// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


FUNCTION ACTIVATE_DAP {
    // changes or activates the dap settings

    local ddata1 is EMEM_READ("DAPDATR1").
    local ddata2 is EMEM_READ("DAPDATR2").

    
    local dinf1 is getDinf(ddata1).
    local dinf2 is getDinf(ddata2).

    


}

LOCAL FUNCTION getDinf {
    parameter ofdata is "01010".
    local dinf is lexicon("A",0,"B",0,"C",0,"D",0,"E",0).
    local dinfVal is dinf:keys.
    local dinfIndexer is 0.
    local _wrkkey is "".
    FOR i in ofData {
        set _wrkkey to dinfVal[dinfIndexer].
        IF dinf:haskey(_wrkkey) {
            set dinf[_wrkkey] to i:tonumber(0).
        }

        set dinfIndexer to dinfIndexer+1.
    }

    return dinf.
}