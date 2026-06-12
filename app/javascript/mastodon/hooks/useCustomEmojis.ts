import { createAppSelector, useAppSelector } from '@/mastodon/store';

import type { ExtraCustomEmojiMap } from '../features/emoji/types';

const selectCustomEmojis = createAppSelector(
  [(state) => state.emojis.custom],
  (custom) => {
    const emojis: ExtraCustomEmojiMap = {};
    for (const shortcode in custom) {
      const emoji = custom[shortcode];
      if (!emoji) {
        continue;
      }
      emojis[shortcode] = {
        shortcode,
        ...emoji,
      };
    }
    return emojis;
  },
);

export function useCustomEmojis() {
  return useAppSelector(selectCustomEmojis);
}
