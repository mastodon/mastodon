import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { loadCustomEmoji } from '@/mastodon/features/emoji';

export async function importCustomEmoji(emojis: ApiCustomEmojiJSON[]) {
  const onlyLocalEmojis = emojis.filter(
    // Remote emojis won't have this field.
    (emoji) => 'visible_in_picker' in emoji,
  );
  if (onlyLocalEmojis.length === 0) {
    return;
  }

  // First, check if we already have them all.
  const { searchCustomEmojisByShortcodes, clearEtag } =
    await import('@/mastodon/features/emoji/database');
  const existingEmojis = await searchCustomEmojisByShortcodes(
    onlyLocalEmojis.map((emoji) => emoji.shortcode),
  );

  // If there's a mismatch, re-import all custom emojis.
  if (existingEmojis.length < onlyLocalEmojis.length) {
    await clearEtag('custom');
    await loadCustomEmoji();
  }
}
