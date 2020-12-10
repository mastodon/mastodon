import 'intl';
import 'intl/locale-data/jsonp/en';
import 'es6-symbol/implement';
import includes from 'array-includes';
import assign from 'object-assign';
import values from 'object.values';
import { decode as decodeBase64 } from './utils/base64';
import promiseFinally from 'promise.prototype.finally';

if (!Array.prototype.includes) {
  includes.shim();
}

if (!Object.assign) {
  Object.assign = assign;
}

if (!Object.values) {
  values.shim();
}

promiseFinally.shim();

if (!HTMLCanvasElement.prototype.toBlob) {
  const BASE64_MARKER = ';base64,';

  Object.defineProperty(HTMLCanvasElement.prototype, 'toBlob', {
    value(callback, type = 'image/png', quality) {
      const dataURL = this.toDataURL(type, quality);
      let data;

      if (dataURL.indexOf(BASE64_MARKER) >= 0) {
        const [, base64] = dataURL.split(BASE64_MARKER);
        data = decodeBase64(base64);
      } else {
        [, data] = dataURL.split(',');
      }

      callback(new Blob([data], { type }));
    },
  });
}
