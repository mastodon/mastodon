import { isList } from 'immutable';

import type { CategoryName, Data as TwemojiData } from 'emoji-mart';
import type { SkinVariation } from 'emoji-mart/dist-es/utils/data';
import type { CompactEmoji, SkinTone } from 'emojibase';
import { fromHexcodeToCodepoint } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import {
  VARIATION_SELECTOR_CODE,
  KEYCAP_CODE,
  EMOJIS_WITH_DARK_BORDER,
  EMOJIS_WITH_LIGHT_BORDER,
  EMOJIS_REQUIRING_INVERSION_IN_LIGHT_MODE,
  EMOJIS_REQUIRING_INVERSION_IN_DARK_MODE,
  EMOJI_MIN_TOKEN_LENGTH,
} from './constants';
import type {
  CustomEmojiData,
  CustomEmojiMapArg,
  ExtraCustomEmojiMap,
  UnicodeEmojiData,
} from './types';
import { emojiToUnicodeHex } from './utils';

const SKIN_TONE_MAP: Record<number, SkinTone> = {
  0x1f3fb: 1, // Light skin tone
  0x1f3fc: 2, // Medium-light skin tone
  0x1f3fd: 3, // Medium skin tone
  0x1f3fe: 4, // Medium-dark skin tone
  0x1f3ff: 5, // Dark skin tone
};

export function transformEmojiData(
  emoji: CompactEmoji,
  segmenter: Intl.Segmenter | null,
): UnicodeEmojiData {
  const {
    shortcodes = [],
    tags = [],
    label,
    emoticon,
    hexcode,
    unicode,
    group,
    order,
    skins = [],
  } = emoji;
  const extract = (str: string) => extractTokens(str, segmenter);

  let normalizedEmoticons: string[] | undefined = undefined;
  if (emoticon) {
    normalizedEmoticons = Array.isArray(emoticon) ? emoticon : [emoticon];
  }

  const tokens = [
    ...new Set([
      ...shortcodes.map(extract).flat(),
      ...tags.map(extract).flat(),
      ...extract(label),
      ...(normalizedEmoticons ?? []),
    ]),
  ].sort((a, b) => a.localeCompare(b));

  const res: UnicodeEmojiData = {
    tokens,
    shortcodes,
    label,
    emoticons: normalizedEmoticons,
    hexcode,
    unicode,
    group,
    order,
  };

  for (const skin of skins) {
    res.skinHexcodes ??= [];
    res.skinHexcodes.push(skin.hexcode);

    res.skinTones ??= [];
    for (const codePoint of skin.unicode) {
      const tone = SKIN_TONE_MAP[codePoint.codePointAt(0) ?? 0];
      if (tone) {
        res.skinTones.push(tone);
        break;
      }
    }
  }

  return res;
}

export function transformCustomEmojiData(
  emoji: ApiCustomEmojiJSON,
): CustomEmojiData {
  const tokens = emoji.shortcode
    .split('_')
    .filter((word) => word.length >= EMOJI_MIN_TOKEN_LENGTH)
    .map((word) => word.toLowerCase());
  return {
    ...emoji,
    tokens,
  };
}

export function skinHexcodeToEmoji(
  skinHexcode: string,
  emoji: UnicodeEmojiData,
): UnicodeEmojiData {
  return {
    ...emoji,
    unicode: String.fromCodePoint(...fromHexcodeToCodepoint(skinHexcode)),
    hexcode: skinHexcode,
  };
}

// Misc codes that have special handling
const EYE_CODE = 0x1f441;
const SPEECH_BUBBLE_CODE = 0x1f5e8;

export function unicodeToTwemojiHex(unicodeHex: string): string {
  const codes = fromHexcodeToCodepoint(unicodeHex);
  const normalizedCodes: number[] = [];
  for (let i = 0; i < codes.length; i++) {
    const code = codes[i];
    if (!code) {
      continue;
    }

    // Some emoji have their variation selector removed
    if (code === VARIATION_SELECTOR_CODE) {
      // Key emoji
      if (i === 1 && codes.at(-1) === KEYCAP_CODE) {
        continue;
      }
      // Eye in speech bubble
      if (codes.at(0) === EYE_CODE && codes.at(-2) === SPEECH_BUBBLE_CODE) {
        continue;
      }
    }

    normalizedCodes.push(code);
  }

  return normalizedCodes
    .map((code) => code.toString(16))
    .join('-')
    .toLowerCase();
}

const CODES_WITH_DARK_BORDER = EMOJIS_WITH_DARK_BORDER.map(emojiToUnicodeHex);

const CODES_WITH_LIGHT_BORDER = EMOJIS_WITH_LIGHT_BORDER.map(emojiToUnicodeHex);

export function unicodeHexToUrl({
  unicodeHex,
  darkTheme,
  assetHost,
}: {
  unicodeHex: string;
  darkTheme: boolean;
  assetHost: string;
}): string {
  const normalizedHex = unicodeToTwemojiHex(unicodeHex);
  let url = `${assetHost}/emoji/${normalizedHex}`;
  if (darkTheme && CODES_WITH_LIGHT_BORDER.includes(normalizedHex)) {
    url += '_border';
  }
  if (CODES_WITH_DARK_BORDER.includes(normalizedHex)) {
    url += '_border';
  }
  url += '.svg';
  return url;
}

export function emojiToInversionClassName(emoji: string): string | null {
  if (EMOJIS_REQUIRING_INVERSION_IN_DARK_MODE.includes(emoji)) {
    return 'invert-on-dark';
  }
  if (EMOJIS_REQUIRING_INVERSION_IN_LIGHT_MODE.includes(emoji)) {
    return 'invert-on-light';
  }
  return null;
}

export function cleanExtraEmojis(extraEmojis?: CustomEmojiMapArg | null) {
  if (!extraEmojis) {
    return null;
  }
  if (!Array.isArray(extraEmojis) && !isList(extraEmojis)) {
    return extraEmojis;
  }
  const emojis: ExtraCustomEmojiMap = {};
  const emojiArray = isList(extraEmojis) ? extraEmojis.toJS() : extraEmojis;
  for (const emoji of emojiArray) {
    emojis[emoji.shortcode] = emoji;
  }

  return emojis;
}

/**
 * Tokenizes an input string into words, using Intl.Segmenter if available.
 * @param input Any input string.
 * @param segmenter Segmenter, if available.
 * @returns Array of tokens in lowercase.
 */
export function extractTokens(
  input: string,
  segmenter: Intl.Segmenter | null,
): string[] {
  if (!input.trim()) {
    return [];
  }
  const tokens: string[] = [];

  // Prefer to use Intl.Segmenter if available for better locale support.
  if (segmenter) {
    for (const { isWordLike, segment } of segmenter.segment(
      input.replaceAll('_', ' '), // Handle underscores from shortcodes.
    )) {
      if (isWordLike && segment.length >= EMOJI_MIN_TOKEN_LENGTH) {
        tokens.push(segment.toLowerCase());
      }
    }
  } else {
    // Fallback to simple splitting.
    input.split(/[\s_-]+/).forEach((word) => {
      if (/\w/.test(word) && word.length >= EMOJI_MIN_TOKEN_LENGTH) {
        tokens.push(word.toLowerCase());
      }
    });
  }
  return tokens;
}

const GROUP_KEY_TO_TWEMOJI_CATEGORY: Record<number, CategoryName> = {
  [0]: 'people',
  [1]: 'people',
  // 2 is components.
  [3]: 'nature',
  [4]: 'foods',
  [6]: 'activity',
  [5]: 'places',
  [7]: 'objects',
  [8]: 'symbols',
  [9]: 'flags',
};

type TwemojiMap = Record<string, [string, number, number]>;

interface TwemojiDataEmoji {
  // Label
  a: string;
  // Qualified hexcode
  b: string;
  // Unqualified hexcode
  c?: string;
  // has_img_twitter - Always true
  f: boolean;
  // Sheet offset
  k: [number, number];
  // Keywords
  j?: string[];
  skin_variations?: Record<string, SkinVariation>;
}

export function transformUnicodeEmojiToTwemojiData({
  emojis,
  twemojiMap,
  categoryLabels,
}: {
  emojis: UnicodeEmojiData[];
  twemojiMap: TwemojiMap;
  categoryLabels: Record<CategoryName, string>;
}): TwemojiData {
  const categoryMap: Partial<Record<CategoryName, string[]>> = {};
  const emojisMap: Record<string, TwemojiDataEmoji> = {};

  for (const emoji of emojis) {
    let hexcode = emoji.hexcode;
    let sheetData = twemojiMap[hexcode];
    if (!sheetData && !hexcode.endsWith('-FE0F')) {
      hexcode = `${hexcode}-FE0F`;
      sheetData = twemojiMap[hexcode];
    }

    if (!sheetData) {
      console.warn(
        'No sheet data for emoji %s (%s)',
        emoji.hexcode,
        emoji.label,
      );
      continue;
    }
    const [code, x, y] = sheetData;
    const twemoji: TwemojiDataEmoji = {
      a: emoji.label,
      b: hexcode,
      f: true,
      k: [x, y],
    };

    const unqualifiedHex = unicodeToTwemojiHex(emoji.hexcode).toUpperCase();
    if (unqualifiedHex !== emoji.hexcode) {
      twemoji.c = unqualifiedHex;
    }

    if (emoji.shortcodes.length > 0) {
      twemoji.j = emoji.shortcodes;
    }

    for (const skinHexcode of emoji.skinHexcodes ?? []) {
      const skinSheetData = twemojiMap[skinHexcode];
      if (!skinSheetData) {
        console.warn(
          'No sheet data for skin variation %s of emoji %s (%s)',
          skinHexcode,
          emoji.hexcode,
          emoji.label,
        );
        continue;
      }
      twemoji.skin_variations ??= {};

      const [skinCode, x, y] = skinSheetData;
      const twemojiSkinHex = unicodeToTwemojiHex(skinHexcode).toUpperCase();

      twemoji.skin_variations[skinCode] = {
        unified: skinHexcode,
        non_qualified: twemojiSkinHex !== skinHexcode ? twemojiSkinHex : null,
        image: '',
        sheet_x: x,
        sheet_y: y,
        has_img_apple: false,
        has_img_facebook: false,
        has_img_google: false,
        has_img_twitter: true,
        has_img_emojione: false,
        added_in: '1.0', // Incorrect, but that doesn't matter.
      };
    }

    emojisMap[code] = twemoji;

    const category = GROUP_KEY_TO_TWEMOJI_CATEGORY[emoji.group ?? -1];
    if (category) {
      categoryMap[category] ??= [];
      categoryMap[category].push(code);
    }
  }

  return {
    compressed: true,
    categories: Object.values(GROUP_KEY_TO_TWEMOJI_CATEGORY).map(
      (category) => ({
        id: category,
        name: categoryLabels[category],
        emojis: categoryMap[category] ?? [],
      }),
    ),
    emojis: emojisMap,
    aliases: twemojiAliases,
  };
}

const twemojiAliases = {
  satisfied: 'laughing',
  grinning_face_with_star_eyes: 'star-struck',
  grinning_face_with_one_large_and_one_small_eye: 'zany_face',
  smiling_face_with_smiling_eyes_and_hand_covering_mouth:
    'face_with_hand_over_mouth',
  face_with_finger_covering_closed_lips: 'shushing_face',
  face_with_one_eyebrow_raised: 'face_with_raised_eyebrow',
  face_with_open_mouth_vomiting: 'face_vomiting',
  shocked_face_with_exploding_head: 'exploding_head',
  serious_face_with_symbols_covering_mouth: 'face_with_symbols_on_mouth',
  poop: 'hankey',
  shit: 'hankey',
  collision: 'boom',
  raised_hand: 'hand',
  hand_with_index_and_middle_fingers_crossed: 'crossed_fingers',
  sign_of_the_horns: 'the_horns',
  reversed_hand_with_middle_finger_extended: 'middle_finger',
  thumbsup: '+1',
  thumbsdown: '-1',
  punch: 'facepunch',
  mother_christmas: 'mrs_claus',
  running: 'runner',
  'man-with-bunny-ears-partying': 'men-with-bunny-ears-partying',
  'woman-with-bunny-ears-partying': 'women-with-bunny-ears-partying',
  women_holding_hands: 'two_women_holding_hands',
  woman_and_man_holding_hands: 'man_and_woman_holding_hands',
  couple: 'man_and_woman_holding_hands',
  men_holding_hands: 'two_men_holding_hands',
  paw_prints: 'feet',
  flipper: 'dolphin',
  honeybee: 'bee',
  lady_beetle: 'ladybug',
  cooking: 'fried_egg',
  knife: 'hocho',
  red_car: 'car',
  sailboat: 'boat',
  waxing_gibbous_moon: 'moon',
  sun_small_cloud: 'mostly_sunny',
  sun_behind_cloud: 'barely_sunny',
  sun_behind_rain_cloud: 'partly_sunny_rain',
  lightning_cloud: 'lightning',
  tornado_cloud: 'tornado',
  tshirt: 'shirt',
  shoe: 'mans_shoe',
  telephone: 'phone',
  lantern: 'izakaya_lantern',
  open_book: 'book',
  envelope: 'email',
  pencil: 'memo',
  heavy_exclamation_mark: 'exclamation',
  staff_of_aesculapius: 'medical_symbol',
  'flag-cn': 'cn',
  'flag-de': 'de',
  'flag-es': 'es',
  'flag-fr': 'fr',
  uk: 'gb',
  'flag-gb': 'gb',
  'flag-it': 'it',
  'flag-jp': 'jp',
  'flag-kr': 'kr',
  'flag-ru': 'ru',
  'flag-us': 'us',
};
