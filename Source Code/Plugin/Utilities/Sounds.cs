// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using KSP;
using System.Linq.Expressions;
using System.Text.RegularExpressions;

namespace AGCextras
{
    [KSPAddon(KSPAddon.Startup.Flight,false)]
    public class AGCsounds : MonoBehaviour
    {
        List<string> singleClick = new List<string>() { "kOS-Addons/AGC/Sounds/clicks1_0", "kOS-Addons/AGC/Sounds/clicks1_1","kOS-Addons/AGC/Sounds/clicks1_2","kOS-Addons/AGC/Sounds/clicks1_3","kOS-Addons/AGC/Sounds/clicks1_4" };
        List<string> dualClick = new List<string>() { "kOS-Addons/AGC/Sounds/clicks2_0", "kOS-Addons/AGC/Sounds/clicks2_1", "kOS-Addons/AGC/Sounds/clicks2_2", "kOS-Addons/AGC/Sounds/clicks2_3", "kOS-Addons/AGC/Sounds/clicks2_4" };
        List<string> tripleClick = new List<string>() { "kOS-Addons/AGC/Sounds/clicks3_0", "kOS-Addons/AGC/Sounds/clicks3_1", "kOS-Addons/AGC/Sounds/clicks3_2", "kOS-Addons/AGC/Sounds/clicks3_3", "kOS-Addons/AGC/Sounds/clicks3_4" };
        List<string> fourClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks4_0", "kOS-Addons/AGC/Sounds/clicks4_1", "kOS-Addons/AGC/Sounds/clicks4_2", "kOS-Addons/AGC/Sounds/clicks4_3", "kOS-Addons/AGC/Sounds/clicks4_4" };
        List<string> fiveClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks5_0", "kOS -Addons/AGC/Sounds/clicks5_1", "kOS-Addons/AGC/Sounds/clicks5_2", "kOS-Addons/AGC/Sounds/clicks5_3", "kOS-Addons/AGC/Sounds/clicks5_4" };
        List<string> sixClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks6_0", "kOS-Addons/AGC/Sounds/clicks6_1", "kOS-Addons/AGC/Sounds/clicks6_2", "kOS-Addons/AGC/Sounds/clicks6_3", "kOS-Addons/AGC/Sounds/clicks6_4" };
        List<string> sevenClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks7_0", "kOS-Addons/AGC/Sounds/clicks7_1", "kOS-Addons/AGC/Sounds/clicks7_2", "kOS-Addons/AGC/Sounds/clicks7_3", "kOS-Addons/AGC/Sounds/clicks7_4" };
        List<string> eightClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks8_0", "kOS-Addons/AGC/Sounds/clicks8_1", "kOS-Addons/AGC/Sounds/clicks8_2", "kOS-Addons/AGC/Sounds/clicks8_3", "kOS-Addons/AGC/Sounds/clicks8_4" };
        List<string> nineClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks9_0", "kOS-Addons/AGC/Sounds/clicks9_1", "kOS-Addons/AGC/Sounds/clicks9_2", "kOS-Addons/AGC/Sounds/clicks9_3", "kOS-Addons/AGC/Sounds/clicks9_4" };
        List<string> tenClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks10_0", "kOS-Addons/AGC/Sounds/clicks10_1", "kOS-Addons/AGC/Sounds/clicks10_2", "kOS-Addons/AGC/Sounds/clicks10_3", "kOS-Addons/AGC/Sounds/clicks10_4" };
        List<string> elevenClicks = new List<string>() { "kOS-Addons/AGC/Sounds/clicks11_0", "kOS-Addons/AGC/Sounds/clicks11_1", "kOS-Addons/AGC/Sounds/clicks11_2", "kOS-Addons/AGC/Sounds/clicks11_3", "kOS-Addons/AGC/Sounds/clicks11_4" };
        List<string> clickFiles;
        Vessel vesselActive;
        System.Random clickInstantiate = new System.Random();
        int randomClicks;
        bool clickerCreated = false;
        FXGroup kOSclicker = new FXGroup("Clicker");

        void Start()
        {
            Debug.Log("[kOS AGC SOUNDS] Loading sounds!");

            vesselActive = FlightGlobals.ActiveVessel;
            if(vesselActive == null)
            {
                return;
            }

            createClicker();
        }

        void createClicker()
        {
            if(clickerCreated) { return; }
            vesselActive = FlightGlobals.ActiveVessel;
            GameObject kOSaudio = new GameObject("kOS AUDIO");
            kOSaudio.transform.parent = vesselActive.gameObject.transform;
            kOSclicker.audio = kOSaudio.AddComponent<AudioSource>();
            kOSclicker.audio.loop = false;
            kOSclicker.audio.spatialBlend = 0;
            kOSclicker.audio.bypassEffects = true;
            kOSclicker.audio.Stop();

            clickerCreated = true;
        }
        public void playClick(double clickNumber = 1)
        {
            if (!clickerCreated)
            {
                createClicker();
            }
            int randomClicks = clickInstantiate.Next(0, 4);
            
            if (clickNumber == 1)
            {
                clickFiles = singleClick;
            } else if (clickNumber == 2) { clickFiles = dualClick; }
            else if (clickNumber == 3) { clickFiles = tripleClick; }
            else if (clickNumber == 4) { clickFiles = fourClicks; }
            else if (clickNumber == 5) { clickFiles = fiveClicks; }
            else if (clickNumber == 6) { clickFiles = sixClicks; }
            else if (clickNumber == 7) { clickFiles = sevenClicks; }
            else if (clickNumber == 8) { clickFiles = eightClicks; }
            else if (clickNumber == 9) { clickFiles = nineClicks; }
            else if (clickNumber == 10) { clickFiles = tenClicks; }
            else if (clickNumber == 11) { clickFiles = elevenClicks; }

            kOSclicker.audio.clip = GameDatabase.Instance.GetAudioClip(clickFiles[randomClicks]);

            kOSclicker.audio.Play();
        }
    }
}
