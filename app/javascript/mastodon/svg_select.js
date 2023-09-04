export function svgSelect(light, dark) {

  var svgbg = window.getComputedStyle(document.getElementsByClassName("drawer__inner")[0], null).getPropertyValue("background-color");
  var rgbArray = ((svgbg.replace(/[^0-9,]/g, "")).split(",")).map(Number).map(x => x/255);

  for ( var i = 0; i < rgbArray.length; ++i ) {
  			if ( rgbArray[i] <= 0.03928 ) {
  				rgbArray[i] = rgbArray[i] / 12.92
	      } else {
  				rgbArray[i] = Math.pow( ( rgbArray[i] + 0.055 ) / 1.055, 2.4);
  			}
  		}

  var luminance = 0.2126 * rgbArray[0] + 0.7152 * rgbArray[1] + 0.0722 * rgbArray[2];

  		if ( luminance <= 0.179 ) {
  			return light;
  		} else {
  		  return dark;
  		}
}
