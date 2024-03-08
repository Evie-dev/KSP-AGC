using System;
using System.Collections.ObjectModel;
using UnityEngine;

namespace AGCextras
{
    public class DSKY
    {
        public DSKYkeyboard keycodes = new DSKYkeyboard(); 
    }
    public class DSKYkeyboard
    {
        // this class contains methods and information regarding the DSKY structure itself

        private static readonly ReadOnlyCollection<string> _KEYPRESS = new ReadOnlyCollection<string>(new[]
        {
            "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "VERB",
            "NOUN",
            "ENTER",
            "RESET",
            "CLEAR",
            "KEY RELEASE",
            "+",
            "-"
        });

        private static readonly ReadOnlyCollection<string> _KEYPRESS_INTERNAL = new ReadOnlyCollection<string>(new[]
        {
            "0",
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "VERB",
            "NOUN",
            "ENTR",
            "RSET",
            "CLR",
            "KEY REL",
            "+",
            "-"
        });

        private static readonly ReadOnlyCollection<string> _KEYRUPT_WORDS = new ReadOnlyCollection<string>(new[]
        {
            "10000",
            "00001",
            "00010",
            "00011",
            "00100",
            "00101",
            "00110",
            "00111",
            "01000",
            "01001",
            "10001",
            "11111",
            "11100",
            "10010",
            "11110",
            "11001",
            "11010",
            "11011"
        });

        private static readonly ReadOnlyCollection<string> _UPRUPT_WORDS = new ReadOnlyCollection<string>(new[]
        {
            "1 10000 01111 10000", //1
            "1 00001 11110 00001", // 2
            "1 00010 11101 00010", // 3
            "1 00011 11100 00011",
            "1 00100 11011 00100",
            "1 00101 11001 00110",
            "1 00111 11000 00111",
            "1 01000 10111 01000",
            "1 01001 10110 01001",
            "1 10001 01110 10001",
            "1 11111 00000 11111",
            "1 11100 00011 11100",
            "1 10010 01101 10010",
            "1 11110 00001 11110",
            "1 11001 00110 11001",
            "1 11010 00101 11010",
            "1 11011 00100 11011"

            // 79-95
        });


        public static ReadOnlyCollection<string> KEYPRESS
        {
            get { return _KEYPRESS; }
        }

        public static ReadOnlyCollection<string> INTERNAL_KEYPRESS
        {
            get { return _KEYPRESS_INTERNAL; }
        }
        public static ReadOnlyCollection<string> KEYRUPT
        {
            get { return _KEYRUPT_WORDS; }
        }

        public static ReadOnlyCollection<string> UPRUPT
        {
            get { return _UPRUPT_WORDS; }
        }


        public string getKeyruptWord(string keypress)
        {
            string keyruptWord = "";
            int keypressIndex = 0;
            // option 1 - keypress default
            if (_KEYPRESS.Contains(keypress))
            {
                keypressIndex = _KEYPRESS.IndexOf(keypress);
                if (keypressIndex < 17)
                {
                    keyruptWord = _KEYPRESS[keypressIndex];
                }
                else
                {

                }
            }
            else if (_KEYPRESS_INTERNAL.Contains(keypress))
            {
                // option 2
                keypressIndex = _KEYPRESS_INTERNAL.IndexOf(keypress);
                if (keypressIndex < 17)
                {
                    keyruptWord = _KEYPRESS_INTERNAL[keypressIndex];
                }
                else
                {

                }
            }
            else
            {
                // throw error!

            }

            return keyruptWord;
        }

        public string getUpruptWord(string keypress)
        {
            string upruptWord = string.Empty;
            int upruptIndex = 0;
            if (_KEYPRESS.Contains(keypress))
            {
                upruptIndex = _KEYPRESS.IndexOf(keypress);
                if (upruptIndex < 15)
                {
                    upruptWord = _UPRUPT_WORDS[upruptIndex];
                }
                else
                {
                    // ????
                }
            }
            else if (_KEYPRESS_INTERNAL.Contains(keypress))
            {
                upruptIndex = _KEYPRESS_INTERNAL.IndexOf(keypress);
                if (upruptIndex < 15)
                {
                    upruptWord = _UPRUPT_WORDS[upruptIndex];
                }
                else
                {
                    // ????
                }
            }
            else
            {

            }
            return upruptWord;
        }

        public string getKeypress(string keycode, bool asInternal = false)
        {
            string returnKeypress = string.Empty;

            // try for keyrupt
            if (_KEYRUPT_WORDS.Contains(keycode))
            {

            }
            else if (_UPRUPT_WORDS.Contains(keycode))
            {

            }
            else
            {

            }
            return returnKeypress;
        }
    }
}
