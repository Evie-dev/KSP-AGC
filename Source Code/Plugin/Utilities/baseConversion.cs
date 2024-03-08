using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static EdyCommonTools.ObjectUtility;

namespace AGCextras
{
    public class class_baseConversion
    {
        public ulong tobase(int inputBase, int outputBase, double inputValue, int maxItterations = 28, bool doOnesComp = false)
        {
            ulong result = 0;

            int iB;
            int oB;
            double iV;
            int iM;
            bool oC;

            iB = inputBase;
            oB = outputBase;
            iV = inputValue;
            iM = maxItterations;
            oC = doOnesComp;

            if (oC)
            {
                iV = (double)tobase(2, iB, (double)onesComp(tobase(iB, 2, iV, iM), iM), iM);
            }

            if (iB != oB)
            {
                if (iB > oB)
                {
                    result = downbase(iB, oB, iV, iM);
                }
                else
                {
                    // to do this we want to ideally change this to binary to ensure its actually easier for us

                    iV = (double)tobase(inputBase, 2, iV, iM);
                    result = upbase(2, oB, iV, iM);
                }
            }
            else
            {
                result = (ulong)iV;
            }

            return result;
        }

        public ulong upbase(int inputBase, int outputBase, double inputValue, int maxItterations = 28)
        {
            // a C# implimentation of FromBase (Common/common_usefulstuff.ks)
            ulong result = 0;



            int expon;

            int iB;
            int oB;
            int iM;
            int i;

            double iV;
            double resultant;
            double exponentResultant;
            double iNumb;

            string sV = string.Empty;
            char ichar;

            iB = inputBase;
            oB = outputBase;
            i = 0;
            iV = inputValue;
            iM = maxItterations;
            resultant = 0;
            exponentResultant = 0;

            sV = iV.ToString();
            expon = sV.Length - 1;
            if (sV.Contains(".")) { expon--; }

            while (expon != -1)
            {
                if (i > iM) { break; }
                if (i < sV.Length)
                {
                    ichar = sV[i];
                    if (ichar != '.')
                    {
                        iNumb = double.Parse(ichar.ToString());
                        exponentResultant = iNumb * Math.Pow(iB, expon);
                        resultant = resultant + exponentResultant;
                        expon--;
                    }
                }
                i++;
            }
            try
            {
                result = (ulong)resultant;
            }
            catch
            {
                result = 0;
            }
            return result;
        }

        public ulong downbase(int inputBase, int outputBase, double inputValue, int maxItterations = 28)
        {
            ulong result = 0;

            int iB;
            int oB;
            int iM;
            int i;

            double iV;

            iB = inputBase;
            oB = outputBase;
            iV = inputValue;
            iM = maxItterations;
            i = 0;

            double rem;
            double res;
            string resultant = string.Empty;
            string remString = string.Empty;

            res = iV;
            rem = 0;



            while (res != 0)
            {
                if (i > iM) { break; }
                rem = res % oB;
                rem = Math.Floor(rem);
                remString = rem.ToString();
                resultant = remString + resultant;

                res = res / oB;
                res = Math.Floor(res);

                i++;
            }

            // now convert
            double resDouble = 0;
            try
            {
                resDouble = double.Parse(resultant);
            }
            catch
            {
                Console.WriteLine("Empty string was passed!");
            }
            result = (ulong)resDouble;

            return result;
        }

        public ulong onesComp(ulong val, int enforceLength = 0)
        {
            ulong result = 0;
            string stringResult = string.Empty;
            char ichar;
            string inputStr = val.ToString();

            if(enforceLength != 0)
            {
                if(inputStr.Length < enforceLength)
                {
                    while(inputStr.Length < enforceLength)
                    {
                        inputStr = inputStr + "0";
                    }
                }
            }

            for (int i = 0; i < inputStr.Length; i++)
            {
                ichar = inputStr[i];
                if (ichar == '1')
                {
                    stringResult = stringResult + "0";
                }
                else if (ichar == '0')
                {
                    stringResult = stringResult + "1";
                }
            }
            try
            {

            }
            catch
            {

            }
            return result;
        }

        public double dualCompOctDouble(double oct1, double oct2)
        {
            double dec1;
            double dec2;

            ulong _dec1;
            ulong _dec2;
            ulong bin1;
            ulong bin2;

            _dec1 = tobase(8, 10, oct1, 28, false);
            _dec2 = tobase(8, 10, oct2, 28, false);

            bin1 = tobase(10, 2, (double)_dec1, 28, false);
            bin2 = tobase(10, 2, (double)_dec2, 28, false);

            dec1 = (double)tobase(2, 10, (double)bin1, 28, false);
            dec2 = (double)tobase(2, 10, (double)bin2, 28, false);

            double gThan = 037777;
            double gRemove = 077777;
            if (dec1 > gThan)
            {
                dec1 = -(gRemove - dec1);
            }
            if (dec2 > gThan)
            {
                dec2 = -(gRemove - dec2);
            }

            return dec1 * Math.Pow(2, -14) + dec2 * Math.Pow(2, -28);

        }

        public double remainder(double x, double m)
        {
            double r = x % m;
            return r < 0 ? r + m : r;
        }
    }
}
