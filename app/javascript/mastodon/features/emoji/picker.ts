import type { CategoryName, CustomEmoji } from 'emoji-mart';

import { autoPlayGif } from '@/mastodon/initial_state';
import {
  createAppSelector,
  useAppSelector,
} from '@/mastodon/store/typed_functions';
import { createLimitedCache } from '@/mastodon/utils/cache';

import { emojiLogger } from './utils';

const log = emojiLogger('picker');

const searchCache = createLimitedCache<LegacyEmoji[]>({ maxSize: 10, log });

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
  const query = token.replace(':', '').trim();
  if (!query.length) {
    return [];
  }

  const cacheKey = `${query}|${locale}|${limit}`;
  const cachedResult = searchCache.get(cacheKey);
  if (cachedResult) {
    return cachedResult;
  }

  const { search } = await import('./database');
  const results = await search({ query, locale, limit });
  const legacyResults = results.map((emoji) =>
    'shortcode' in emoji
      ? ({ id: emoji.shortcode, custom: true } as const)
      : {
          id: emoji.label.replaceAll(' ', '_').toLowerCase(),
          native: emoji.unicode,
        },
  );
  searchCache.set(cacheKey, legacyResults);

  return legacyResults;
}

const defaultCategories = [
  'people',
  'nature',
  'foods',
  'activity',
  'places',
  'objects',
  'symbols',
  'flags',
] as CategoryName[];

const selectPickerData = createAppSelector(
  [(state) => state.emojis.custom, (state) => state.emojis.customCategories],
  (emojis, categories) => {
    // Create a map of shortcode to category name.
    const categoryMap = new Map<string, string>();
    for (const category in categories) {
      const catEmojis = categories[category];
      if (!catEmojis?.length) {
        continue;
      }
      for (const shortcode of catEmojis) {
        categoryMap.set(shortcode, category);
      }
    }

    const customEmojis: CustomEmoji[] = [];
    for (const shortcode in emojis) {
      const emoji = emojis[shortcode];
      if (!emoji) {
        continue;
      }

      customEmojis.push({
        name: shortcode,
        id: shortcode,
        custom: true,
        short_names: [shortcode],
        imageUrl: autoPlayGif ? emoji.url : emoji.static_url,
        customCategory: categoryMap.get(shortcode),
      } as CustomEmoji);
    }

    searchCache.clear();
    log('regenerated the picker data');

    return {
      emojis: customEmojis,
      categories: [
        'recent',
        'custom',
        ...Object.keys(categories)
          .toSorted()
          .map((category) => `custom-${category}`),
        ...defaultCategories,
      ] as CategoryName[],
    };
  },
);

export function usePickerEmojis() {
  return useAppSelector(selectPickerData);
}
