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

const shortnameToImage = str => str.replace(emojione.regShortNames, shortname => {
  if (typeof shortname === 'undefined' || shortname === '' || !(shortname in emojione.emojioneList)) {
    return shortname;
  }

  const unicode = emojione.emojioneList[shortname].unicode[emojione.emojioneList[shortname].unicode.length - 1];
  const alt     = emojione.convert(unicode.toUpperCase());

  return `<img draggable="false" class="emojione" alt="${alt}" title="${shortname}" src="/emoji/${unicode}.svg" />`;
});

export default function emojify(text) {
  text = toImage(text);
  text = text.replace(/5,?000\s*兆円/g, (m) => {
    return `<img alt="${m}" src="/emoji/5000tyoen.svg" style="height: 1.8em;"/>`;
  });
  text = text.replace(/ニコる/g, (m) => {
    return `<img alt="${m}" src="/emoji/nicoru.svg" style="height: 1.5em;"/>`;
  });
  text = text.replace(/バジリスク\s*タイム/g, (m) => {
    return `<img alt="${m}" src="/emoji/basilisktime.png" height="40"/>`;
  });
    text = text.replace(/熱盛/g, (m) => {
    return `<img alt="${m}" src="/emoji/atumori.png" height="51"/>`;
  });
    text = text.replace(/欲しい！/g, (m) => {
    return `<img alt="${m}" src="/emoji/hosii.png" height="30"/>`;
  });
  return text;
}
