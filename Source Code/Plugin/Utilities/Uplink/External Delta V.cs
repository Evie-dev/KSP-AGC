// Copyright (c) 2024 The Developers of KSP-AGC (Evie-dev)
// License: MIT


using KSPAchievements;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace AGCextras.Utilities.Uplink
{
    public class externalDeltaV
    {

        private uplinkBase UB = new uplinkBase();

        private const int TIG_modifier = -28;
        private const int VEL_modifier = -7;

        // the inverse...
        private const int TIG_unmodifier = 28;
        private const int VEL_unmodifier = 7;

        private const int INDEXVALUE = 12;
        private const int ECADR = 3404;
        
        
        // we can get a component of a velocity in three ways, singular or both, due to different return types they are separated into two methods

        public List<double> getVelocityComponents(double iValue)
        {
            List<double> returnComponents = new List<double>();

            returnComponents.Add(getVelocityComponent(iValue, true));
            returnComponents.Add(getVelocityComponent(iValue, false));

            return returnComponents;
        }
        private double getVelocityComponent(double iValue, bool signifigantComponent = false)
        {
            double returnValue = 0;

            // get an IJKL

            double I = iValue;
            double J = (iValue / 100) * Math.Pow(2, VEL_modifier);

            if (signifigantComponent)
            {
                returnValue = UB.gsc(I, J);
            }
            else
            {
                returnValue = UB.gic(I, J);
            }
            

            return returnValue;
        }

        public double getSignifigantVelocity(double iValue)
        {
            return getVelocityComponent(iValue, true);
        }
        public double getInsignifigantVelocity(double iValue)
        {
            return getVelocityComponent(iValue, false);
        }

        public double getVelocity(double oct1, double oct2)
        {
            double returnValue = UB.dc(oct1, oct2);

            returnValue = returnValue * Math.Pow(2, VEL_unmodifier);
            returnValue = returnValue * 100;
            return returnValue;
        }

        // TIG

        public List<double> getTIGcomponents(double iValue)
        {
            List<double> returnComponents = new List<double>();
            returnComponents.Add(getTIGcomponent(iValue, true));
            returnComponents.Add(getTIGcomponent(iValue, false));
            return returnComponents;
        }

        private double getTIGcomponent(double iValue, bool signifigantComponent = false)
        {
            double returnValue = 0;

            double I = iValue;
            double J = (iValue * 100) * Math.Pow(2, TIG_modifier);
            if (signifigantComponent)
            {
                returnValue = UB.gsc(I, J);
            } else
            {
                returnValue = UB.gic(I, J);
            }


            return returnValue;
        }

        public double getSignifigantTIG(double iValue)
        {
            return getTIGcomponent(iValue, true);
        }

        public double getInsignifigantTIG(double iValue)
        {
            return getTIGcomponent(iValue, false);
        }

        public double getTIG(double oct1, double oct2)
        {
            double returnValue = UB.dc(oct1, oct2);
            returnValue = returnValue * Math.Pow(2, TIG_unmodifier);
            returnValue = returnValue * 100;
            return returnValue;
        }

        // now we can use this to construct a structure to create a uplink structure

        // Intended usage
        // Velocity - inputed as a vector
        // x - prograde
        // y - normal
        // z - radial
        // just like the AGC itself
        public List<string> getUplinkList(List<double> velocityComponents, double TIG)
        {
            
            List<string> returnList = new List<string>();
            List<string> rawInputsList = new List<string>(); // for use with raw inputs - do not add enter to this!
            List<double> xVel = getVelocityComponents(velocityComponents[0]);
            List<double> yVel = getVelocityComponents(velocityComponents[1]);
            List<double> zVel = getVelocityComponents(velocityComponents[2]);

            List<double> TIGcomp = getTIGcomponents(TIG);

            rawInputsList.Add(INDEXVALUE.ToString());
            rawInputsList.Add(ECADR.ToString());

            for(int i = 0; i < xVel.Count; i++)
            {
                rawInputsList.Add(xVel[i].ToString());
            }

            for (int i = 0; i < yVel.Count; i++)
            {
                rawInputsList.Add(yVel[i].ToString());
            }

            for (int i = 0; i < zVel.Count; i++)
            {
                rawInputsList.Add(zVel[i].ToString());
            }

            for (int i = 0; i < TIGcomp.Count; i++)
            {
                rawInputsList.Add(TIGcomp[i].ToString());
            }

            for (int i = 0; i < rawInputsList.Count; i++)
            {
                for (int j = 0; j < rawInputsList[i].Length; j++)
                {
                    returnList.Add(UB.UPRUPT(rawInputsList[i][j].ToString()));
                }
                returnList.Add(UB.UPRUPT("ENTER"));
            }

            // add KEY RELEASE

            returnList.Add(UB.UPRUPT("KEY RELEASE"));
            return returnList;
        }
    }
}
