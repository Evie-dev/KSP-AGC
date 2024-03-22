using System.Collections.Generic;
using AGCextras;
using AGCextras2.Game_Settings;
using AGCextras2.Utilities;
using kOS.Safe.Encapsulation;
using kOS.Safe.Encapsulation.Suffixes;
using kOS.Safe.Exceptions;
using kOS.Safe.Utilities;
using kOS.Suffixed;
using kOS.Utilities;
using UnityEngine;

// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

namespace kOS.AddOns.AGC
{
    [kOSAddon("AGC")]
    [KOSNomenclature("KOSAGCADDON")]
    public class Addon : Suffixed.Addon
    {
        public Addon(SharedObjects shared) : base(shared)
        {
            InitilizeSuffixes();
        }

        private void InitilizeSuffixes()
        {


            AddSuffix(new[] { "UNITCONFIG", "UNITS" }, new NoArgsSuffix<BooleanValue>(getUnitConfig, "Returns kOS-AGC's Unit configuration"));
            AddSuffix(new[] { "REFRESHRATE", "REFRESH", "REFRATE" }, new NoArgsSuffix<BooleanValue>(getRefreshRate, "Returns if we use a quick refresh rate"));
            AddSuffix(new[] { "CHUNKREFRESH", "REFTYPE" }, new NoArgsSuffix<BooleanValue>(doChunkRefreshing, "returns if we are allowing chunk based refreshing"));
            AddSuffix(new[] { "DOCLICK", "CLICKING" }, new NoArgsSuffix<BooleanValue>(AGCclicker, "returns the click setting"));
            AddSuffix(new[] { "EXTERNALAPI", "ASPL", "JSONoutput", "TERMINALINPUT" }, new NoArgsSuffix<BooleanValue>(ASPL));

            AddSuffix(new[] { "RELAYCLICK", "AGCCLICK" }, new OneArgsSuffix<ScalarValue>(doAGCclick, "click"));
        }

        // CONFIG configurations

        private BooleanValue getUnitConfig()
        {
            // gets the information regarding the user's selection of 
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().useHistoricalUnits;
            }
            catch
            {
                return true;
            }
        }

        private BooleanValue getRefreshRate()
        {
            // gets the information regarding the user's selection of 
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().useHistoricalUnits;
            }
            catch
            {
                return true;
            }
        }

        private BooleanValue doChunkRefreshing()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().refreshInChunks;
            }
            catch
            {
                return false;
            }
        }

        private BooleanValue AGCclicker()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().doClicking;
            }
            catch
            {
                return true;
            }
        }

        private BooleanValue ASPL()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().ASPLpermission;
            }
            catch
            {
                return false;
            }
        }

        private void doAGCclick(ScalarValue clickNumber)
        {
            AGCsounds Asounds = new AGCsounds();
            Asounds.playClick((double)clickNumber);
        }

        public override BooleanValue Available()
        {
            return true;
        }


    }
}
