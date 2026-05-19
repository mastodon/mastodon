import { useEffect, useState } from 'react';

import type { CategoryName, CustomEmoji } from 'emoji-mart';

import { autoPlayGif } from '@/mastodon/initial_state';

import { emojiLogger } from './utils';

const log = emojiLogger('picker');

let customEmojis: CustomEmoji[] | null = null;
let customCategories = [
  'recent',
  'people',
  'nature',
  'foods',
  'activity',
  'places',
  'objects',
  'symbols',
  'flags',
] as CategoryName[];

export async function fetchCustomEmojiData() {
  if (customEmojis !== null) {
    return customEmojis;
  }

  const { loadAllCustomEmoji } = await import('./database');
  const emojisRaw = await loadAllCustomEmoji();

  // If it returns null then custom emojis aren't even loaded yet.
  if (emojisRaw === null) {
    return [];
  }

  // If it's empty, then they are loaded but there aren't any.
  if (emojisRaw.length === 0) {
    customEmojis = [];
    return customEmojis;
  }

  const categories = new Set(['custom']);
  const emojis = [];
  for (const emoji of emojisRaw) {
    const name = emoji.shortcode.replaceAll(':', '');
    emojis.push({
      name,
      id: name,
      custom: true,
      short_names: [name],
      imageUrl: autoPlayGif ? emoji.url : emoji.static_url,
      customCategory: emoji.category,
    });

    if (emoji.category) {
      categories.add(`custom-${emoji.category}`);
    }
  }

  customEmojis = emojis.toSorted((a, b) => {
    return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
  });
  customCategories = customCategories.toSpliced(
    1,
    0,
    ...(Array.from(categories).toSorted() as CategoryName[]),
  );
  log(
    'loaded %d custom emojis in %d categories',
    customEmojis.length,
    categories.size,
  );

  return customEmojis;
}

type LegacyEmoji =
  | { id: string; custom?: false; native: string }
  | {
      id: string;
      custom: true;
    };

// Replicates the old legacy search function.
export async function emojiMartSearch(
  token: string,
  locale: string,
  limit = 5,
): Promise<LegacyEmoji[]> {
  const query = token.replace(':', '').toLowerCase().trim();
  if (!query.length) {
    return [];
  }

  const { search } = await import('./database');
  const results = await search({ query, locale, limit });
  return results.map((emoji) =>
    'shortcode' in emoji
      ? { id: emoji.shortcode, custom: true }
      : {
          id: emoji.label.replaceAll(' ', '_').toLowerCase(),
          native: emoji.unicode,
        },
  );
}

export function usePickerEmojis() {
  const [, setLoaded] = useState(customEmojis !== null);

  useEffect(() => {
    if (customEmojis === null) {
      void fetchCustomEmojiData().then(() => {
        setLoaded(true);
      });
    }
  }, []);

  return {
    customEmojis,
    customCategories,
  };
}
