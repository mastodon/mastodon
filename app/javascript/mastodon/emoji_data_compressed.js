// @preval
const data = require('emoji-mart/dist/data').default;
const pick = require('lodash/pick');
const values = require('lodash/values');

const condensedEmojis = Object.keys(data.emojis).map(key => {
  if (!data.emojis[key].short_names[0] === key) {
    throw new Error('The condenser expects the first short_code to be the ' +
      'key. It may need to be rewritten if the emoji change such that this ' +
      'is no longer the case.');
  }
  return values(pick(data.emojis[key], ['short_names', 'unified', 'search']));
});

// JSON.parse/stringify is to emulate what @preval is doing and avoid any
// inconsistent behavior in dev mode
module.exports = JSON.parse(JSON.stringify({
  emojis: condensedEmojis,
  skins: data.skins,
  categories: data.categories,
  short_names: data.short_names,
}));
