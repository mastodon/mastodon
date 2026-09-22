import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { loadCustomEmoji } from '@/mastodon/features/emoji';
import {
  searchCustomEmojisByShortcodes,
  clearCache,
} from '@/mastodon/features/emoji/database';
import { emojiLogger } from '@/mastodon/features/emoji/utils';

const log = emojiLogger('actions');

export async function importCustomEmoji(emojis: ApiCustomEmojiJSON[]) {
  if (emojis.length === 0) {
    return;
  }

  // First, check if we already have them all.
  const existingEmojis = await searchCustomEmojisByShortcodes(
    emojis.map((emoji) => emoji.shortcode),
  );

  // If there's a mismatch, re-import all custom emojis.
  if (existingEmojis.length > 0 && existingEmojis.length < emojis.length) {
    await clearCache('custom');
    await loadCustomEmoji();

    log('Custom emojis updated, reloaded cache and picker data.');
  }
}
