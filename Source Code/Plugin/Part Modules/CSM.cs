using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

namespace AGCextras2.Part_Modules
{
    public class ModuleApolloCSM : PartModule
    {
        private const string PAWname = "ProjectApollo";
        private const string PAWdisplay = "Project Apollo (CSM)";

        [KSPField(groupName = PAWname, groupDisplayName = PAWdisplay, guiActive = true, guiActiveEditor = false, isPersistant = false, guiName = "DSKY"),
            UI_Toggle(controlEnabled = true, enabledText = "DSKY Showing", disabledText = "DSKY Hidden")]
        public bool DSKYshowing = false;


    }

    public class ModuleApolloRCSquad : PartModule
    {
        private const string PAWname = "ProjectApollo";
        private const string PAWdisplay = "Project Apollo (RCS QUAD)";

        private List<string> quadIDs = new List<string>() { "A", "B", "C", "D" };

        [KSPField(guiName = "RCS Block", groupName = PAWname, groupDisplayName = PAWdisplay, guiActive = true, guiActiveEditor = true, isPersistant = true)]
        public string currentQuadID;

        [KSPField(isPersistant = true)]
        public int quadIDnumber = 0;

        [KSPEvent(guiActiveEditor = true, guiActive = true, groupName = PAWname, groupDisplayName = PAWdisplay, guiName = "RCS Quad+")]
        public void NextRCSID() => NextID();

        [KSPEvent(guiActive = true, guiActiveEditor = true, groupDisplayName = PAWdisplay, groupName = PAWname, guiName = "RCS Quad-")]
        public void PrevRCSID() => PrevID();

        public void setIDdisplay()
        {
            try
            {
                currentQuadID = quadIDs[quadIDnumber];
            }
            catch
            {
                quadIDnumber = 0;
                currentQuadID = quadIDs[quadIDnumber];
            }
        }
        public void NextID()
        {
            quadIDnumber = Math.Min(quadIDnumber++, 3);
            setIDdisplay();
        }

        public void PrevID()
        {
            quadIDnumber = Math.Max(quadIDnumber--, 0);
            setIDdisplay();
        }

        public override void OnStart(StartState state)
        {
            base.OnStart(state);

            setIDdisplay();
        }
    }
}
