import { resolve } from 'node:path';
import { writeFile } from 'node:fs/promises';

import {
  buildSearch,
  type Emoji,
  type SkinVariation,
} from 'emoji-mart/dist-es/utils/data';

import { unicodeToFilename } from './unicode_to_filename';
import { unicodeToUnifiedName } from './unicode_to_unified_name';
import type {
  EmojiCompressed,
  FilenameTuple,
  Search,
  SearchData,
  ShortCodesToEmojiMap,
} from './emoji_compressed';

interface EmojiListItem {
  id: string;
  name: string;
  keywords: string[];
  skins: Skin[];
  version: number;
  emoticons?: string[];
}

interface Skin {
  unified: string;
  native: string;
  x: number;
  y: number;
}

interface EmojiSheetDataItem {
  unified: string;
  sheet_x: number;
  sheet_y: number;
  skin_variations: Record<
    string,
    Omit<EmojiSheetDataItem, 'skin_variations'> | undefined
  >;
}

interface ExtendedEmoji extends Omit<Emoji, 'skin_variations'> {
  search?: Search;
  native?: string;
  skin_variations?: Record<string, ExtendedSkinVariation>;
}

type ExtendedSkinVariation = {
  native?: string;
} & Pick<
  SkinVariation,
  'unified' | 'non_qualified' | 'sheet_x' | 'sheet_y' | 'has_img_twitter'
>;

type ImportTypes = [
  typeof import('@emoji-mart/data/i18n/en.json'),
  typeof import('@emoji-mart/data/sets/15/all.json'),
  { default: Record<string, string> },
  { default: EmojiSheetDataItem[] },
];

async function main() {
  const [
    emojiMart5LocalesData,
    emojiMart5Data,
    { default: emojiMap },
    { default: emojiSheetData },
  ]: ImportTypes = await Promise.all([
    import('@emoji-mart/data/i18n/en.json'),
    import('@emoji-mart/data/sets/15/all.json'),
    import('./emoji_map.json'),
    import('./emoji_sheet.json'),
  ]);

  const emojiList: EmojiListItem[] = Object.values(emojiMart5Data.emojis);

  const categories = emojiMart5Data.categories.map((cat) => ({
    ...cat,
    name: emojiMart5LocalesData.categories[
      cat.id as keyof typeof emojiMart5LocalesData.categories
    ],
  }));
  const aliases = emojiMart5Data.aliases;
  const emojis = extractEmojiData(emojiList, emojiSheetData);

  const excluded = ['®', '©', '™'];
  const shortcodeMap: Record<string, string> = emojiList.reduce(
    (map, emoji) => ({
      [emoji.skins[0]?.native ?? '']: emoji.id,
      ...map,
    }),
    {},
  );

  const emojisWithoutShortCodes: FilenameTuple[] = [];
  const shortCodesToEmojiPartialMap: Record<string, FilenameTuple> = {};

  for (const key of Object.keys(emojiMap)) {
    if (excluded.includes(key)) {
      continue;
    }
    const filenameData: FilenameTuple = [key];

    const filename = emojiMap[key];
    if (filename && unicodeToFilename(key) !== filename) {
      // filename can't be derived using unicodeToFilename
      filenameData.push(filename);
    }

    const normalizedKey = key.replace(/[\u{1F3FB}-\u{1F3FF}]/u, '');
    const shortcode =
      shortcodeMap[normalizedKey] ?? shortcodeMap[normalizedKey + '\uFE0F'];
    if (shortcode) {
      shortCodesToEmojiPartialMap[shortcode] = filenameData;
    } else {
      emojisWithoutShortCodes.push(filenameData);
    }
  }

  for (const emoji of Object.values(emojiMart5Data.emojis)) {
    const firstSkin = emoji.skins[0];
    if (firstSkin) {
      shortcodeMap[firstSkin.native] = emoji.id;
    }
  }

  const shortCodesToEmojiMap: ShortCodesToEmojiMap = {};

  for (const [key, emoji] of Object.entries(emojis)) {
    const { native, search, unified } = emoji;
    if (!native || !search) {
      continue;
    }
    let { short_names } = emoji;
    if (!short_names || short_names[0] !== key) {
      throw new Error(
        'The compressor expects the first short_code to be the ' +
          'key. It may need to be rewritten if the emoji change such that this ' +
          'is no longer the case.',
      );
    }
    short_names = short_names.slice(1); // first short name can be inferred from the key

    const searchData: SearchData = [native, short_names, search, undefined];

    if (unicodeToUnifiedName(native) !== unified) {
      // unified name can't be derived from unicodeToUnifiedName
      searchData[3] = unified;
    }

    const filenameData = shortCodesToEmojiPartialMap[key];
    if (filenameData) {
      shortCodesToEmojiMap[key] = [[filenameData], searchData];
    }
  }

  const emojiCompressed: EmojiCompressed = [
    shortCodesToEmojiMap,
    null,
    categories,
    aliases,
    emojisWithoutShortCodes,
    {
      compressed: false,
      categories,
      aliases,
      emojis: emojis as Record<string, Emoji>, // Suppress errors with differences with skin_variations
    },
  ];

  const json = JSON.stringify(emojiCompressed, null, 2);
  const fileName = resolve(
    process.cwd(),
    'app/javascript/mastodon/features/emoji',
    'emoji_compressed.json',
  );

  await writeFile(fileName, json, 'utf-8');
  console.log(`Emoji compressed data written to ${fileName}`);
}

function extractEmojiData(
  list: EmojiListItem[],
  sheetData: EmojiSheetDataItem[],
): Record<string, ExtendedEmoji> {
  const resultMap: Record<string, ExtendedEmoji> = {};
  for (const item of list) {
    const unified = item.skins.at(0)?.unified.toUpperCase();
    if (!unified) {
      continue;
    }
    const emojiFromRawData = sheetData.find((e) => e.unified === unified);
    if (!emojiFromRawData) {
      continue;
    }
    const skin_variations: Record<string, ExtendedSkinVariation> = {};
    for (const skin of item.skins.slice(1)) {
      if (!emojiFromRawData.skin_variations) {
        continue;
      }
      const matchingEmoji = Object.entries(
        emojiFromRawData.skin_variations,
      ).find(([, value]) => value?.unified.toLowerCase() === skin.unified);
      if (!matchingEmoji) {
        continue;
      }
      const [matchingRawCodePoints, matchingRawEmoji] = matchingEmoji;

      if (matchingRawEmoji && matchingRawCodePoints) {
        // At the time of writing, the json from `@emoji-mart/data` doesn't have data
        // for emoji like `woman-heart-woman` with two different skin tones.
        const skinToneCode = matchingRawCodePoints.split('-')[0];
        if (skinToneCode) {
          skin_variations[skinToneCode] = {
            unified: matchingRawEmoji.unified.toUpperCase(),
            non_qualified: null,
            sheet_x: matchingRawEmoji.sheet_x,
            sheet_y: matchingRawEmoji.sheet_y,
            has_img_twitter: true,
            native: unifiedToNative(matchingRawEmoji.unified.toUpperCase()),
          };
        }
      }
    }
    resultMap[item.id] = {
      name: item.name,
      unified,
      has_img_twitter: true,
      keywords: [item.id, ...item.keywords],
      sheet_x: emojiFromRawData.sheet_x,
      sheet_y: emojiFromRawData.sheet_y,
      short_names: [item.id],
      text: item.emoticons?.at(0) ?? '',
      emoticons: item.emoticons,
      added_in: item.version ?? 6,
      skin_variations,
      native: unifiedToNative(unified.toUpperCase()),
      search: buildSearch(item),
    };
  }

  return resultMap;
}

function unifiedToNative(unified: string) {
  let unicodes = unified.split('-'),
    codePoints = unicodes.map((u) => parseInt(`0x${u}`));

  return String.fromCodePoint(...codePoints);
}

main()
  .catch(console.error)
  .finally(() => {
    process.exit(0);
  });
