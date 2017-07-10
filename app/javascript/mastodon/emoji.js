import emojione from 'emojione';
import Trie from 'substring-trie';

const mappedUnicode = emojione.mapUnicodeToShort();
const trie = new Trie(Object.keys(emojione.jsEscapeMap));

function emojify(str) {
  // This walks through the string from start to end, ignoring any tags (<p>, <br>, etc.)
  // and replacing valid shortnames like :smile: and :wink: as well as unicode strings
  // that _aren't_ within tags with an <img> version.
  // The goal is to be the same as an emojione.regShortNames/regUnicode replacement, but faster.
  let i = -1;
  let insideTag = false;
  let insideShortname = false;
  let shortnameStartIndex = -1;
  let match;
  while (++i < str.length) {
    const char = str.charAt(i);
    if (insideShortname && char === ':') {
      const shortname = str.substring(shortnameStartIndex, i + 1);
      if (shortname in emojione.emojioneList) {
        const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
        const alt = emojione.convert(unicode.toUpperCase());
        const replacement = `<img draggable="false" class="emojione" alt="${alt}" title="${shortname}" src="/emoji/${unicode}.svg" />`;
        str = str.substring(0, shortnameStartIndex) + replacement + str.substring(i + 1);
        i += (replacement.length - shortname.length - 1); // jump ahead the length we've added to the string
      } else {
        i--; // stray colon, try again
      }
      insideShortname = false;
    } else if (insideTag && char === '>') {
      insideTag = false;
    } else if (char === '<') {
      insideTag = true;
      insideShortname = false;
    } else if (!insideTag && char === ':') {
      insideShortname = true;
      shortnameStartIndex = i;
    } else if (!insideTag && (match = trie.search(str.substring(i)))) {
      const unicodeStr = match;
      if (unicodeStr in emojione.jsEscapeMap) {
        const unicode  = emojione.jsEscapeMap[unicodeStr];
        const short    = mappedUnicode[unicode];
        const filename = emojione.emojioneList[short].fname;
        const alt      = emojione.convert(unicode.toUpperCase());
        const replacement =  `<img draggable="false" class="emojione" alt="${alt}" title="${short}" src="/emoji/${filename}.svg" />`;
        str = str.substring(0, i) + replacement + str.substring(i + unicodeStr.length);
        i += (replacement.length - unicodeStr.length); // jump ahead the length we've added to the string
      }
    }
  }
  return str;
}

export default emojify;
