// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

LOCAL BDBdatabase is LEXICON(
    "CSM", LEXICON(
        "CM", LEXICON(
            "LES", LIST(
                "bluedog.Apollo.LES"
            ),
            "APEX", LIST(
                "bluedog.Apollo.Block1.Nose",
                "bluedog.Apollo.ParachuteCover"

            ),
            "CM", LIST(
                "bluedog.Apollo.Boilerplate",
                "bluedog.Apollo.CrewPod",
                "bluedog.Apollo.CrewPod.5crew"
            ),
            "HEATSHIELD", LIST(
                "bluedog.Apollo.Heatshield"
            ),
            "DROUGE", LIST(
                "bluedog.Apollo.DrogueChute"
            ),
            "MAIN", LIST(
                "bluedog.Apollo.MainChute"
            )
        ),
        "SM", LEXICON(
            "Separator", LIST(
                "bluedog.Apollo.Decoupler"
            ),
            "SM", LIST(
                "bluedog.Apollo.Block2.SM",
                "bluedog.Apollo.Block3.SM",
                "bluedog.Apollo.Block4.SM"
            ),
            "Scimitar", LIST(
                "bluedog.Apollo.ScimitarAntenna"
            ),
            "HGA", LIST(
                "bluedog.Apollo_Block2.highGain",
                "bluedog.Apollo.Block3.highGain",
                "bluedog.Apollo.Block5.highGain"
            ),
            "DOPLER_ANTT", LIST(
                "bluedog.Apollo.DopplerAntenna"
            ),
            "ENGINE_MOUNT", LIST(
                "bluedog.Apollo.EngineMount"
            ),
            "EVA_LIGHT", LIST(
                "bluedog.Apollo.EVAFloodlight"
            ),
            "RCS", LIST(
                "bluedog.Apollo.RCS.Quad"
            ),

            "DOCKING_LIGHT", LIST(
                "bluedog.Apollo.DockingSpotlight"
            ),
            "SPS", LIST(
                "bluedog.Apollo.Block2.SPS"
            )
        )
    ),
    "LEM", LIST(
        "ASCENT", LEXICON(
            
            "ENGINE", LIST(
                "bluedog.LM.Ascent.Engine"
            )
        ),
        "DESCENT", LEXICON(

        )
    ),
    "Saturn", LEXICON(
        "S-IC", LEXICON(
            "DECOUPLER", LIST(
                "bluedog.Saturn.S1C.Decoupler"
            )
        ),
        "S-II", LEXICON(

        ),
        "S-IVB", LEXICON(
            "SLA", LIST(

            ),
            "IU", LIST()
        )
    )
).

FUNCTION getBDBdatabase {
    parameter forVehicle is "CSM".

    IF BDBdatabase:haskey(forVehicle) {
        return BDBdatabase:copy[forVehicle].
    } ELSE {
        return BDBdatabase:copy.
    }
}
