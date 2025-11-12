import type { GroupMessage } from 'emojibase';
import groupData from 'emojibase-data/meta/groups.json';

import type { CustomEmojiData } from '@/mastodon/features/emoji/types';

type CustomGroupMessage = Omit<GroupMessage, 'key'> & {
  key: string;
};

export const groupKeysToNumber = Object.fromEntries(
  Object.entries(groupData.groups).map(([number, key]) => [
    key,
    Number(number),
  ]),
);

export const mockCustomGroups = [
  { key: 'blobcat', message: 'Blobcat', order: 1 },
  { key: 'lgbt', message: 'LGBTQ+', order: 2 },
  { key: 'logos', message: 'Logos', order: 3 },
] satisfies CustomGroupMessage[];

export const mockCustomEmojis = [
  {
    shortcode: 'blobcat_heart',
    url: 'https://pics.ishella.gay/custom_emojis/images/000/001/217/original/abede62a1fe634cf.png',
    static_url:
      'https://pics.ishella.gay/custom_emojis/images/000/001/217/static/abede62a1fe634cf.png',
    visible_in_picker: true,
    category: 'blobcat',
  },
  {
    shortcode: 'blobcat_wave',
    url: 'https://pics.ishella.gay/custom_emojis/images/000/001/250/original/f924277a36414906.png',
    static_url:
      'https://pics.ishella.gay/custom_emojis/images/000/001/250/static/f924277a36414906.png',
    visible_in_picker: true,
    category: 'blobcat',
  },
  {
    shortcode: 'mastodon',
    url: 'https://pics.ishella.gay/custom_emojis/images/000/025/993/original/56c38669cdca5d1c.png',
    static_url:
      'https://pics.ishella.gay/custom_emojis/images/000/025/993/static/56c38669cdca5d1c.png',
    visible_in_picker: true,
    category: 'mastodon',
  },
  {
    shortcode: 'fediverse',
    url: 'https://pics.ishella.gay/custom_emojis/images/000/001/198/original/b8041a4f365c4518.png',
    static_url:
      'https://pics.ishella.gay/custom_emojis/images/000/001/198/static/b8041a4f365c4518.png',
    visible_in_picker: true,
    category: 'logos',
  },
  {
    shortcode: 'ace_heart',
    url: 'https://pics.ishella.gay/custom_emojis/images/000/001/220/original/8689758e37a1bfbc.png',
    static_url:
      'https://pics.ishella.gay/custom_emojis/images/000/001/220/static/8689758e37a1bfbc.png',
    visible_in_picker: true,
    category: 'lgbt',
  },
  {
    shortcode: 'nbi_heart',
    url: 'https://pics.ishella.gay/custom_emojis/images/000/001/199/original/a06d788bce50f260.png',
    static_url:
      'https://pics.ishella.gay/custom_emojis/images/000/001/199/static/a06d788bce50f260.png',
    visible_in_picker: true,
    category: 'lgbt',
  },
] satisfies (CustomEmojiData & { category: string })[];
