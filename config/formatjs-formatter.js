const path = require('path');

const currentTranslations = require(
  path.join(__dirname, '../app/javascript/mastodon/locales/en.json'),
);

exports.format = (msgs) => {
  const results = {};
  for (const [id, msg] of Object.entries(msgs)) {
    results[id] = currentTranslations[id] || msg.defaultMessage;
  }
  return results;
};
