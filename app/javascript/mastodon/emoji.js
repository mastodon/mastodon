import { unicodeMapping } from './emojione_light';
import Trie from 'substring-trie';

const trie = new Trie(Object.keys(unicodeMapping));

const emojify = (str, customEmojis = {}) => {
  let rtn = '';
  for (;;) {
    let match, i = 0, tag;
    while (i < str.length && (tag = '<&:'.indexOf(str[i])) === -1 && !(match = trie.search(str.slice(i)))) {
      i += str.codePointAt(i) < 65536 ? 1 : 2;
    }
    if (i === str.length)
      break;
    else if (tag >= 0) {
      let tagend = str.indexOf('>;:'[tag], i + 1) + 1;
      if (!tagend)
        break;
      if (str[i] === ':') {
        const shortname = str.slice(i, tagend);
        const lt = str.indexOf('<', i + 1);
        if ((lt === -1 || lt >= tagend) && shortname in customEmojis) {
          rtn += str.slice(0, i) + `<img draggable="false" class="emojione" alt="${shortname}" title="${shortname}" src="${customEmojis[shortname]}" />`;
          str = str.slice(tagend);
        } else {
          rtn += str.slice(0, i + 1);
          str = str.slice(i + 1);
        }
      } else {
        rtn += str.slice(0, tagend);
        str = str.slice(tagend);
      }
    } else {
      const [filename, shortCode] = unicodeMapping[match];
      rtn += str.slice(0, i) + `<img draggable="false" class="emojione" alt="${match}" title=":${shortCode}:" src="/emoji/${filename}.svg" />`;
      str = str.slice(i + match.length);
    }
  }
  return rtn + str;
};

export default emojify;
