import { useEffect, useState } from 'react';

import type { ExtraCustomEmojiMap } from '../features/emoji/types';
import { emojiLogger } from '../features/emoji/utils';

let emojis: ExtraCustomEmojiMap | null = null;

const log = emojiLogger('useCustomEmojis');

export function useCustomEmojis() {
  const [, setLoaded] = useState(emojis !== null);
  useEffect(() => {
    if (!emojis) {
      void loadEmojisIntoCache().then(() => {
        setLoaded(true);
      });
    }
  }, []);

  return emojis;
}

export async function loadEmojisIntoCache() {
  const { loadAllCustomEmoji } = await import('../features/emoji/database');
  const emojisRaw = await loadAllCustomEmoji();
  if (emojisRaw === null) {
    log('Custom emojis not loaded yet');
    return;
  }

  emojis = {};
  for (const emoji of emojisRaw) {
    emojis[emoji.shortcode] = {
      url: emoji.url,
      shortcode: emoji.shortcode,
      static_url: emoji.static_url,
    };
  }
  log('Loaded %d custom emojis into cache', Object.keys(emojis).length);
}
