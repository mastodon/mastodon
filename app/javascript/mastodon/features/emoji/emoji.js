import { autoPlayGif } from '../../initial_state';
import unicodeMapping from './emoji_unicode_mapping_light';
import Trie from 'substring-trie';

const trie = new Trie(Object.keys(unicodeMapping));

const assetHost = process.env.CDN_HOST || '';

const emojify = (str, customEmojis = {}) => {
  const tagCharsWithoutEmojis = '<&';
  const tagCharsWithEmojis = Object.keys(customEmojis).length ? '<&:' : '<&';
  let rtn = '', i, shortCodeStart, tagChars = tagCharsWithEmojis, invisible = 0;

  if (str[0] === ':') {
    i = 1;
    shortCodeStart = 0;
  } else {
    i = 0;
    shortCodeStart = null;
  }

  // This loop initializes the internal state.
  for (;;) {
    const allowedAroundShortCode = '><\u0085\u0020\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u202f\u205f\u3000\u2028\u2029\u0009\u000a\u000b\u000c\u000d';

    // This loop looks for:
    // 1. the end of the string and
    // 2. an emoji to be replaced with a HTML representation.
    // In case of 1, it will return the result and ends this function.
    // In case of 2, the processed string will be concatenated to rtn. i will be
    // the index of the beginning of the remainder.
    for (;;) {
      // The string ended. Return the processed string and the remainder.
      if (i >= str.length) {
        return rtn + str;
      }

      const tag = tagChars.indexOf(str[i]);
      if (tag === 2) {
        const shortCodeEnd = i + 1;

        if (shortCodeStart !== null &&
            (allowedAroundShortCode.includes(str[shortCodeEnd]) || shortCodeEnd >= str.length)) {
          // Shortcode ended without any intrusive strings.

          // Get replacee as ':shortCode:'
          const shortCode = str.slice(shortCodeStart, shortCodeEnd);

          if (shortCode in customEmojis) {
            const filename = autoPlayGif ? customEmojis[shortCode].url : customEmojis[shortCode].static_url;
            rtn += str.slice(0, shortCodeStart) + `<img draggable="false" class="emojione" alt="${shortCode}" title="${shortCode}" src="${filename}" />`;
            i++;
            break;
          }
        }

        if (allowedAroundShortCode.includes(str[i - 1])) {
          // Short code started.

          // Note that it is just a "candidate"; there may not be an ending
          // colon and the end of the string, an HTML tag, or a Unicode emoji
          // may appear. Therefore here just mark the start and continue the
          // loop.
          shortCodeStart = i;
        }
      } else if (tag >= 0) {
        // An HTML tag started. Look for its end and advance i after that if
        // found.
        const rend = str.indexOf('>;'[tag], i + 1) + 1;
        if (rend) {
          if (!invisible) {
            if (str.startsWith('<span class="invisible">', i)) {
              invisible = 1;
              tagChars = tagCharsWithoutEmojis;
            }
          } else if (str[i + 1] === '/') {
            if (!--invisible) {
              tagChars = tagCharsWithEmojis;
            }
          } else if (str[rend - 2] !== '/') {
            invisible++;
          }

          i = rend;
          continue;
        }
      } else if (invisible <= 0) {
        const match = trie.search(str.slice(i));
        if (match) {
          // An Unicode emoji was matched to.

          const { filename, shortCode } = unicodeMapping[match];
          const title = shortCode ? `:${shortCode}:` : '';
          rtn += str.slice(0, i) + `<img draggable="false" class="emojione" alt="${match}" title="${title}" src="${assetHost}/emoji/${filename}.svg" />`;
          i += match.length;
          break;
        }
      }

      i++;
    }

    // Slice the remainder.
    str = str.slice(i);

    i = 0;
    shortCodeStart = null;
  }
};

export default emojify;

export const buildCustomEmojis = (customEmojis) => {
  const emojis = [];

  customEmojis.forEach(emoji => {
    const shortcode = emoji.get('shortcode');
    const url       = autoPlayGif ? emoji.get('url') : emoji.get('static_url');
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
