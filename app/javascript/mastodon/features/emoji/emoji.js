import Trie from 'substring-trie';

import { getIsSystemTheme, isDarkMode } from '@/mastodon/utils/theme';
import { assetHost } from 'mastodon/utils/config';

import { autoPlayGif } from '../../initial_state';

import { unicodeMapping } from './emoji_unicode_mapping_light';

const trie = new Trie(Object.keys(unicodeMapping));

// Convert to file names from emojis. (For different variation selector emojis)
const emojiFilenames = (emojis) => {
  return emojis.map(v => unicodeMapping[v].filename);
};

// Emoji requiring extra borders depending on theme
const darkEmoji = emojiFilenames(['🎱', '🐜', '⚫', '🖤', '⬛', '◼️', '◾', '◼️', '✒️', '▪️', '💣', '🎳', '📷', '📸', '♣️', '🕶️', '✴️', '🔌', '💂‍♀️', '📽️', '🍳', '🦍', '💂', '🔪', '🕳️', '🕹️', '🕋', '🖊️', '🖋️', '💂‍♂️', '🎤', '🎓', '🎥', '🎼', '♠️', '🎩', '🦃', '📼', '📹', '🎮', '🐃', '🏴', '🐞', '🕺', '📱', '📲', '🚲', '🪮', '🐦‍⬛']);
const lightEmoji = emojiFilenames(['👽', '⚾', '🐔', '☁️', '💨', '🕊️', '👀', '🍥', '👻', '🐐', '❕', '❔', '⛸️', '🌩️', '🔊', '🔇', '📃', '🌧️', '🐏', '🍚', '🍙', '🐓', '🐑', '💀', '☠️', '🌨️', '🔉', '🔈', '💬', '💭', '🏐', '🏳️', '⚪', '⬜', '◽', '◻️', '▫️', '🪽', '🪿']);

/**
 * @param {string} filename
 * @param {"light" | "dark" } colorScheme
 * @returns {string}
 */
const emojiFilename = (filename, colorScheme) => {
  const borderedEmoji = colorScheme === "light" ? lightEmoji : darkEmoji;
  return borderedEmoji.includes(filename) ? (filename + '_border') : filename;
};

const emojifyTextNode = (node, customEmojis) => {
  const VS15 = 0xFE0E;
  const VS16 = 0xFE0F;

  let str = node.textContent;

  const fragment = new DocumentFragment();
  let i = 0;

  for (;;) {
    let unicode_emoji;

    // Skip to the next potential emoji to replace (either custom emoji or custom emoji :shortcode:
    if (customEmojis === null) {
      while (i < str.length && !(unicode_emoji = trie.search(str.slice(i)))) {
        i += str.codePointAt(i) < 65536 ? 1 : 2;
      }
    } else {
      while (i < str.length && str[i] !== ':' && !(unicode_emoji = trie.search(str.slice(i)))) {
        i += str.codePointAt(i) < 65536 ? 1 : 2;
      }
    }

    // We reached the end of the string, nothing to replace
    if (i === str.length) {
      break;
    }

    let rend, replacement = null;
    if (str[i] === ':') { // Potentially the start of a custom emoji :shortcode:
      rend = str.indexOf(':', i + 1) + 1;

      // no matching ending ':', skip
      if (!rend) {
        i++;
        continue;
      }

      const shortcode = str.slice(i, rend);
      const custom_emoji = customEmojis[shortcode];

      // not a recognized shortcode, skip
      if (!custom_emoji) {
        i++;
        continue;
      }

      // now got a replacee as ':shortcode:'
      // if you want additional emoji handler, add statements below which set replacement and return true.
      const filename = autoPlayGif ? custom_emoji.url : custom_emoji.static_url;
      replacement = document.createElement('img');
      replacement.setAttribute('draggable', 'false');
      replacement.setAttribute('class', 'emojione custom-emoji');
      replacement.setAttribute('alt', shortcode);
      replacement.setAttribute('title', shortcode);
      replacement.setAttribute('src', filename);
      replacement.setAttribute('data-original', custom_emoji.url);
      replacement.setAttribute('data-static', custom_emoji.static_url);
    } else { // start of an unicode emoji
      rend = i + unicode_emoji.length;

      // If the matched character was followed by VS15 (for selecting text presentation), skip it.
      if (str.codePointAt(rend - 1) !== VS16 && str.codePointAt(rend) === VS15) {
        i = rend + 1;
        continue;
      }

      const { filename, shortCode } = unicodeMapping[unicode_emoji];
      const title = shortCode ? `:${shortCode}:` : '';

      const isSystemTheme = getIsSystemTheme();

      const theme = (isSystemTheme || !isDarkMode()) ? 'light' : 'dark';

      const imageFilename = emojiFilename(filename, theme);

      const img = document.createElement('img');
      img.setAttribute('draggable', 'false');
      img.setAttribute('class', 'emojione');
      img.setAttribute('alt', unicode_emoji);
      img.setAttribute('title', title);
      img.setAttribute('src', `${assetHost}/emoji/${imageFilename}.svg`);

      if (isSystemTheme && imageFilename !== emojiFilename(filename, 'dark')) {
        replacement = document.createElement('picture');

        const source = document.createElement('source');
        source.setAttribute('media', '(prefers-color-scheme: dark)');
        source.setAttribute('srcset', `${assetHost}/emoji/${emojiFilename(filename, 'dark')}.svg`);
        replacement.appendChild(source);
        replacement.appendChild(img);
      } else {
        replacement = img;
      }
    }

    // Add the processed-up-to-now string and the emoji replacement
    fragment.append(document.createTextNode(str.slice(0, i)));
    fragment.append(replacement);
    str = str.slice(rend);
    i = 0;
  }

  fragment.append(document.createTextNode(str));
  node.parentElement.replaceChild(fragment, node);
};

const emojifyNode = (node, customEmojis) => {
  for (const child of Array.from(node.childNodes)) {
    switch(child.nodeType) {
    case Node.TEXT_NODE:
      emojifyTextNode(child, customEmojis);
      break;
    case Node.ELEMENT_NODE:
      if (!child.classList.contains('invisible'))
        emojifyNode(child, customEmojis);
      break;
    }
  }
};

/**
 * Legacy emoji processing function.
 * @param {string} str
 * @param {object} customEmojis
 * @returns {string}
 */
const emojify = (str, customEmojis = {}) => {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = str;

  if (!Object.keys(customEmojis).length)
    customEmojis = null;

  emojifyNode(wrapper, customEmojis);

  return wrapper.innerHTML;
};

export default emojify;
