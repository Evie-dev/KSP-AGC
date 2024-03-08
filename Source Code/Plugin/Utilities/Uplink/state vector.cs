using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace AGCextras.Utilities.Uplink
{
    public class StateVector
    {
        private uplinkBase UB = new uplinkBase();
        private AGCfunctions func = new AGCfunctions();
        private const int INDEXVALUE = 21;
        private const int ECADR = 1501;

        private const int LUNAR_POSITION_MODIFIER = 27;
        private const int LUNAR_VELOCITY_MODIFIER = 5;

        private const int EARTH_POSITION_MODIFIER = 29;
        private const int EARTH_VELOCITY_MODIFIER = 7;

        private const int TIME_MODIFIER = 28;

        public List<double> getPositionComponents(double ivalue, bool moonCentered = false)
        {
            List<double> returnList = new List<double>();
            returnList.Add(getPositionComponent(ivalue, moonCentered, true));
            returnList.Add(getPositionComponent(ivalue, moonCentered, false));

            return returnList;
        }
        private double getPositionComponent(double iValue, bool moonCentered = false, bool signifigantComponent = false)
        {
            double returnPos = 0;

            double I = iValue;
            double J;
            int exponent;
            if(moonCentered)
            {
                exponent = -LUNAR_POSITION_MODIFIER;
            } else {  exponent = -EARTH_POSITION_MODIFIER; }

            J = I*Math.Pow(2, exponent);
            if(signifigantComponent) { returnPos = UB.gsc(I, J);  }
            else { returnPos = UB.gic(I, J); }

            return returnPos;
        }

        public double getPosition(double oct1, double oct2, bool moonCentered = false)
        {
            int exponent;
            if (moonCentered) { exponent = LUNAR_POSITION_MODIFIER; }
            else { exponent = EARTH_POSITION_MODIFIER;  }
            return UB.dc(oct1, oct2)*Math.Pow(2, exponent);
        }

        public List<double> getVelocityComponents(double ivalue, bool moonCentered = false)
        {
            List<double> returnList = new List<double>();
            returnList.Add(getVelocityComponent(ivalue, moonCentered, true));
            returnList.Add(getVelocityComponent(ivalue,moonCentered, false));
            return returnList;
        }

        private double getVelocityComponent(double ivalue, bool moonCentered = false, bool signifigantComponent = false)
        {
            double returnDouble = 0;
            double I = ivalue;
            double J;
            int exponent;
            if(moonCentered)
            {
                exponent = -LUNAR_VELOCITY_MODIFIER;
            } else { exponent = -EARTH_VELOCITY_MODIFIER; }

            J = (I/100)*Math.Pow(2,exponent);

            if(signifigantComponent) { returnDouble = UB.gsc(I,J); }
            else {  returnDouble = UB.gic(I,J);}

            return returnDouble;
        }

        public double getVelocity(double oct1, double oct2, bool moonCentered = false)
        {
            int exponent;
            if(moonCentered) { exponent = LUNAR_VELOCITY_MODIFIER; }
            else { exponent = EARTH_VELOCITY_MODIFIER; }
            double rDoub = UB.dc(oct1,oct2)*Math.Pow(2, exponent);
            return rDoub * 100;
        }

        public List<double> getTimeComponents(double ivalue)
        {
            List<double> returnList = new List<double>();
            returnList.Add(getTimeComponent(ivalue,true));
            returnList.Add(getTimeComponent(ivalue, false));
            return returnList;
        }

        private double getTimeComponent(double ivalue, bool signifigantComponent = false)
        {
            double returnDouble = 0;
            double I = ivalue;
            double J = (I * 100) * Math.Pow(2, -TIME_MODIFIER);
            if (signifigantComponent) { returnDouble = UB.gsc(I, J); }
            else { returnDouble = UB.gic(I,J); }
            return returnDouble;
        }

        public double getTime(double oct1, double oct2)
        {
            double rDoub = 0;
            rDoub = UB.dc(oct1, oct2)*Math.Pow(2,TIME_MODIFIER);
            rDoub = rDoub / 100;

            return rDoub;
        }

        public List<string> getUplinkList(List<double> positions, List<double> velocities,double timeValue, bool MoonCentered, bool forLM)
        {
            List<string> returnList = new List<string> ();

            List<double> xPos = getPositionComponents(positions[0], MoonCentered);
            List<double> yPos = getPositionComponents(positions[1], MoonCentered);
            List<double> zPos = getPositionComponents(positions[2], MoonCentered);

            List<double> xVel = getVelocityComponents(velocities[0], MoonCentered);
            List<double> yVel = getVelocityComponents(velocities[1], MoonCentered);
            List<double> zVel = getVelocityComponents(velocities[2], MoonCentered);

            List<double> timeVal = getTimeComponents(timeValue);

            List<string> intermediateList = new List<string>();


            double identifier;
            if (forLM)
            {
                identifier = 2;
            } else
            {
                identifier = 1;
            }

            if(MoonCentered) { identifier = -identifier; }

            identifier = func.baseConversion.tobase(10, 8, identifier, 14, identifier < 0);

            intermediateList.Add(INDEXVALUE.ToString());
            intermediateList.Add(ECADR.ToString());
            intermediateList.Add(identifier.ToString());

            // now we get onto the actual data

            for(int i = 0; i < xPos.Count; i++)
            {
                intermediateList.Add(xPos[i].ToString());
            }

            for (int i = 0; i < yPos.Count; i++)
            {
                intermediateList.Add(yPos[i].ToString());
            }

            for (int i = 0; i < zPos.Count; i++)
            {
                intermediateList.Add(zPos[i].ToString());
            }

            // vel

            for (int i = 0; i < xVel.Count; i++)
            {
                intermediateList.Add(xVel[i].ToString());
            }

            for (int i = 0; i < yVel.Count; i++)
            {
                intermediateList.Add(yVel[i].ToString());
            }

            for (int i = 0; i < zVel.Count; i++)
            {
                intermediateList.Add(zVel[i].ToString());
            }

            // time

            for (int i = 0; i < timeVal.Count; i++)
            {
                intermediateList.Add(timeVal[i].ToString());
            }

            for(int i = 0; i < intermediateList.Count; i++)
            {
                for(int j = 0; j < intermediateList[i].Length; j++)
                {
                    returnList.Add(UB.UPRUPT(intermediateList[i][j].ToString()));
                }
                returnList.Add(UB.UPRUPT("ENTER"));
            }

            returnList.Add(UB.UPRUPT("KEY RELEASE"));

            return returnList;
        }
    }
}
