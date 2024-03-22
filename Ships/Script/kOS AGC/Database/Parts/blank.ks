// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

// a blank database set

LOCAL BLANKdatabase is LEXICON(
    "CSM", LEXICON(
        "CM", LEXICON(
            "LES", LIST(
            ),
            "APEX", LIST(

            ),
            "CM", LIST(
            ),
            "HEATSHIELD", LIST(
            ),
            "DROUGE", LIST(
            ),
            "MAIN", LIST(
            )
        ),
        "SM", LEXICON(
            "Separator", LIST(
            ),
            "SM", LIST(
            ),
            "Scimitar", LIST(
            ),
            "HGA", LIST(
            ),
            "DOPLER_ANTT", LIST(
            ),
            "ENGINE_MOUNT", LIST(
            ),
            "EVA_LIGHT", LIST(
            ),
            "RCS", LIST(),
            "DOCKING_LIGHT", LIST(
            ),
            "SPS", LIST(
            )
        )
    ),
    "LEM", LIST(
        "ASCENT", LEXICON(
            
            "ENGINE", LIST(
            )
        ),
        "DESCENT", LEXICON(

        )
    ),
    "Saturn", LEXICON(

    )
).

FUNCTION getBlankDatabase {
    parameter forVehicle is "CSM".

    IF BLANKdatabase:haskey(forVehicle) {
        return BLANKdatabase:COPY[forVehicle].
    } ELSE {
        return BLANKdatabase:copy.
    }
}