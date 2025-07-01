import { readdir } from 'fs/promises';
import { basename, resolve } from 'path';

import unicodeEmojis from 'emojibase-data/en/data.json';

import { twemojiToUnicodeInfo, unicodeToTwemojiHex } from './normalize';

const emojiSVGFiles = await readdir(
  // This assumes tests are run from project root
  resolve(process.cwd(), 'public/emoji'),
  {
    withFileTypes: true,
  },
);
const svgFileNames = emojiSVGFiles
  .filter(
    (file) =>
      file.isFile() &&
      file.name.endsWith('.svg') &&
      !file.name.endsWith('_border.svg'),
  )
  .map((file) => basename(file.name, '.svg').toUpperCase());

describe('normalizeEmoji', () => {
  describe('unicodeToSVGName', () => {
    test.concurrent.for(
      unicodeEmojis
        // Our version of Twemoji only supports up to version 15.1
        .filter((emoji) => emoji.version < 16)
        .map((emoji) => [emoji.hexcode, emoji.label] as [string, string]),
    )('verifying an emoji exists for %s (%s)', ([hexcode], { expect }) => {
      const result = unicodeToTwemojiHex(hexcode);
      expect(svgFileNames).toContain(result);
    });
  });

  describe('twemojiToUnicodeInfo', () => {
    const unicodeMap = new Map(
      unicodeEmojis.flatMap((emoji) => {
        const base: [string, string][] = [[emoji.hexcode, emoji.label]];
        if (emoji.skins) {
          base.push(
            ...emoji.skins.map(
              (skin) => [skin.hexcode, skin.label] as [string, string],
            ),
          );
        }
        return base;
      }),
    );

    test.concurrent.for(svgFileNames)(
      'verifying SVG file %s maps to Unicode emoji',
      (svgFileName, { expect }) => {
        assert(!!svgFileName);
        const result = twemojiToUnicodeInfo(svgFileName);
        const hexcode =
          typeof result === 'string' ? result : result.unqualified;
        if (!hexcode) {
          // No hexcode means this is a special case like the Shibuya 109 emoji
          expect(result).toHaveProperty('label');
          return;
        }
        assert(!!hexcode);
        expect(
          unicodeMap.has(hexcode),
          `${hexcode} (${svgFileName}) not found`,
        ).toBeTruthy();
      },
    );
  });
});
