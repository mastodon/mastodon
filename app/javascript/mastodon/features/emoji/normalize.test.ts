import { readdir } from 'fs/promises';
import { basename, resolve } from 'path';

import { flattenEmojiData } from 'emojibase';
import unicodeRawEmojis from 'emojibase-data/en/data.json';

import {
  twemojiToUnicodeInfo,
  unicodeToTwemojiHex,
  emojiToUnicodeHex,
} from './normalize';

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

describe('emojiToUnicodeHex', () => {
  test.concurrent.for([
    ['🎱', '1F3B1'],
    ['🐜', '1F41C'],
    ['⚫', '26AB'],
    ['🖤', '1F5A4'],
    ['💀', '1F480'],
    ['💂‍♂️', '1F482-200D-2642-FE0F'],
  ] as const)(
    'emojiToUnicodeHex converts %s to %s',
    ([emoji, hexcode], { expect }) => {
      expect(emojiToUnicodeHex(emoji)).toBe(hexcode);
    },
  );
});

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

describe('twemojiToUnicodeInfo', () => {
  const unicodeCodeSet = new Set(unicodeEmojis.map((emoji) => emoji.hexcode));

  test.concurrent.for(svgFileNamesWithoutBorder)(
    'verifying SVG file %s maps to Unicode emoji',
    (svgFileName, { expect }) => {
      assert(!!svgFileName);
      const result = twemojiToUnicodeInfo(svgFileName);
      const hexcode = typeof result === 'string' ? result : result.unqualified;
      if (!hexcode) {
        // No hexcode means this is a special case like the Shibuya 109 emoji
        expect(result).toHaveProperty('label');
        return;
      }
      assert(!!hexcode);
      expect(
        unicodeCodeSet.has(hexcode),
        `${hexcode} (${svgFileName}) not found`,
      ).toBeTruthy();
    },
  );
});
