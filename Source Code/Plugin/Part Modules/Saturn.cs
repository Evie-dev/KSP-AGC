using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

namespace AGCextras2.Part_Modules
{

    // part modules for the saturn/saturn v
    public class ModuleApolloSaturnIU : PartModule
    {
        private const string PAWgroup = "SaturnInstrumentUnitModule";
        private const string PAWdisplay = "Instrument Unit (kOS-AGC)";

        [KSPField(groupName = PAWgroup, groupDisplayName = PAWdisplay, guiActive = true, guiActiveEditor = false, guiName = "IU Uplink", isPersistant = false),
            UI_Toggle(controlEnabled = true, enabledText = "Allow", disabledText = "Block", scene = UI_Scene.Flight)]
        public bool IUuplinkAllow = false;

        // potential idea: autosequencing
    }

    public class ModuleApolloSaturnEngine : PartModule
    {
        // Different to above, as it allows for differenciating between stages and stuff

        private const string PAWgroup = "SaturnEngineModule";
        private const string PAWdisplay = "Saturn Engine Info";
        private List<string> stageList = new List<string>() { "S-I", "S-IB", "S-IC", "S-II", "S-IV", "S-IVB" };

        [KSPField(guiName = "Engine Stage", guiActive = true, guiActiveEditor = true, isPersistant = true, groupName = PAWgroup, groupDisplayName = PAWdisplay)]
        public string engineStageDisplay;

        [KSPField(guiName = "Engine Number",guiActive = true, guiActiveEditor = true, isPersistant = true, groupName = PAWgroup, groupDisplayName = PAWdisplay)]
        public string engineNumberDisplay;

        [KSPField(isPersistant = true)]
        public int engineStageNumber = 0;

        [KSPField(isPersistant = true)]
        public int engineNumberINT = 0;

        // increase/decrease

        // stage

        [KSPEvent(guiActive = true, guiActiveEditor = true, groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "Stage+")]
        public void NextStageID() => setNextStage();

        [KSPEvent(guiActive = true, guiActiveEditor = true, groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "Stage-")]
        public void PrevStageID() => setPreviousStage();

        [KSPEvent(guiActive = true,guiActiveEditor = true, groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "ID+")]
        public void NextID() => setNextID();

        [KSPEvent(guiActive = true,guiActiveEditor =true, groupDisplayName = PAWdisplay, groupName = PAWgroup, guiName = "ID-")]
        public void PrevID() => setPreviousID();
        public override void OnStart(StartState state)
        {
            base.OnStart(state);

            setDisplay_ID();
            setDisplay_STAGE();
        }

        public void setDisplay_ID()
        {
            engineNumberDisplay = engineNumberINT.ToString();
        }
        public void setNextID()
        {
            engineNumberINT++;
            setDisplay_ID();
        }

        public void setPreviousID()
        {
            if(engineNumberINT >= 1)
            {
                engineNumberINT--;
            }
            setDisplay_ID();
        }

        public void setDisplay_STAGE()
        {
            try
            {
                engineStageDisplay = stageList[engineStageNumber];
            }
            catch
            {
                // clearly out of range, set to zero
                engineStageNumber = 0;
                engineStageDisplay = stageList[engineStageNumber];
            }

            
        }

        public void setNextStage()
        {
            if(engineStageNumber != stageList.Count)
            {
                engineStageNumber++;
            }
            setDisplay_STAGE();
        }

        public void setPreviousStage()
        {
            if(engineStageNumber >= 1)
            {
                engineStageNumber--;
            }
            setDisplay_STAGE();
        }
                
    }
}
