import { useEffect } from 'react';

import { loadAllCustomEmoji } from '../features/emoji/database';
import type { ExtraCustomEmojiMap } from '../features/emoji/types';

let emojis: ExtraCustomEmojiMap | null = null;

export function useCustomEmojis() {
  useEffect(() => {
    if (!emojis) {
      void loadAllCustomEmoji().then((data) => {
        emojis = {};
        for (const emoji of data) {
          emojis[emoji.shortcode] = emoji;
        }
      });
    }
  }, []);

  return emojis;
}
