import { unicodeMapping } from './emojione_light';
import Trie from 'substring-trie';

const trie = new Trie(Object.keys(unicodeMapping));

const assetHost = process.env.CDN_HOST || '';

const emojify = (str, customEmojis = {}) => {
  let rtn = '';
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
      rtn += str.slice(0, tagend);
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
          rtn += str.slice(0, i) + `<img draggable="false" class="emojione" alt="${shortname}" title="${shortname}" src="${customEmojis[shortname]}" />`;
          str = str.slice(closeColon);
          continue;
        }
      } catch (e) {}
      // replacing :shortname: failed
      rtn += str.slice(0, i + 1);
      str = str.slice(i + 1);
    } else {
      const [filename, shortCode] = unicodeMapping[match];
      rtn += str.slice(0, i) + `<img draggable="false" class="emojione" alt="${match}" title=":${shortCode}:" src="${assetHost}/emoji/${filename}.svg" />`;
      str = str.slice(i + match.length);
    }
  }
  return rtn + str;
};

const emojify_knzk = (str, customEmojis = {}) => [
  {re: /5,?000\s*兆円/g, file: '5000tyoen.svg', attrs: 'style="height: 1.8em;"'},
  {re: /ニコる/g, file: 'nicoru.svg', attrs: 'style="height: 1.5em;"'},
  {re: /バジリスク\s*タイム/g, file: 'basilisktime.png', attrs: 'height="40"'},
  {re: /熱盛/g, file: 'atumori.png', attrs: 'height="51"'},
  {re: /欲しい！/g, file: 'hosii.png', attrs: 'height="30"'},
].reduce((text, e) => text.replace(e.re, m => `<img alt="${m}" src="/emoji/${e.file}" ${e.attrs}/>`), emojify(str, customEmojis));

export default emojify_knzk;

export const buildCustomEmojis = customEmojis => {
  const emojis = [];

  customEmojis.forEach(emoji => {
    const shortcode = emoji.get('shortcode');
    const url       = emoji.get('url');
    const name      = shortcode.replace(':', '');

    emojis.push({
      id: name,
      name,
      short_names: [name],
      text: '',
      emoticons: [],
      keywords: [name],
      imageUrl: url,
      custom: true,
    });
  });

  return emojis;
};
