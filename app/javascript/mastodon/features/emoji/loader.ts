import { flattenEmojiData } from 'emojibase';
import type { CompactEmoji, FlatCompactEmoji } from 'emojibase';

import {
  putEmojiData,
  putCustomEmojiData,
  loadLatestEtag,
  putLatestEtag,
} from './database';
import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';
import type { CustomEmojiData, LocaleOrCustom } from './types';
import { emojiLogger } from './utils';

const log = emojiLogger('loader');

export async function importEmojiData(localeString: string) {
  const locale = toSupportedLocale(localeString);
  const emojis = await fetchAndCheckEtag<CompactEmoji[]>(locale);
  if (!emojis) {
    return;
  }
  const flattenedEmojis: FlatCompactEmoji[] = flattenEmojiData(emojis);
  log('loaded %d for %s locale', flattenedEmojis.length, locale);
  await putEmojiData(flattenedEmojis, locale);
}

export async function importCustomEmojiData() {
  const emojis = await fetchAndCheckEtag<CustomEmojiData[]>('custom');
  if (!emojis) {
    return;
  }
  log('loaded %d custom emojis', emojis.length);
  await putCustomEmojiData(emojis);
}

async function fetchAndCheckEtag<ResultType extends object[]>(
  localeOrCustom: LocaleOrCustom,
): Promise<ResultType | null> {
  const locale = toSupportedLocaleOrCustom(localeOrCustom);

  // Use location.origin as this script may be loaded from a CDN domain.
  const url = new URL(location.origin);
  if (locale === 'custom') {
    url.pathname = '/api/v1/custom_emojis';
  } else {
    // This doesn't use isDevelopment() as that module loads initial state
    // which breaks workers, as they cannot access the DOM.
    url.pathname = `/packs${import.meta.env.DEV ? '-dev' : ''}/emoji/${locale}.json`;
  }

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
      `Failed to fetch emoji data for ${localeOrCustom}: ${response.statusText}`,
    );
  }

  const data = (await response.json()) as ResultType;
  if (!Array.isArray(data)) {
    throw new Error(
      `Unexpected data format for ${localeOrCustom}: expected an array`,
    );
  }

  // Store the ETag for future requests
  const etag = response.headers.get('ETag');
  if (etag) {
    await putLatestEtag(etag, localeOrCustom);
  }

  return data;
}
