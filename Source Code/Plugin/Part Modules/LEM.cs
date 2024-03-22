using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT

namespace AGCextras2.Part_Modules
{
    public class ModuleApolloLEM : PartModule
    {
        private const string PAWname = "ProjectApollo";
        private const string PAWdisplay = "Project Apollo (LEM)";

        [KSPField(groupName = PAWname, groupDisplayName = PAWdisplay, guiActive = true, guiActiveEditor = false, isPersistant = false, guiName = "DSKY"),
            UI_Toggle(controlEnabled = true, enabledText = "DSKY Showing", disabledText = "DSKY Hidden")]
        public bool DSKYshowing = false;

        [KSPField(groupName = PAWname, groupDisplayName = PAWdisplay, guiActive = true, guiActiveEditor = false, isPersistant = false, guiName = "AGS"),
            UI_Toggle(controlEnabled = true, enabledText = "AGS Showing", disabledText = "AGS Hidden")]
        public bool AGSshowing = false;
    }
}
