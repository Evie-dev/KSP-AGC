using KSP.UI.Screens.Flight;
using System;
using UnityEngine;

namespace AGCextras
{
    public class ModuleApolloCM : PartModule
    {
        private const string PAWgroup = "ProjectApollo";
        private const string PAWdisplay = "kOS AGC (CM)";
        // the DKSY 

        [KSPField(groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "DSKY", guiActive = true, guiActiveEditor = false, isPersistant = false),
        UI_Toggle(controlEnabled = true, disabledText = "DSKY Hidden", enabledText = "DSKY Showing", scene = UI_Scene.Flight)]
        public bool DSKYshowing = false;

        // the EMS (WIP and may not be implimented)

        [KSPField(groupName = PAWgroup, groupDisplayName = PAWdisplay, guiName = "EMS", guiActive = true, guiActiveEditor = false, isPersistant = false), UI_Toggle(controlEnabled = true, disabledText = "EMS Hidden", enabledText = "EMS Showing", scene =UI_Scene.Flight)]
        public bool EMSshowing = false;
    }
}
