const path = require('path');

const upstreamTranslations = require(path.join(__dirname, "../app/javascript/mastodon/locales/en.json"));
const currentTranslations = require(path.join(__dirname, "../app/javascript/flavours/glitch/locales/en.json"));

exports.format = (msgs) => {
  const results = {};
  for (const [id, msg] of Object.entries(msgs)) {
    if (!upstreamTranslations[id]) {
      results[id] = currentTranslations[id] || msg.defaultMessage;
    }
  }
  return results;
};
