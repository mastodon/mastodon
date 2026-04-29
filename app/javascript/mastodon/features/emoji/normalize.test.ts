import { readdir } from 'fs/promises';
import { basename, resolve } from 'path';

import type { CategoryName } from 'emoji-mart';
import type { SkinVariation } from 'emoji-mart/dist-es/utils/data';
import { flattenEmojiData } from 'emojibase';
import unicodeRawEmojis from 'emojibase-data/en/data.json';

import twemojiData from './emoji_data.json';
import {
  transformEmojiData,
  transformUnicodeEmojiToTwemojiData,
  unicodeToTwemojiHex,
} from './normalize';
import twemojiMap from './twemoji_map.json';

const emojiSVGFiles = await readdir(
  // This assumes tests are run from project root
  resolve(process.cwd(), 'public/emoji'),
  {
    withFileTypes: true,
  },
);
const svgFileNames = emojiSVGFiles
  .filter((file) => file.isFile() && file.name.endsWith('.svg'))
  .map((file) => basename(file.name, '.svg'));
const svgFileNamesWithoutBorder = svgFileNames.filter(
  (fileName) => !fileName.endsWith('_border'),
);

const unicodeEmojis = flattenEmojiData(unicodeRawEmojis);

describe('unicodeToTwemojiHex', () => {
  test.concurrent.for(
    unicodeEmojis
      // Our version of Twemoji only supports up to version 15.1
      .filter((emoji) => emoji.version < 16)
      .map((emoji) => [emoji.hexcode, emoji.label] as [string, string]),
  )('verifying an emoji exists for %s (%s)', ([hexcode], { expect }) => {
    const result = unicodeToTwemojiHex(hexcode);
    expect(svgFileNamesWithoutBorder).toContain(result);
  });
});

describe('transformUnicodeEmojiToTwemojiData', () => {
  const categoryLabels: Record<CategoryName, string> = {
    people: 'Smileys & Emotion',
    nature: 'Animals & Nature',
    foods: 'Food & Drink',
    activity: 'Activities',
    places: 'Travel & Places',
    objects: 'Objects',
    symbols: 'Symbols',
    flags: 'Flags',
    search: 'Search Results',
    custom: 'Custom Emoji',
    recent: 'Frequently Used',
  };
  const unicodePlainEmojis = unicodeEmojis
    .filter(({ tone }) => !tone)
    .map((emoji) =>
      transformEmojiData(
        {
          ...emoji,
          unicode: emoji.emoji,
          skins: emoji.skins?.map(({ emoji, skins: _, ...skin }) => ({
            ...skin,
            unicode: emoji,
          })),
        },
        null,
      ),
    );

  const result = transformUnicodeEmojiToTwemojiData({
    emojis: unicodePlainEmojis,
    categoryLabels,
    twemojiMap: twemojiMap as Record<
      keyof typeof twemojiMap,
      [string, number, number]
    >,
  });

  test.each(
    twemojiData.categories.map(
      ({ id, name, emojis }) => [name, id, emojis] as const,
    ),
  )('category %s (%s)', (_name, id, emojis) => {
    const cat = result.categories.find((cat) => cat.id === id);
    expect(cat).toBeDefined();
    expect(cat?.emojis).toHaveLength(emojis.length);
  });

  test.concurrent.each(Object.entries(twemojiData.emojis))(
    'emoji %s',
    (code, emoji) => {
      const found = result.emojis[code];
      expect(found).toBeDefined();
      expect(found?.b).toEqual(emoji.b);
      expect(found?.k).toEqual(emoji.k);
    },
  );

  const twemojiSkinVariationEntries: [string, string, SkinVariation][] = [];
  for (const [code, emoji] of Object.entries(twemojiData.emojis)) {
    if ('skin_variations' in emoji) {
      for (const [tone, variation] of Object.entries(emoji.skin_variations)) {
        twemojiSkinVariationEntries.push([code, tone, variation] as const);
      }
    }
  }

  test.concurrent.each(twemojiSkinVariationEntries)(
    'skin variation for %s tone %s',
    (code, tone, variation) => {
      const found = result.emojis[code];
      expect(found).toHaveProperty(['skin_variations', tone]);
      expect(found?.skin_variations?.[tone]).toMatchObject(variation);
    },
  );
});
