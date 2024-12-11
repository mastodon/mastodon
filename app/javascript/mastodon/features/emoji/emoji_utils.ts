// This code is largely borrowed from:
// https://github.com/missive/emoji-mart/blob/5f2ffcc/src/utils/index.js

import type {
  BaseEmoji,
  CustomEmoji,
  EmojiSkin,
  PickerProps,
} from 'emoji-mart';
import type { Emoji, SkinVariation } from 'emoji-mart/dist-es/utils/data';

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

const COLONS_REGEX = /^(?::([^:]+):)(?::skin-tone-(\d):)?$/;
const SKINS = ['1F3FA', '1F3FB', '1F3FC', '1F3FD', '1F3FE', '1F3FF'];

function unifiedToNative(unified: Emoji['unified']) {
  const unicodes = unified?.split('-') ?? [];
  const codePoints = unicodes.map((u) => +`0x${u}`);

  return String.fromCodePoint(...codePoints);
}

/*
 * `skin_tone` is used [here]{@link node_modules/emoji-mart/dist-es/utils/index.js#19}, but is not found in the [type definition]{@link node_modules/@types/emoji-mart/dist-es/utils/emoji-index/nimble-emoji-index.d.ts}.
 * `emoji-mart` does not come with a built-in type, so you need to add a separate type with DefinitelyTyped.
 * The type and implementation have different maintainers and packages, so the installed versions of `@types/emoji-mart` and `emoji-mart` may not match.
 */

interface SkinTone {
  skin_tone?: EmojiSkin;
}

type RawEmoji = BaseEmoji &
  CustomEmoji &
  Pick<Emoji, 'skin_variations'> &
  Pick<PickerProps, 'custom'> &
  SkinTone;

function sanitize(
  emoji: RawEmoji,
):
  | BaseEmoji
  | (Omit<CustomEmoji, 'short_names'> & Pick<PickerProps, 'custom'>) {
  const {
    name = '',
    short_names = [],
    skin_tone,
    skin_variations,
    emoticons = [],
    unified = '',
    custom,
    imageUrl,
  } = emoji;
  const id = emoji.id || short_names[0];

  let colons = `:${id}:`;

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
    skin: skin_tone ?? (skin_variations ? 1 : null),
    native: unifiedToNative(unified),
  };
}

type GetDataArgs = [
  emoji: BaseEmoji | string,
  skin: EmojiSkin | null,
  set?: 'apple' | 'google' | 'twitter' | 'facebook' | 'emojione' | 'messenger',
];

function getSanitizedData(...args: GetDataArgs) {
  return sanitize(getData(...args));
}

function getData(...[emoji, skin, set]: GetDataArgs) {
  /*
   The version of [the referenced source code]{@link https://github.com/missive/emoji-mart/blob/5f2ffcc/src/utils/index.js} does not match that of DefinitelyTyped.
   It is also old, and non-existent properties have been added or removed, making it difficult to achieve type consistency.
   */
  /* eslint-disable @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
  /* eslint-disable-next-line @typescript-eslint/no-explicit-any */
  let emojiData: any = {};

  if (typeof emoji === 'string') {
    const matches = emoji.match(COLONS_REGEX);

    if (matches) {
      emoji = matches[1];

      const int = parseInt(matches[2]);
      const isValid = (value: number): value is EmojiSkin =>
        ([1, 2, 3, 4, 5, 6] satisfies EmojiSkin[]).some(
          (skin) => skin === value,
        );

      if (isValid(int)) {
        skin = int;
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
      skin = skin ?? emoji.skin;
    }
  }

  if (!Object.keys(emojiData).length && typeof emoji === 'object') {
    emojiData = emoji;
    emojiData.custom = true;

    if (!emojiData.search) {
      emojiData.search = buildSearch(emoji);
    }
  }

  emojiData.emoticons = emojiData.emoticons || [];
  emojiData.variations = emojiData.variations || [];

  if (emojiData.skin_variations && skin && skin > 1 && set) {
    const skinKey = SKINS[skin - 1];
    const variationData = emojiData.skin_variations[skinKey];

    if (variationData[`has_img_${set}`]) {
      emojiData.skin_tone = skin;

      for (const k in variationData) {
        type K = keyof typeof emojiData;
        emojiData[k as K] = variationData[k as keyof SkinVariation];
      }
    }
  }

  if (emojiData.variations.length) {
    emojiData.unified = emojiData.variations.shift();
  }

  return emojiData as RawEmoji;

  /* eslint-enable @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-assignment, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
}

// TODO: General array operations not related to emojis. Consider separating them into separate files.
function uniq(arr: []) {
  return arr.reduce((acc, item) => {
    if (!acc.includes(item)) {
      acc.push(item);
    }
    return acc;
  }, []);
}

// TODO: General array operations not related to emojis. Consider separating them into separate files.
function intersect(a: [], b: []) {
  const uniqA = uniq(a);
  const uniqB = uniq(b);

  return uniqA.filter((item) => uniqB.includes(item));
}

export { getData, getSanitizedData, uniq, intersect, unifiedToNative };
