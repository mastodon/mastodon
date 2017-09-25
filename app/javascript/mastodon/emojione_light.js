// @preval
// http://www.unicode.org/Public/emoji/5.0/emoji-test.txt

const emojis         = require('./emoji_map.json');
const { emojiIndex } = require('emoji-mart');
const excluded       = ['®', '©', '™'];
const skins          = ['🏻', '🏼', '🏽', '🏾', '🏿'];
const shortcodeMap   = {};

Object.keys(emojiIndex.emojis).forEach(key => {
  shortcodeMap[emojiIndex.emojis[key].native] = emojiIndex.emojis[key].id;
});

const stripModifiers = unicode => {
  skins.forEach(tone => {
    unicode = unicode.replace(tone, '');
  });

  return unicode;
};

Object.keys(emojis).forEach(key => {
  if (excluded.includes(key)) {
    delete emojis[key];
    return;
  }

  const normalizedKey = stripModifiers(key);
  let shortcode       = shortcodeMap[normalizedKey];

  if (!shortcode) {
    shortcode = shortcodeMap[normalizedKey + '\uFE0F'];
  }

  emojis[key] = [emojis[key], shortcode];
});

module.exports.unicodeMapping = emojis;
