/* eslint-disable no-console */
import { writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';

import twemojiData from './emoji_data.json';

async function main() {
  const mapped: Record<string, [string, number, number]> = {};
  for (const [code, emoji] of Object.entries(twemojiData.emojis)) {
    const [x, y] = emoji.k;
    if (typeof x === 'number' && typeof y === 'number') {
      mapped[emoji.b] = [code, x, y];
    } else {
      console.warn('No sheet position for emoji %s (%s)', code, emoji.a);
    }

    if ('skin_variations' in emoji) {
      for (const [code, skinEmoji] of Object.entries(emoji.skin_variations)) {
        mapped[skinEmoji.unified] = [
          code,
          skinEmoji.sheet_x,
          skinEmoji.sheet_y,
        ];
      }
    }
  }
  await writeFile(
    resolve(__dirname, 'twemoji_map.json'),
    JSON.stringify(mapped, null, '\t'),
  );
}

main()
  .then(() => {
    console.log('Done!');
    process.exit();
  })
  .catch((err: unknown) => {
    console.error('Error:', err);
    process.exit(1);
  });
