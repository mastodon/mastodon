// This code is largely borrowed from:
// https://github.com/missive/emoji-mart/blob/5f2ffcc/src/utils/emoji-index.js

import data from './emoji_mart_data_light';
import { getData, getSanitizedData, uniq, intersect } from './emoji_utils';

let originalPool = {};
let index = {};
let emojisList = {};
let emoticonsList = {};
let customEmojisList = [];

for (let emoji in data.emojis) {
  let emojiData = data.emojis[emoji];
  let { short_names, emoticons } = emojiData;
  let id = short_names[0];

  if (emoticons) {
    emoticons.forEach(emoticon => {
      if (emoticonsList[emoticon]) {
        return;
      }

      emoticonsList[emoticon] = id;
    });
  }

  emojisList[id] = getSanitizedData(id);
  originalPool[id] = emojiData;
}

function clearCustomEmojis(pool) {
  customEmojisList.forEach((emoji) => {
    let emojiId = emoji.id || emoji.short_names[0];

    delete pool[emojiId];
    delete emojisList[emojiId];
  });
}

function addCustomToPool(custom, pool) {
  if (customEmojisList.length) clearCustomEmojis(pool);

  custom.forEach((emoji) => {
    let emojiId = emoji.id || emoji.short_names[0];

    if (emojiId && !pool[emojiId]) {
      pool[emojiId] = getData(emoji);
      emojisList[emojiId] = getSanitizedData(emoji);
    }
  });

  customEmojisList = custom;
  index = {};
}

function search(value, { emojisToShowFilter, maxResults, include, exclude, custom } = {}) {
  if (custom !== undefined) {
    if (customEmojisList !== custom)
      addCustomToPool(custom, originalPool);
  } else {
    custom = [];
  }

  maxResults = maxResults || 75;
  include = include || [];
  exclude = exclude || [];

  let results = null,
    pool = originalPool;

  if (value.length) {
    if (value === '-' || value === '-1') {
      return [emojisList['-1']];
    }

    let values = value.toLowerCase().split(/[\s|,\-_]+/),
      allResults = [];

    if (values.length > 2) {
      values = [values[0], values[1]];
    }

    if (include.length || exclude.length) {
      pool = {};

      data.categories.forEach(category => {
        let isIncluded = include && include.length ? include.indexOf(category.name.toLowerCase()) > -1 : true;
        let isExcluded = exclude && exclude.length ? exclude.indexOf(category.name.toLowerCase()) > -1 : false;
        if (!isIncluded || isExcluded) {
          return;
        }

        category.emojis.forEach(emojiId => pool[emojiId] = data.emojis[emojiId]);
      });

      if (custom.length) {
        let customIsIncluded = include && include.length ? include.indexOf('custom') > -1 : true;
        let customIsExcluded = exclude && exclude.length ? exclude.indexOf('custom') > -1 : false;
        if (customIsIncluded && !customIsExcluded) {
          addCustomToPool(custom, pool);
        }
      }
    }

    const searchValue = (value) => {
      let aPool = pool,
        aIndex = index,
        length = 0;

      for (let charIndex = 0; charIndex < value.length; charIndex++) {
        const char = value[charIndex];
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
              if (sub === id) score = 0;

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
    };

    if (values.length > 1) {
      results = searchValue(value);
    } else {
      results = [];
    }

    allResults = values.map(searchValue).filter(a => a);

    if (allResults.length > 1) {
      allResults = intersect.apply(null, allResults);
    } else if (allResults.length) {
      allResults = allResults[0];
    }

    results = uniq(results.concat(allResults));
  }

  if (results) {
    if (emojisToShowFilter) {
      results = results.filter((result) => emojisToShowFilter(data.emojis[result.id]));
    }

    if (results && results.length > maxResults) {
      results = results.slice(0, maxResults);
    }
  }

  return results;
}

export { search };
