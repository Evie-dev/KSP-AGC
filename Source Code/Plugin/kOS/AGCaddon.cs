// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


using System;
using UnityEngine;
using kOS;
using kOS.AddOns;
using kOS.Safe.Encapsulation;
using AGCextras;
using kOS.Safe.Encapsulation.Suffixes;
using System.Net.NetworkInformation;
using kOS.Safe.Function;

namespace kOS.Addons.kOSAGC
{
    // this actually contains two addons to assist in keeping them seprate
    [kOSAddon("AGC")]
    [kOS.Safe.Utilities.KOSNomenclature("AGCaddon")]

    public class AGCaddon : Suffixed.Addon
    {
        public AGCaddon(SharedObjects shared) : base (shared)
        {
            InitilizeSuffixes();
        }
        private void InitilizeSuffixes()
        {
            AddSuffix("UNITS", new Suffix<BooleanValue>(GetUnitConifg, "Returns the unit config for kOS AGC"));
            AddSuffix("REFRATE", new Suffix<BooleanValue>(getRefreshRate, "Returns if we use a historical refresh rate"));
            AddSuffix("REFTYPE", new Suffix<BooleanValue>(getRefreshType, "Chunk based refresh logic?"));
            AddSuffix("JSONoutput", new Suffix<BooleanValue>(getDisplayOutput, "Enable JSON writing for display buffer"));
            AddSuffix("TERMINALINPUT", new Suffix<BooleanValue>(getInputToggle, "Do we allow terminal input"));

            AddSuffix("DOCLICK", new Suffix<BooleanValue>(doClicking, "Allow click"));
            AddSuffix("AGCCLICK", new OneArgsSuffix<ScalarValue>(doAGCclick, "click"));

        }

        private BooleanValue GetUnitConifg()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().historicalUnits;
            }
            catch
            {
                return false;
            }
            
        }
        private BooleanValue getRefreshRate()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().historicalRefreshRates;
            }
            catch
            {
                return false;
            }
        }

        private BooleanValue getRefreshType()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().chunkRefresh;
            }
            catch
            {
                return false;
            }
        }
        
        private BooleanValue getDisplayOutput() {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().doJSONoutput;
            } catch
            {
                return false;
            }
        }

        private BooleanValue getInputToggle()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().doTERMINALinput;
            } catch
            {
                return false;
            }
        }

        private BooleanValue doClicking()
        {
            try
            {
                return HighLogic.CurrentGame.Parameters.CustomParams<kOSAGCSettings>().allowClickclickclickclickclick;
            } catch { return false; }
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
