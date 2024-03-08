using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace AGCextras
{
    
    public class ModuleApolloLGC : PartModule
    {
        private const string PAWgroup = "ProjectApollo";
        private const string PAWdisplay = "kOS AGC (LM)";
        // the DKSY 

        [KSPField(groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "DSKY", guiActive = true, guiActiveEditor = false, isPersistant = false),
        UI_Toggle(controlEnabled = true, disabledText = "DSKY Hidden", enabledText = "DSKY Showing", scene = UI_Scene.Flight)]
        public bool DSKYshowing = false;

        // the AGS

        [KSPField(groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "AGS", guiActive = true, guiActiveEditor = false, isPersistant = false),
        UI_Toggle(controlEnabled = true, disabledText = "AGS Hidden", enabledText = "AGS Showing", scene = UI_Scene.Flight)]
        public bool AGSshowing = false;
    }
}
