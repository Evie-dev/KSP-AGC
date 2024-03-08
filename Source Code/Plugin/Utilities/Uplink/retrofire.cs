using JetBrains.Annotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AGCextras.Utilities.Uplink
{
    // also serves as ENTRY
    public class retrofire : uplinkBase
    {
        private uplinkBase UB = new uplinkBase();
        private externalDeltaV extDV = new externalDeltaV();
        private Entry ENTR = new Entry();


    }

    public class Entry
    {
        // cmc entry update
        private uplinkBase UB = new uplinkBase();


        public List<double> getGeopositionComponents(double iValue)
        {
            List<double> returnList = new List<double>();


            return returnList;
        }

        private double getGeopositionComponent(double iValue, bool signifigantComponent = false)
        {
            double returnDouble = 0;
            double I = iValue;
            double J = iValue / 360;

            if (signifigantComponent) { returnDouble = UB.gsc(I, J); }
            else { returnDouble = UB.gic(I, J); }

            return returnDouble;
        }
    }
}
