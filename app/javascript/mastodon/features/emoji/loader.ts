import { flattenEmojiData } from 'emojibase';
import type { CompactEmoji, FlatCompactEmoji, Locale } from 'emojibase';

import {
  putEmojiData,
  putCustomEmojiData,
  loadLatestEtag,
  putLatestEtag,
} from './database';
import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';
import type { CustomEmojiData } from './types';

export async function importEmojiData(localeString: string, path?: string) {
  const locale = toSupportedLocale(localeString);

  // Validate the provided path.
  if (path && !/^[/a-z]*\/packs\/assets\/compact-\w+\.json$/.test(path)) {
    throw new Error('Invalid path for emoji data');
  } else {
    // Otherwise get the path if not provided.
    path ??= await localeToPath(locale);
  }

  const emojis = await fetchAndCheckEtag<CompactEmoji[]>(locale, path);
  if (!emojis) {
    return;
  }
  const flattenedEmojis: FlatCompactEmoji[] = flattenEmojiData(emojis);
  await putEmojiData(flattenedEmojis, locale);
  return flattenedEmojis;
}

export async function importCustomEmojiData() {
  const emojis = await fetchAndCheckEtag<CustomEmojiData[]>(
    'custom',
    '/api/v1/custom_emojis',
  );
  if (!emojis) {
    return;
  }
  await putCustomEmojiData(emojis);
  return emojis;
}

const modules = import.meta.glob<string>(
  '../../../../../node_modules/emojibase-data/**/compact.json',
  {
    query: '?url',
    import: 'default',
  },
);

export function localeToPath(locale: Locale) {
  const key = `../../../../../node_modules/emojibase-data/${locale}/compact.json`;
  if (!modules[key] || typeof modules[key] !== 'function') {
    throw new Error(`Unsupported locale: ${locale}`);
  }
  return modules[key]();
}

export async function fetchAndCheckEtag<ResultType extends object[]>(
  localeString: string,
  path: string,
): Promise<ResultType | null> {
  const locale = toSupportedLocaleOrCustom(localeString);

  // Use location.origin as this script may be loaded from a CDN domain.
  const url = new URL(path, location.origin);

  const oldEtag = await loadLatestEtag(locale);
  const response = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      'If-None-Match': oldEtag ?? '', // Send the old ETag to check for modifications
    },
  });
  // If not modified, return null
  if (response.status === 304) {
    return null;
  }
  if (!response.ok) {
    throw new Error(
      `Failed to fetch emoji data for ${locale}: ${response.statusText}`,
    );
  }

  const data = (await response.json()) as ResultType;
  if (!Array.isArray(data)) {
    throw new Error(`Unexpected data format for ${locale}: expected an array`);
  }

  // Store the ETag for future requests
  const etag = response.headers.get('ETag');
  if (etag) {
    await putLatestEtag(etag, localeString);
  }

  return data;
}
