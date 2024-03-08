using KSPAchievements;
using System;
using UnityEngine;

namespace AGCextras
{
    // seup in a similar way to the way kOS' gamesettings are set
    public class kOSAGCSettings : GameParameters.CustomParameterNode
    {
        private static kOSAGCSettings instance;

        public static kOSAGCSettings Instance
        {
            get
            {
                if (instance == null)
                {
                    if (HighLogic.CurrentGame == null)
                    {
                        instance = HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>();
                    }
                }
                return instance;
            }
        }
        public override string Title { get { return "kOS AGC Options"; } }
        public override GameParameters.GameMode GameMode { get { return GameParameters.GameMode.ANY; } }
        public override string Section { get { return "kOSAGC"; } }
        public override string DisplaySection { get { return Section; } }
        public override int SectionOrder { get { return 1; } }
        public override bool HasPresets { get { return false; } }

        [GameParameters.CustomParameterUI("DSKY display units", toolTip = "Enabling this will cause your units to be in ft or nmi", unlockedDuringMission = true)]
        public bool historicalUnits = true;
        [GameParameters.CustomParameterUI("Historical Refresh Rate", toolTip = "Enable to limit the DSKY refresh rate to 1.5Hz\n"+"(1.5Hz is 0.3 seconds)")]
        public bool historicalRefreshRates = true;
        [GameParameters.CustomParameterUI("Require Uplink", toolTip = "Requires you to manually uplink info to the AGC\n" + "Use the Antenna to do this!")]
        public bool requireDataUplink = false;

        // input output

        [GameParameters.CustomParameterUI("Chunk based refreshing", toolTip = "Enabling this will cause the DSKY to use a more realistic chunk-based refresh sequence", unlockedDuringMission = true)]
        public bool chunkRefresh = true;

        [GameParameters.CustomParameterUI("JSON Output", toolTip = "Enabling this will create an output file for use with interfacing APIs\n" + "the file is located at: [KSP directory]/ships/script/kOS AGC/DSKY/GUIexport.json\n" + "WARNING: MAY CAUSE LAG!", unlockedDuringMission = true)]
        public bool doJSONoutput = false;
        [GameParameters.CustomParameterUI("Terminal Input", toolTip = "Enabling this will allow for the user to use the terminal GUI to input data\n" + "Format can be found in the README.md file from where you downloaded this", unlockedDuringMission = true)]
        public bool doTERMINALinput = false;
        /*
         * 
         * Requirements: 
         * 
         * the ability to switch between using historical and KSP centered units
         * 
         * the ability to switch between using a 
        */
    }
}
