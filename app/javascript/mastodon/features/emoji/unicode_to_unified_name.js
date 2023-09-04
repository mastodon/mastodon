/* eslint-disable import/no-commonjs --
   We need to use CommonJS here as its imported into a preval file (`emoji_compressed.js`) */

function padLeft(str, num) {
  while (str.length < num) {
    str = '0' + str;
  }

  return str;
}

exports.unicodeToUnifiedName = (str) => {
  let output = '';

  for (let i = 0; i < str.length; i += 2) {
    if (i > 0) {
      output += '-';
    }

    output += padLeft(str.codePointAt(i).toString(16).toUpperCase(), 4);
  }

  return output;
};
