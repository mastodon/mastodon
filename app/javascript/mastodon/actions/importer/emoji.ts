import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

export async function importCustomEmoji(emojis: ApiCustomEmojiJSON[]) {
  const onlyLocalEmojis = emojis.filter(
    // Remote emojis won't have this field, but we still want it for rendering old emojis.
    (emoji) => 'visible_in_picker' in emoji,
  );
  if (onlyLocalEmojis.length === 0) {
    return;
  }

  const { putCustomEmojiData } =
    await import('@/mastodon/features/emoji/database');
  await putCustomEmojiData(onlyLocalEmojis);
}
