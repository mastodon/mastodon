import type { AnyEmojiData } from '@/mastodon/features/emoji/types';

export function emojiToKey(emoji: AnyEmojiData, hexcode = true): string {
  if ('shortcode' in emoji) {
    return `:${emoji.shortcode}:`;
  }
  return hexcode ? emoji.hexcode : emoji.unicode;
}
