package utils {
	
	/* found this on-line.  hoping this can be useful in drawing curved lines between points.
	
    /**
     * http://www.movable-type.co.uk/scripts/latlong-vincenty.html
     */
    public class GeodesicCalc {
		
        private static const PI_OVER_180 : Number = Math.PI / 180.0;
        
        /**
         * Calculate geodesic distance (in m) between two points specified by latitude/longitude (in numeric degrees)
         * using Vincenty inverse formula for ellipsoids
         */
        public static function distVincenty(
            lat1 : Number,
            lon1 : Number,
            lat2 : Number,
            lon2 : Number
          ) : Number {
			
          var a : Number = 6378137, b : Number = 6356752.3142,  f : Number = 1/298.257223563;  // WGS-84 ellipsiod
          var L : Number = (lon2-lon1) * PI_OVER_180;
          var U1 : Number = Math.atan((1-f) * Math.tan(lat1 * PI_OVER_180));
          var U2 : Number = Math.atan((1-f) * Math.tan(lat2 * PI_OVER_180));
          var sinU1 : Number = Math.sin(U1), cosU1 : Number = Math.cos(U1);
          var sinU2 : Number = Math.sin(U2), cosU2 : Number = Math.cos(U2);
          
          var lambda : Number = L, lambdaP : Number = 2*Math.PI;
          var iterLimit : int = 20;
		  
          while (Math.abs(lambda-lambdaP) > 1e-12 && --iterLimit>0) {
			  
            var sinLambda : Number = Math.sin(lambda), cosLambda : Number = Math.cos(lambda);
            var sinSigma : Number = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + 
              (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
			
            if (sinSigma==0) return 0;  // co-incident points
			
            var cosSigma : Number = sinU1*sinU2 + cosU1*cosU2*cosLambda;
            var sigma : Number = Math.atan2(sinSigma, cosSigma);
            var sinAlpha : Number = cosU1 * cosU2 * sinLambda / sinSigma;
            var cosSqAlpha : Number = 1 - sinAlpha*sinAlpha;
            var cos2SigmaM : Number = cosSigma - 2*sinU1*sinU2/cosSqAlpha;
			
            if (isNaN(cos2SigmaM)) cos2SigmaM = 0;  // equatorial line: cosSqAlpha=0 (¤6)
			
            var C : Number = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
            lambdaP = lambda;
            lambda = L + (1-C) * f * sinAlpha *
              (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
          }
		  
          if (iterLimit==0) return NaN  // formula failed to converge
        
          var uSq : Number = cosSqAlpha * (a*a - b*b) / (b*b);
          var A : Number = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
          var B : Number = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
          var deltaSigma : Number = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-
            B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
          var s : Number = b*A*(sigma-deltaSigma);
          return s;
        }
    
        public static const NUME : RegExp = /^-?\d{1,3}\.\d*$/;
        public static const DMS : RegExp = /^(\d{1,3})\s(\d{1,2})\s(\d{1,2}\.?\d*)\s?([NSEW])$/;
        
        public static function parseDeg( value : String) : Number
        {
            var arr1 : Array = NUME.exec( value);
            if( arr1 != null )
            {
                return Number(arr1[0]);
            }
            var arr2 : Array = DMS.exec( value);
            if( arr2 != null && arr2.length == 5)
            {
                var deg : Number = arr2[1]/1.0 + arr2[2]/60.0 + arr2[3]/3600;                
                return (arr2[4] == "W" || arr2[4] == "S") ? -deg : deg;
            }
            return NaN;
        }    
    }
}