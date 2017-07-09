import emojione from 'emojione';

const toImage = str => shortnameToImage(unicodeToImage(str));

const unicodeToImage = str => {
  const mappedUnicode = emojione.mapUnicodeToShort();

  return str.replace(emojione.regUnicode, unicodeChar => {
    if (typeof unicodeChar === 'undefined' || unicodeChar === '' || !(unicodeChar in emojione.jsEscapeMap)) {
      return unicodeChar;
    }

    const unicode  = emojione.jsEscapeMap[unicodeChar];
    const short    = mappedUnicode[unicode];
    const filename = emojione.emojioneList[short].fname;
    const alt      = emojione.convert(unicode.toUpperCase());

    return `<img draggable="false" class="emojione" alt="${alt}" title="${short}" src="/emoji/${filename}.svg" />`;
  });
};

const shortnameToImage = str => {
  // This walks through the string from end to start, ignoring any tags (<p>, <br>, etc.)
  // and replacing valid shortnames like :smile: and :wink: that _aren't_ within
  // tags with an <img> version.
  // The goal is to be the same as an emojione.regShortNames replacement, but faster.
  // The reason we go backwards is because then we can replace substrings as we go.
  let i = str.length;
  let insideTag = false;
  let insideShortname = false;
  let shortnameEndIndex = -1;
  while (i--) {
    const char = str.charAt(i);
    if (insideShortname && char === ':') {
      const shortname = str.substring(i, shortnameEndIndex + 1);
      if (shortname in emojione.emojioneList) {
        const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
        const alt = emojione.convert(unicode.toUpperCase());
        const replacement = `<img draggable="false" class="emojione" alt="${alt}" title="${shortname}" src="/emoji/${unicode}.svg" />`;
        str = str.substring(0, i) + replacement + str.substring(shortnameEndIndex + 1);
      } else {
        i++; // stray colon, try again
      }
      insideShortname = false;
    } else if (insideTag && char === '<') {
      insideTag = false;
    } else if (char === '>') {
      insideTag = true;
      insideShortname = false;
    } else if (!insideTag && char === ':') {
      insideShortname = true;
      shortnameEndIndex = i;
    }
  }
  return str;
};

export default function emojify(text) {
  return toImage(text);
};
