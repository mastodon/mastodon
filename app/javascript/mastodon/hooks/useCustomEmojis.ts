import { useEffect } from 'react';

import { loadAllCustomEmoji } from '../features/emoji/database';
import { cleanExtraEmojis } from '../features/emoji/normalize';
import type { ExtraCustomEmojiMap } from '../features/emoji/types';

let emojis: ExtraCustomEmojiMap | null = null;

export function useCustomEmojis() {
  useEffect(() => {
    if (!emojis) {
      void loadAllCustomEmoji().then((data) => {
        const emojiMap = cleanExtraEmojis(data);
        if (emojiMap) {
          emojis = emojiMap;
        }
      });
    }
  }, []);

  return emojis;
}
