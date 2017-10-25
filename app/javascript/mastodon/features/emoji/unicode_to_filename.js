// taken from:
// https://github.com/twitter/twemoji/blob/47732c7/twemoji-generator.js#L848-L866
exports.unicodeToFilename = (str) => {
  let result = '';
  let charCode = 0;
  let p = 0;
  let i = 0;
  while (i < str.length) {
    charCode = str.charCodeAt(i++);
    if (p) {
      if (result.length > 0) {
        result += '-';
      }
      result += (0x10000 + ((p - 0xD800) << 10) + (charCode - 0xDC00)).toString(16);
      p = 0;
    } else if (0xD800 <= charCode && charCode <= 0xDBFF) {
      p = charCode;
    } else {
      if (result.length > 0) {
        result += '-';
      }
      result += charCode.toString(16);
    }
  }
  return result;
};
