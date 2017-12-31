// adapted from https://github.com/exif-js/exif-js/blob/a0f8a5147500dbd29a9a6db81451526f34226584/exif.js
export default function getPanoramaData (imageSource) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.addEventListener('load', () => {
      if (xhr.status === 200) {
        resolve(readXMP(xhr.response));
      } else {
        reject();
      }
    });

    xhr.responseType = 'arraybuffer';
    xhr.open('GET', imageSource);
    xhr.send();
  });
}

function stringFromDataView (buffer, start, length) {
  let string = '';

  for (let offset = start; offset < start + length; offset++) {
    string += String.fromCharCode(buffer.getUint8(offset));
  }

  return string;
}

function readXMP (buffer) {
  const dataView = new DataView(buffer);

  if ((dataView.getUint8(0) !== 0xFF) || (dataView.getUint8(1) !== 0xD8)) {
    // invalid jpeg
    return null;
  }

  const length = buffer.byteLength;
  let offset = 2;

  const h = 'h'.charCodeAt(0);

  while (offset < length - 4) {
    if (dataView.getUint8(offset) === h && stringFromDataView(dataView, offset, 4) === 'http') {
      const startOffset = offset - 1;
      const sectionLength = dataView.getUint16(offset - 2) - 1;
      let xmpString = stringFromDataView(dataView, startOffset, sectionLength);
      const xmpEndIndex = xmpString.indexOf('xmpmeta>') + 8;
      xmpString = xmpString.substring(xmpString.indexOf('<x:xmpmeta'), xmpEndIndex);

      const xmpIndex = xmpString.indexOf('x:xmpmeta') + 10;

      //Many custom written programs embed xmp/xml without any namespace. Following are some of them.
      //Without these namespaces, XML is thought to be invalid by parsers
      xmpString = xmpString.slice(0, xmpIndex)
        + 'xmlns:Iptc4xmpCore="http://iptc.org/std/Iptc4xmpCore/1.0/xmlns/" '
        + 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        + 'xmlns:tiff="http://ns.adobe.com/tiff/1.0/" '
        + 'xmlns:plus="http://schemas.android.com/apk/lib/com.google.android.gms.plus" '
        + 'xmlns:ext="http://www.gettyimages.com/xsltExtension/1.0" '
        + 'xmlns:exif="http://ns.adobe.com/exif/1.0/" '
        + 'xmlns:stEvt="http://ns.adobe.com/xap/1.0/sType/ResourceEvent#" '
        + 'xmlns:stRef="http://ns.adobe.com/xap/1.0/sType/ResourceRef#" '
        + 'xmlns:crs="http://ns.adobe.com/camera-raw-settings/1.0/" '
        + 'xmlns:xapGImg="http://ns.adobe.com/xap/1.0/g/img/" '
        + 'xmlns:Iptc4xmpExt="http://iptc.org/std/Iptc4xmpExt/2008-02-29/" '
        + xmpString.slice(xmpIndex);

      const dom = new DOMParser().parseFromString(xmpString, 'text/xml');

      const description = dom.querySelector('Description');

      const usePano = description.getAttribute('GPano:UsePanoramaViewer') !== 'False';

      const projection = description.getAttribute('GPano:ProjectionType');
      if (projection && projection !== 'equirectangular') return null;

      let initialFOV = description.getAttribute('GPano:InitialHorizontalFOVDegrees');
      if (initialFOV !== null) {
        initialFOV = +initialFOV / 180 * Math.PI;
      }

      const data = {
        fullWidth: +description.getAttribute('GPano:FullPanoWidthPixels'),
        fullHeight: +description.getAttribute('GPano:FullPanoHeightPixels'),
        croppedWidth: +description.getAttribute('GPano:CroppedAreaImageWidthPixels'),
        croppedHeight: +description.getAttribute('GPano:CroppedAreaImageHeightPixels'),
        croppedLeft: +description.getAttribute('GPano:CroppedAreaLeftPixels'),
        croppedTop: +description.getAttribute('GPano:CroppedAreaTopPixels'),
        enabledInitially: usePano,
        initialFOV: initialFOV,
      };

      for (let key in data) if (Number.isNaN(data[key])) return null;

      return data;
    } else {
      offset++;
    }
  }

  return null;
}
