import { readdir } from 'fs/promises';
import { basename, resolve } from 'path';

import { flattenEmojiData } from 'emojibase';
import unicodeRawEmojis from 'emojibase-data/en/data.json';

import { unicodeToTwemojiHex } from './normalize';

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
