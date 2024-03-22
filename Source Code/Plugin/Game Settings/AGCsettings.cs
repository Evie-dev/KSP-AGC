using KSPAchievements;
using System;
using UnityEngine;

// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

namespace AGCextras2.Game_Settings
{
    public class kOSAGCSettings : GameParameters.CustomParameterNode
    {
        private static kOSAGCSettings instance;

        public static kOSAGCSettings Instance
        {
            get
            {
                if(instance == null)
                {
                    if(HighLogic.CurrentGame == null)
                    {
                        instance = HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>();
                    }
                }
                return instance;
            }
            
        }

        public override string Title { get { return "kOS-AGC GAME SETTINGS"; } }
        public override string Section {  get { return "kOS-AGC";  } }
        public override string DisplaySection { get { return Section; } }
        public override GameParameters.GameMode GameMode { get { return GameParameters.GameMode.ANY; } }

        public override int SectionOrder { get { return 1; } }
        public override bool HasPresets { get { return false; } }


        // settings

        // -- Historical units --

        [GameParameters.CustomParameterUI("Use Historically Accurate Units", toolTip = "Enable this to have units that match that of the AGC (ft/s, nmi, ft, ect ect", autoPersistance = true)]
        public bool useHistoricalUnits = true;

        [GameParameters.CustomParameterUI("Use Historically accurate refresh rate")]
        public bool useRealRefreshRate = true;

        [GameParameters.CustomParameterUI("Use chunk based refreshing", toolTip = "Enable this to have the AGC refresh as it would in the real world" + "\n" + "This means that the AGC refreshes in bits as opposed to refreshing all at once", unlockedDuringMission = true, autoPersistance = true)]
        public bool refreshInChunks = true;

        [GameParameters.CustomParameterUI("Enable Clicking", toolTip = "Enable this to hear latchbing relay drivers", autoPersistance = true, unlockedDuringMission = true)]
        public bool doClicking = true;

        [GameParameters.CustomParameterUI("Enable ASPL Features", toolTip = "Enable this to allow for integration with the Apollo Simulation Peripheral Lab's web DSKY GUI", unlockedDuringMission = true, autoPersistance = true)]
        public bool ASPLpermission = false;

        [GameParameters.CustomParameterUI("Enforce Memory Maximums", toolTip = "Enable this for a more realistic experience" + "\n" + "Some values in the AGC had a maximum storable value, if this setting is enabled, that will be enforced")]
        public bool enforceMemoryMaximums = false;
    }
}
