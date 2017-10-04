const data = require('./emoji_data_compressed');

// decompress
const emojis = {};
data.emojis.forEach(compressedEmoji => {
  const [ short_names, unified, search ] = compressedEmoji;
  emojis[short_names[0]] = {
    short_names,
    unified,
    search,
  };
});

data.emojis = emojis;

module.exports = data;
