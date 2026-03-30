import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { loadCustomEmoji } from '@/mastodon/features/emoji';

export async function importCustomEmoji(emojis: ApiCustomEmojiJSON[]) {
  if (emojis.length === 0) {
    return;
  }

  // First, check if we already have them all.
  const { searchCustomEmojisByShortcodes, clearCache } =
    await import('@/mastodon/features/emoji/database');

  const existingEmojis = await searchCustomEmojisByShortcodes(
    emojis.map((emoji) => emoji.shortcode),
  );

  // If there's a mismatch, re-import all custom emojis.
  if (existingEmojis.length < emojis.length) {
    await clearCache('custom');
    await loadCustomEmoji();
  }
}
