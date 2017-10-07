// This code is largely borrowed from:
// https://github.com/missive/emoji-mart/blob/bbd4fbe/src/utils/emoji-index.js

import data from './emoji_mart_data_light';
import { getData, getSanitizedData, intersect } from './emoji_utils';

let index = {};
let emojisList = {};
let emoticonsList = {};
let previousInclude = [];
let previousExclude = [];

for (let emoji in data.emojis) {
  let emojiData = data.emojis[emoji],
    { short_names, emoticons } = emojiData,
    id = short_names[0];

  for (let emoticon of (emoticons || [])) {
    if (!emoticonsList[emoticon]) {
      emoticonsList[emoticon] = id;
    }
  }

  emojisList[id] = getSanitizedData(id);
}

function search(value, { emojisToShowFilter, maxResults, include, exclude, custom = [] } = {}) {
  maxResults = maxResults || 75;
  include = include || [];
  exclude = exclude || [];

  if (custom.length) {
    for (const emoji of custom) {
      data.emojis[emoji.id] = getData(emoji);
      emojisList[emoji.id] = getSanitizedData(emoji);
    }

    data.categories.push({
      name: 'Custom',
      emojis: custom.map(emoji => emoji.id),
    });
  }

  let results = null;
  let pool = data.emojis;

  if (value.length) {
    if (value === '-' || value === '-1') {
      return [emojisList['-1']];
    }

    let values = value.toLowerCase().split(/[\s|,|\-|_]+/);

    if (values.length > 2) {
      values = [values[0], values[1]];
    }

    if (include.length || exclude.length) {
      pool = {};

      if (previousInclude !== include.sort().join(',') || previousExclude !== exclude.sort().join(',')) {
        previousInclude = include.sort().join(',');
        previousExclude = exclude.sort().join(',');
        index = {};
      }

      for (let category of data.categories) {
        let isIncluded = include && include.length ? include.indexOf(category.name.toLowerCase()) > -1 : true;
        let isExcluded = exclude && exclude.length ? exclude.indexOf(category.name.toLowerCase()) > -1 : false;
        if (!isIncluded || isExcluded) {
          continue;
        }

        for (let emojiId of category.emojis) {
          pool[emojiId] = data.emojis[emojiId];
        }
      }
    } else if (previousInclude.length || previousExclude.length) {
      index = {};
    }

    let allResults = values.map((value) => {
      let aPool = pool;
      let aIndex = index;
      let length = 0;

      for (let char of value.split('')) {
        length++;

        aIndex[char] = aIndex[char] || {};
        aIndex = aIndex[char];

        if (!aIndex.results) {
          let scores = {};

          aIndex.results = [];
          aIndex.pool = {};

          for (let id in aPool) {
            let emoji = aPool[id],
              { search } = emoji,
              sub = value.substr(0, length),
              subIndex = search.indexOf(sub);

            if (subIndex !== -1) {
              let score = subIndex + 1;
              if (sub === id) {
                score = 0;
              }

              aIndex.results.push(emojisList[id]);
              aIndex.pool[id] = emoji;

              scores[id] = score;
            }
          }

          aIndex.results.sort((a, b) => {
            let aScore = scores[a.id],
              bScore = scores[b.id];

            return aScore - bScore;
          });
        }

        aPool = aIndex.pool;
      }

      return aIndex.results;
    }).filter(a => a);

    if (allResults.length > 1) {
      results = intersect(...allResults);
    } else if (allResults.length) {
      results = allResults[0];
    } else {
      results = [];
    }
  }

  if (results) {
    if (emojisToShowFilter) {
      results = results.filter((result) => emojisToShowFilter(data.emojis[result.id].unified));
    }

    if (results && results.length > maxResults) {
      results = results.slice(0, maxResults);
    }
  }

  return results;
}

export { search };
