import { flattenEmojiData } from 'emojibase';
import type {
  CompactEmoji,
  FlatCompactEmoji,
  Locale,
  ShortcodesDataset,
} from 'emojibase';

import {
  putEmojiData,
  putCustomEmojiData,
  loadLatestEtag,
  putLatestEtag,
  putLegacyShortcodes,
} from './database';
import { toSupportedLocale, toValidEtagName } from './locale';
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

  const emojis = await fetchAndCheckEtag<CompactEmoji[]>({
    etagString: locale,
    path: localeToEmojiPath(locale),
  });
  if (!emojis) {
    return;
  }

  const shortcodesData: ShortcodesDataset[] = [];
  if (shortcodes) {
    const shortcodesResponse = await fetchAndCheckEtag<ShortcodesDataset>({
      etagString: `${locale}-shortcodes`,
      path: localeToShortcodesPath(locale),
    });
    if (shortcodesResponse) {
      shortcodesData.push(shortcodesResponse);
    } else {
      throw new Error(`No shortcodes data found for locale ${locale}`);
    }
  }

  const flattenedEmojis: FlatCompactEmoji[] = flattenEmojiData(
    emojis,
    shortcodesData,
  );
  await putEmojiData(flattenedEmojis, locale);
  return flattenedEmojis;
}

export async function importCustomEmojiData() {
  const emojis = await fetchAndCheckEtag<CustomEmojiData[]>({
    etagString: 'custom',
    path: '/api/v1/custom_emojis',
  });
  if (!emojis) {
    return;
  }
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
  const shortcodesData = await fetchAndCheckEtag<ShortcodesDataset>({
    checkEtag: true,
    etagString: 'shortcodes',
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

async function fetchAndCheckEtag<ResultType extends object[] | object>({
  etagString,
  path,
  checkEtag = false,
}: {
  etagString: string;
  path: string;
  checkEtag?: boolean;
}): Promise<ResultType | null> {
  const etagName = toValidEtagName(etagString);

  // Use location.origin as this script may be loaded from a CDN domain.
  const url = new URL(path, location.origin);

  const oldEtag = checkEtag ? await loadLatestEtag(etagName) : null;
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
      `Failed to fetch emoji data for ${etagName}: ${response.statusText}`,
    );
  }

  const data = (await response.json()) as ResultType;

  // Store the ETag for future requests
  const etag = response.headers.get('ETag');
  if (etag && checkEtag) {
    log(`storing new etag for ${etagName}: ${etag}`);
    await putLatestEtag(etag, etagName);
  }

  return data;
}
