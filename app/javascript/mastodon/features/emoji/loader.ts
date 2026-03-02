import { joinShortcodes } from 'emojibase';
import type { CompactEmoji, Locale, ShortcodesDataset } from 'emojibase';

import {
  putEmojiData,
  putCustomEmojiData,
  putCacheValue,
  putLegacyShortcodes,
  loadCacheValue,
} from './database';
import { toSupportedLocale, toValidCacheKey } from './locale';
import type { CustomEmojiData } from './types';
import { emojiLogger } from './utils';

const log = emojiLogger('loader');

export async function importEmojiData(localeString: string, shortcodes = true) {
  const locale = toSupportedLocale(localeString);

  log(
    'importing emoji data for locale %s%s',
    locale,
    shortcodes ? ' and shortcodes' : '',
  );

  let emojis = await fetchIfNotLoaded<CompactEmoji[]>({
    key: locale,
    path: localeToEmojiPath(locale),
  });
  if (!emojis) {
    return;
  }

  const shortcodesData: ShortcodesDataset[] = [];
  if (shortcodes) {
    const shortcodesResponse = await fetchIfNotLoaded<ShortcodesDataset>({
      key: `${locale}-shortcodes`,
      path: localeToShortcodesPath(locale),
    });
    if (shortcodesResponse) {
      shortcodesData.push(shortcodesResponse);
    } else {
      throw new Error(`No shortcodes data found for locale ${locale}`);
    }
  }

  emojis = joinShortcodes(emojis, shortcodesData);

  await putEmojiData(emojis, locale);
  return emojis;
}

export async function importCustomEmojiData() {
  const response = await fetchAndCheckEtag({
    oldEtag: await loadCacheValue('custom'),
    path: '/api/v1/custom_emojis',
  });

  if (!response) {
    return;
  }

  const etag = response.headers.get('ETag');
  if (etag) {
    log('Custom emoji data fetched successfully, storing etag %s', etag);
    await putCacheValue('custom', etag);
  } else {
    log('No etag found in response for custom emoji data');
  }

  const emojis = (await response.json()) as CustomEmojiData[];
  await putCustomEmojiData({ emojis, clear: true });
  return emojis;
}

export async function importLegacyShortcodes() {
  const globPaths = import.meta.glob<string>(
    // We use import.meta.glob to eagerly load the URL, as the regular import() doesn't work inside the Web Worker.
    '../../../../../node_modules/emojibase-data/en/shortcodes/iamcal.json',
    { eager: true, import: 'default', query: '?url' },
  );
  const path = Object.values(globPaths)[0];
  if (!path) {
    throw new Error('IAMCAL shortcodes path not found');
  }
  const shortcodesData = await fetchIfNotLoaded<ShortcodesDataset>({
    key: 'shortcodes',
    path,
  });
  if (!shortcodesData) {
    return;
  }
  await putLegacyShortcodes(shortcodesData);
  return Object.keys(shortcodesData);
}

function localeToEmojiPath(locale: Locale) {
  const key = `../../../../../node_modules/emojibase-data/${locale}/compact.json`;
  const emojiModules = import.meta.glob<string>(
    '../../../../../node_modules/emojibase-data/**/compact.json',
    {
      query: '?url',
      import: 'default',
      eager: true,
    },
  );
  const path = emojiModules[key];
  if (!path) {
    throw new Error(`Unsupported locale: ${locale}`);
  }
  return path;
}

function localeToShortcodesPath(locale: Locale) {
  const key = `../../../../../node_modules/emojibase-data/${locale}/shortcodes/cldr.json`;
  const shortcodesModules = import.meta.glob<string>(
    '../../../../../node_modules/emojibase-data/**/shortcodes/cldr.json',
    {
      query: '?url',
      import: 'default',
      eager: true,
    },
  );
  const path = shortcodesModules[key];
  if (!path) {
    throw new Error(`Unsupported locale for shortcodes: ${locale}`);
  }
  return path;
}

async function fetchIfNotLoaded<ResultType extends object[] | object>({
  key: rawKey,
  path,
}: {
  key: string;
  path: string;
}): Promise<ResultType | null> {
  const key = toValidCacheKey(rawKey);

  const value = await loadCacheValue(key);

  if (value === path) {
    log('data for %s already loaded, skipping fetch', key);
    return null;
  }

  const response = await fetchAndCheckEtag({ path });
  if (!response) {
    return null;
  }

  log('data for %s fetched successfully, storing etag', key);
  await putCacheValue(key, path);

  return (await response.json()) as ResultType;
}

async function fetchAndCheckEtag({
  oldEtag,
  path,
}: {
  oldEtag?: string;
  path: string;
}) {
  const headers = new Headers({
    'Content-Type': 'application/json',
  });
  if (oldEtag) {
    headers.set('If-None-Match', oldEtag);
  }

  // Use location.origin as this script may be loaded from a CDN domain.
  const url = new URL(path, location.origin);
  const response = await fetch(url, {
    headers,
  });

  // If not modified, return null
  if (response.status === 304) {
    log('etag not modified for %s', path);
    return null;
  }

  if (!response.ok) {
    throw new Error(
      `Failed to fetch emoji data for ${path}: ${response.statusText}`,
    );
  }

  return response;
}
