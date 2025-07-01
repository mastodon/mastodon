import { readdir } from 'fs/promises';
import { basename, resolve } from 'path';

import unicodeEmojis from 'emojibase-data/en/data.json';

import { unicodeToTwemojiHex } from './normalize';

describe('normalizeEmoji', () => {
  describe('unicodeToSVGName', () => {
    test.concurrent.each(
      unicodeEmojis
        // Our version of Twemoji only supports up to version 15.1
        .filter((emoji) => emoji.version < 16)
        .map((emoji) => [emoji.hexcode, emoji.label] as [string, string]),
    )('verifying an emoji exists for %s (%s)', (hexcode) => {
      const result = unicodeToTwemojiHex(hexcode);
      expect(svgFileNames).toContain(result);
    });
  });

  let svgFileNames: string[];
  beforeAll(async () => {
    const emojiSVGFiles = await readdir(
      // This assumes tests are run from project root
      resolve(process.cwd(), 'public/emoji'),
      {
        withFileTypes: true,
      },
    );
    svgFileNames = emojiSVGFiles
      .filter(
        (file) =>
          file.isFile() &&
          file.name.endsWith('.svg') &&
          !file.name.endsWith('_border.svg'),
      )
      .map((file) => basename(file.name, '.svg').toUpperCase());
  });
});
