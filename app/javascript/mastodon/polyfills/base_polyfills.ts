import 'core-js/features/object/assign';
import 'core-js/features/object/values';
import 'core-js/features/symbol';
import 'core-js/features/promise/finally';
import { decode as decodeBase64 } from '../utils/base64';

if (!HTMLCanvasElement.prototype.toBlob) {
  const BASE64_MARKER = ';base64,';

  Object.defineProperty(HTMLCanvasElement.prototype, 'toBlob', {
    value: function (
      this: HTMLCanvasElement,
      callback: BlobCallback,
      type = 'image/png',
      quality: unknown
    ) {
      const dataURL: string = this.toDataURL(type, quality);
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
