import emojione from 'emojione';

const toImage = str => shortnameToImage(unicodeToImage(str));

const blacklistedHex = {"00ae": true, "00a9": true, "2122": true};

const unicodeToImage = str => {
  const mappedUnicode = emojione.mapUnicodeToShort();

  return str.replace(emojione.regUnicode, unicodeChar => {
    if (typeof unicodeChar === 'undefined' || unicodeChar === '' || !(unicodeChar in emojione.jsEscapeMap)) {
      return unicodeChar;
    }

    const unicode  = emojione.jsEscapeMap[unicodeChar];
    const short    = mappedUnicode[unicode];
    const filename = emojione.emojioneList[short].fname;
    // Blacklisted - these have better font support than images
    if (blacklistedHex[filename])
      return unicodeChar;
    }
    const alt      = emojione.convert(unicode.toUpperCase());

    return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${filename}.svg" />`;
  });
};

const shortnameToImage = str => str.replace(emojione.regShortNames, shortname => {
  if (typeof shortname === 'undefined' || shortname === '' || !(shortname in emojione.emojioneList)) {
    return shortname;
  }

  const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
  const alt     = emojione.convert(unicode.toUpperCase());
  if (blacklistedHex[unicode]) {
    return alt;
  }

  return `<img draggable="false" class="emojione" alt="${alt}" src="/emoji/${unicode}.svg" />`;
});

export default function emojify(text) {
  return toImage(text);
};
