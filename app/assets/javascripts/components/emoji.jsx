import emojione from 'emojione';
import detectVersion from 'mojibaka';

emojione.imageType    = 'png';
emojione.sprites      = false;
emojione.imagePathPNG = '/emoji/';

let emoji_version = detectVersion();

export default function emojify(text) {
  // Browser too old to support native emoji
  if (emoji_version < 9.0) {
    return emojione.toImage(text);
  // Convert short codes into native emoji
  } else {
    return emojione.shortnameToUnicode(text);
  }
};
