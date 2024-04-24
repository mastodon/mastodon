// This code is largely borrowed from:
// https://github.com/missive/emoji-mart/blob/5f2ffcc/src/utils/index.js

import type { Emoji } from 'emoji-mart/dist-es/utils/data';

import * as data from './emoji_mart_data_light';

type Data = Pick<Emoji, 'short_names' | 'name' | 'keywords' | 'emoticons'>;

const buildSearch = (data: Data) => {
  const search: string[] = [];

  const addToSearch = (strings: Data[keyof Data], split: boolean) => {
    if (!strings) {
      return;
    }

    (Array.isArray(strings) ? strings : [strings]).forEach((string) => {
      (split ? string.split(/[-|_|\s]+/) : [string]).forEach((s) => {
        s = s.toLowerCase();

        if (!search.includes(s)) {
          search.push(s);
        }
      });
    });
  };

  addToSearch(data.short_names, true);
  addToSearch(data.name, true);
  addToSearch(data.keywords, false);
  addToSearch(data.emoticons, false);

  return search.join(',');
};

/* eslint-disable */

const _JSON = JSON;

const COLONS_REGEX = /^(?::([^:]+):)(?::skin-tone-(\d):)?$/;
const SKINS = ['1F3FA', '1F3FB', '1F3FC', '1F3FD', '1F3FE', '1F3FF'];

// @ts-expect-error
function unifiedToNative(unified) {
  let unicodes = unified.split('-'),
    // @ts-expect-error
    codePoints = unicodes.map((u) => `0x${u}`);

  return String.fromCodePoint(...codePoints);
}

// @ts-expect-error
function sanitize(emoji) {
  let {
      name,
      short_names,
      skin_tone,
      skin_variations,
      emoticons,
      unified,
      custom,
      imageUrl,
    } = emoji,
    id = emoji.id || short_names[0],
    colons = `:${id}:`;

  if (custom) {
    return {
      id,
      name,
      colons,
      emoticons,
      custom,
      imageUrl,
    };
  }

  if (skin_tone) {
    colons += `:skin-tone-${skin_tone}:`;
  }

  return {
    id,
    name,
    colons,
    emoticons,
    unified: unified.toLowerCase(),
    skin: skin_tone || (skin_variations ? 1 : null),
    native: unifiedToNative(unified),
  };
}

function getSanitizedData() {
  // @ts-expect-error
  return sanitize(getData(...arguments));
}

// @ts-expect-error
function getData(emoji, skin, set) {
  let emojiData = {};

  if (typeof emoji === 'string') {
    let matches = emoji.match(COLONS_REGEX);

    if (matches) {
      emoji = matches[1];

      if (matches[2]) {
        skin = parseInt(matches[2]);
      }
    }

    if (Object.hasOwn(data.short_names, emoji)) {
      emoji = data.short_names[emoji];
    }

    if (Object.hasOwn(data.emojis, emoji)) {
      emojiData = data.emojis[emoji];
    }
  } else if (emoji.id) {
    if (Object.hasOwn(data.short_names, emoji.id)) {
      emoji.id = data.short_names[emoji.id];
    }

    if (Object.hasOwn(data.emojis, emoji.id)) {
      emojiData = data.emojis[emoji.id];
      skin = skin || emoji.skin;
    }
  }

  if (!Object.keys(emojiData).length) {
    emojiData = emoji;
    // @ts-expect-error
    emojiData.custom = true;

    // @ts-expect-error
    if (!emojiData.search) {
      // @ts-expect-error
      emojiData.search = buildSearch(emoji);
    }
  }

  // @ts-expect-error
  emojiData.emoticons = emojiData.emoticons || [];
  // @ts-expect-error
  emojiData.variations = emojiData.variations || [];

  // @ts-expect-error
  if (emojiData.skin_variations && skin > 1 && set) {
    emojiData = JSON.parse(_JSON.stringify(emojiData));

    let skinKey = SKINS[skin - 1],
      // @ts-expect-error
      variationData = emojiData.skin_variations[skinKey];

    // @ts-expect-error
    if (!variationData.variations && emojiData.variations) {
      // @ts-expect-error
      delete emojiData.variations;
    }

    if (variationData[`has_img_${set}`]) {
      // @ts-expect-error
      emojiData.skin_tone = skin;

      for (let k in variationData) {
        let v = variationData[k];
        // @ts-expect-error
        emojiData[k] = v;
      }
    }
  }

  // @ts-expect-error
  if (emojiData.variations && emojiData.variations.length) {
    emojiData = JSON.parse(_JSON.stringify(emojiData));
    // @ts-expect-error
    emojiData.unified = emojiData.variations.shift();
  }

  return emojiData;
}

// @ts-expect-error
function uniq(arr) {
  // @ts-expect-error
  return arr.reduce((acc, item) => {
    if (acc.indexOf(item) === -1) {
      acc.push(item);
    }
    return acc;
  }, []);
}

// @ts-expect-error
function intersect(a, b) {
  const uniqA = uniq(a);
  const uniqB = uniq(b);

  // @ts-expect-error
  return uniqA.filter((item) => uniqB.indexOf(item) >= 0);
}

// @ts-expect-error
function deepMerge(a, b) {
  let o = {};

  for (let key in a) {
    let originalValue = a[key],
      value = originalValue;

    if (Object.hasOwn(b, key)) {
      value = b[key];
    }

    if (typeof value === 'object') {
      value = deepMerge(originalValue, value);
    }

    // @ts-expect-error
    o[key] = value;
  }

  return o;
}

// https://github.com/sonicdoe/measure-scrollbar
function measureScrollbar() {
  const div = document.createElement('div');

  div.style.width = '100px';
  div.style.height = '100px';
  div.style.overflow = 'scroll';
  div.style.position = 'absolute';
  div.style.top = '-9999px';

  document.body.appendChild(div);
  const scrollbarWidth = div.offsetWidth - div.clientWidth;
  document.body.removeChild(div);

  return scrollbarWidth;
}

export {
  getData,
  getSanitizedData,
  uniq,
  intersect,
  deepMerge,
  unifiedToNative,
  measureScrollbar,
};
