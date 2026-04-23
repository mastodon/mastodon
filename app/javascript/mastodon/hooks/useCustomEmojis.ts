import { useEffect, useState } from 'react';

import type { ExtraCustomEmojiMap } from '../features/emoji/types';

let emojis: ExtraCustomEmojiMap | null = null;

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

async function loadEmojisIntoCache() {
  const { loadAllCustomEmoji } = await import('../features/emoji/database');
  const emojisRaw = await loadAllCustomEmoji();
  if (emojisRaw.length === 0) {
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
}
