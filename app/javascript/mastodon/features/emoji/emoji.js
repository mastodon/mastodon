import { autoPlayGif } from '../../initial_state';
import unicodeMapping from './emoji_unicode_mapping_light';
import Trie from 'substring-trie';

const trie = new Trie(Object.keys(unicodeMapping));

const assetHost = process.env.CDN_HOST || '';

const emojify = (str, customEmojis = {}) => {
  const tagCharsWithoutEmojis = '<&';
  const tagCharsWithEmojis = Object.keys(customEmojis).length ? '<&:' : '<&';
  let rtn = '', tagChars = tagCharsWithEmojis;

  // This loop initializes the internal state.
  for (;;) {
    let i = 0, shortCodeStart = null, invisible = 0;

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
      if (tag < 0) {
        if (invisible <= 0) {
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
      } else if (tag < 2) {
        // An HTML tag started. Look for its end and advance i after that if
        // found.
        const rend = str.indexOf('>;'[tag], i + 1) + 1;
        if (rend) {
          if (invisible) {
            if (str[i + 1] === '/') {
              if (!--invisible) {
                tagChars = tagCharsWithEmojis;
              }
            } else if (str[rend - 2] !== '/') {
              invisible++;
            }
          } else if (str.startsWith('<span class="invisible">', i)) {
            invisible = 1;
            tagChars = tagCharsWithoutEmojis;
          }

          i = rend;
          continue;
        }
      } else if (shortCodeStart === null) {
        // Short code started.

        // Note that it is just a "candidate"; there may not be an ending
        // colon and the end of the string, an HTML tag, or a Unicode emoji
        // may appear. Therefore here just mark the start and continue the
        // loop.
        shortCodeStart = i;
      } else {
        // Shortcode ended without any intrusive strings.

        // Get replacee as ':shortCode:'
        const shortCode = str.slice(shortCodeStart, i + 1);

        if (shortCode in customEmojis) {
          const filename = autoPlayGif ? customEmojis[shortCode].url : customEmojis[shortCode].static_url;
          rtn += str.slice(0, shortCodeStart) + `<img draggable="false" class="emojione" alt="${shortCode}" title="${shortCode}" src="${filename}" />`;
          i++;
          break;
        }
      }

      i++;
    }

    // Slice the remainder.
    str = str.slice(i);
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
