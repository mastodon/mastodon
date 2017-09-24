import { unicodeMapping } from './emojione_light';
import Trie from 'substring-trie';

const trie = new Trie(Object.keys(unicodeMapping));

const assetHost = process.env.CDN_HOST || '';

const parse = (str, customEmojis = {}) => {
  let tokens = [];
  for (;;) {
    let match, i = 0, tag;
    while (i < str.length && (tag = '<&'.indexOf(str[i])) === -1 && str[i] !== ':' && !(match = trie.search(str.slice(i)))) {
      i += str.codePointAt(i) < 65536 ? 1 : 2;
    }
    if (i === str.length)
      break;
    else if (tag >= 0) {
      const tagend = str.indexOf('>;'[tag], i + 1) + 1;
      if (!tagend)
        break;
      tokens.push({ type: 'html', value: str.slice(0, tagend) });
      str = str.slice(tagend);
    } else if (str[i] === ':') {
      try {
        // if replacing :shortname: succeed, exit this block with "continue"
        const closeColon = str.indexOf(':', i + 1) + 1;
        if (!closeColon) throw null; // no pair of ':'
        const lt = str.indexOf('<', i + 1);
        if (!(lt === -1 || lt >= closeColon)) throw null; // tag appeared before closing ':'
        const shortname = str.slice(i, closeColon);
        if (shortname in customEmojis) {
          tokens.push(
            { type: 'html', value: str.slice(0, i) },
            { type: 'customEmoji', alt: shortname, title: shortname, src: customEmojis[shortname] }
          );
          str = str.slice(closeColon);
          continue;
        }
      } catch (e) {}
      // replacing :shortname: failed
      tokens.push({ type: 'html', value: str.slice(0, i + 1) });
      str = str.slice(i + 1);
    } else {
      const [filename, shortCode] = unicodeMapping[match];
      tokens.push(
        { type: 'html', value: str.slice(0, i) },
        { type: 'emoji', alt: match, title: `:${shortCode}:`, src: `${assetHost}/emoji/${filename}.svg` }
      );
      str = str.slice(i + match.length);
    }
  }
  tokens.push({ type: 'html', value: str });
  return tokens;
};

export default parse;

export const toCodePoint = (unicodeSurrogates, sep = '-') => {
  let r = [], c = 0, p = 0, i = 0;

  while (i < unicodeSurrogates.length) {
    c = unicodeSurrogates.charCodeAt(i++);

    if (p) {
      r.push((0x10000 + ((p - 0xD800) << 10) + (c - 0xDC00)).toString(16));
      p = 0;
    } else if (0xD800 <= c && c <= 0xDBFF) {
      p = c;
    } else {
      r.push(c.toString(16));
    }
  }

  return r.join(sep);
};

export const buildCustomEmojis = customEmojis => {
  const emojis = [];

  customEmojis.forEach(emoji => {
    const shortcode = emoji.get('shortcode');
    const url       = emoji.get('url');
    const name      = shortcode.replace(':', '');

    emojis.push({
      name,
      short_names: [name],
      text: '',
      emoticons: [],
      keywords: [name],
      imageUrl: url,
    });
  });

  return emojis;
};
