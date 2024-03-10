// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


using AGCextras.Utilities.Uplink;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace AGCextras
{
    public class uplink
    {
        public externalDeltaV EDV = new externalDeltaV();
        public StateVector SV = new StateVector();
        public retrofire retrofire = new retrofire();
    }

    public class uplinkBase
    {
        private AGCfunctions func = new AGCfunctions();
        private DSKYkeyboard keycodes = new DSKYkeyboard();
        
        public double gsc(double iValue, double jValue)
        {
            double Jval;
            double returnValue = 0;

            classIJKL IJKL = new classIJKL().getIJKL(iValue, jValue);

            returnValue = (double)func.baseConversion.tobase(10, 8, IJKL.L * Math.Pow(2, 14), 28, iValue < 0);

            return returnValue;
        }
        public double gic(double iValue,double jValue)
        {
            double returnValue = 0;

            classIJKL IJKL = new classIJKL().getIJKL(iValue, jValue);

            returnValue = (double)func.baseConversion.tobase(10, 8, IJKL.K * Math.Pow(2, 28), 28, iValue < 0);

            return returnValue;
        }

        public List<double> gbc(double iValue, double jValue)
        {
            List<double> returnComponents = new List<double>();

            double signifigantValue = gsc(iValue,jValue);
            double insignifigantValue = gic(iValue, jValue);

            returnComponents.Add(signifigantValue);
            returnComponents.Add(insignifigantValue);

            return returnComponents;
        }

        public double dc(double valueA, double valueB)
        {
            // returns the equivilent to the J value!
            double returnValue = func.baseConversion.dualCompOctDouble(valueA, valueB);

            return returnValue;
        }

        public string UPRUPT(string input)
        {
            return keycodes.getUpruptWord(input);
        }
    }

    public class classIJKL
    {

        private class_baseConversion BC =new class_baseConversion();
        public double I;
        public double J;
        public double K;
        public double L;

        public classIJKL getIJKL(double valueof_I, double valueof_J)
        {
            classIJKL returnIJKL = new classIJKL();

            returnIJKL.I = valueof_I;
            returnIJKL.J = valueof_J;
            if (returnIJKL.J < 0)
            {
                returnIJKL.K = -BC.remainder(returnIJKL.J, Math.Pow(2, -14));
            } else
            {
                returnIJKL.K = BC.remainder(returnIJKL.J,Math.Pow(2, -14));
            }
            returnIJKL.L = returnIJKL.J - returnIJKL.K;
            return returnIJKL;
        }
    }
}
