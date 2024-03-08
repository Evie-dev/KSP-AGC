@CLOBBERBUILTINS.

GLOBAL _COMMONFUNC_ORBMECH_AVAILABLE IS TRUE.


FUNCTION orbMech_coe {
    // Classical Orbital Elements from the State Vectors (Position and Velocity)
    parameter sv_pos is ship:body:position, sv_vel is ship:velocity:orbit.


    local _retSTATE is lexicon(
        "Apoapsis", LEXICON("a", 0, "r", 0),
        "Periapsis", LEXICON("a", 0, "r", 0),
        "Altitude", LEXICON("a", 0, "r", 0),
        "mu", 0,
        "semimajoraxis", 0,
        "Inclination", 0,
        "Eccentricity", 0,
        "TrueAnomaly", 0
    ).

    local r_vec is sv_pos.
    local v_vec is sv_vel.

    local _mu is ship:body:mu.
    local _rad is ship:body:radius.

    local _r is r_vec:mag.
    local _v is v_vec:mag.

    local v_r is VDOT(r_vec/_r, v_vec).
    local v_p is sqrt(_v^2-v_r^2).


    // h 

    local h_vec is vcrs(r_vec, v_vec).

    local _h is h_vec:mag.

    local _i is arcCos(h_vec:y/_h).
    local _K is v(0,0,1).
    local N_vec is vCrs(_K, h_vec).
    local _N is N_vec:mag.
    local _Omega is 2*constant:pi-arcCos(N_vec:x/_N).

    local e_vec is vCrs(v_vec, h_vec) / _mu - r_vec / _r.
    local _e is e_vec:mag.

    local __omega is 2*constant:pi - arcCos(vdot(N_vec, e_vec)/(_N*_e)).

    local nu is arcCos(vdot(r_vec/_r, e_vec/_e)).

    local rA is (_h^2/_mu)*(1/1+_e).
    local rP is (_h^2/_mu)*(1/1-_e). // these should be the radius i think
    local _a is (rP+rA)/2.


    set _retSTATE:Apoapsis:r to rA.
    set _retSTATE:Periapsis:r to rP.
    set _retSTATE:Altitude:r to _r.

    // set the "a" parts

    set _retSTATE:Apoapsis:a to _retSTATE:Apoapsis:r-_rad.
    set _retSTATE:Periapsis:a to _retSTATE:Periapsis:r-_rad.
    set _retSTATE:Altitude:a to _retSTATE:Altitude:r-_rad.

    set _retSTATE:mu to _mu.
    set _retSTATE:Semimajoraxis to _a.
    set _retSTATE:Inclination to _i.
    set _retSTATE:eccentricity to _e.
    set _retSTATE:trueanomaly to nu.

    return _retSTATE.

}

FUNCTION orbMech_Period {
    // calculates orbital period

    parameter _a is ship:orbit:semimajoraxis, _mu is ship:body:mu.

    return (2*constant:pi)*(sqrt((_a^3)/_mu)).
}


// Node independent, ignores them using some trickery, though takes 3 timesteps for safety
FUNCTION r_v_predictor {
    parameter inTIME is 0.

    local _predictionUT is time:seconds+inTIME.
    local _vt1 is 0.
    local _rt1 is 0.
    IF hasNode {
        local _predictorNode is nextNode.
        IF NOT(_predictorNode:time > _predictionUT) {
            local ndINFO is lexicon(
                "t", 0,
                "p", 0,
                "r", 0,
                "n", 0
            ).

            set ndINFO:t to _predictorNode:time.
            set ndINFO:p to _predictorNode:prograde.
            set ndINFO:r to _predictorNode:radialout.
            set ndINFO:n to _predictorNode:normal.


            // remove the node

            remove _predictorNode.

            wait 0.

            set _vt1 to velocityAt(ship, _predictionUT).
            set _rt1 to positionAt(ship, _predictionUT).

            wait 0.

            local _ndADD is NODE(ndINFO:t, ndINFO:r, ndINFO:n, ndINFO:p).

            add _ndADD.

            return list(_vt1, _rt1).
        }
    }
    // hasnt returned yet

    set _vt1 to velocityat(ship, _predictionUT).
    set _rt1 to positionAt(ship, _predictionUT).

    return list(_vt1, _rt1).
}

FUNCTION orbMech_GravityVector {
    parameter gv_v is ship:velocity:orbit, gv_r is ship:body:position.
    // may return positive or negative, i honestly do not know!
    return gv_r/gv_r:mag^3*body:mu.
}

FUNCTION orbMech_orbSpeed {
    parameter r1 is apoapsis, r2 is periapsis, r3 is altitude, needsRadiusAdded is true.
    IF needsRadiusAdded {
        set r1 to r1+body:radius.
        set r2 to r2+body:radius.
        set r3 to r3+body:radius.
    }
    local _a is orbMech_semiMajorAxis(r1,r2,false).

    return SQRT(body:mu*((2/r3)-(1/_a))).
}

FUNCTION orbMech_semiMajorAxis {
    parameter r1 is apoapsis, r2 is periapsis, needsRadiusAdded is true.

    IF needsRadiusAdded {
        set r1 to r1+body:radius.
        set r2 to r2+body:radius.
    }
    return (r1+r2)/2.
}




FUNCTION orbMech_VMN {
    parameter t, p,n,_r, justBurnVector is true. // time, prograde, normal, radial component
    // we should do this part first, as its somewhat frame dependent, credit to nuggreat
    //"From this simply multply the each of the 3 state vectors by the amount of deltaV on that axis, sum the vectors and you have the burn vector for the maneuver.  Also keep in mind that below 100km in altitude stored vectors are only correct for the physics frame they are calculated in unless you frame shift them into a non-volatile frame. "
    // To solve the volitility i may move it into my kOS-AGC extras and perform a toggle whereby i:
    // call a function to "START" the calculation and ensure that i have the time and stuff to do said calculation in the "Update" portion of KSP's gameloop

    // these first three "should" keep things somewhat neater
    local TIG_r is positionAt(SHIP,t).
    local TIG_rLocal is TIG_r-body:position.
    local TIG_v is velocityAt(ship,t).
    local TIG_o is ORBITAT(SHIP,t).


    LOCAL localBody IS TIG_o:BODY.
    local r_adjustment is TIG_r - localBody:POSITION.
    LOCAL vecNodePrograde IS TIG_v:ORBIT:NORMALIZED.
    LOCAL vecNodeNormal IS VCRS(vecNodePrograde,r_adjustment:NORMALIZED):NORMALIZED.
    LOCAL vecNodeRadial IS VCRS(vecNodeNormal,vecNodePrograde):NORMALIZED.

    // now we can do the pv

    local pvPrograde is vecNodePrograde*p.
    local pvNormal is vecNodeNormal*n.
    local pvRadial is vecNodeRadial*_r.

    local bvr is pvPrograde+pvNormal+pvRadial.


    IF justBurnVector { return bvr. }
    ELSE { 
        // return the bvr and a coe
        
        local retdict is lexicon().
        retdict:add("bvr", bvr).
        retdict:add("V1", TIG_V:orbit).
        retdict:add("V2", TIG_v:orbit+bvr).
        local _predictionCOE is orbMech_coe(TIG_rLocal, retdict:V2).
        retdict:add("COE", _predictionCOE).
        return retdict.
    }
}