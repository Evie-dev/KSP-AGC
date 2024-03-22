runOncePath("0:/kOS AGC/Database/Parts/all.ks").

local _partDatabase is getDatabaseComponent("BDB", "CSM").


// for a demonstration, we will toggle the CSM SPS

doPartEvent(_partDatabase:SM:SPS, "Activate Engine").