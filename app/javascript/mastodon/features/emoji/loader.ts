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

export async function importEmojiData(
  localeString: string,
  path?: string,
  shortcodes: boolean | string = true,
) {
  const locale = toSupportedLocale(localeString);

  path ??= await localeToEmojiPath(locale);

  const emojis = await fetchAndCheckEtag<CompactEmoji[]>(locale, path);
  if (!emojis) {
    return;
  }

  const shortcodesData: ShortcodesDataset[] = [];
  if (typeof shortcodes === 'string') {
    const shortcodesPath =
      typeof shortcodes === 'string'
        ? shortcodes
        : await localeToShortcodesPath(locale);
    const shortcodesResponse = await fetchAndCheckEtag<ShortcodesDataset>(
      `${locale}-shortcodes`,
      shortcodesPath,
    );
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
  const emojis = await fetchAndCheckEtag<CustomEmojiData[]>(
    'custom',
    '/api/v1/custom_emojis',
  );
  if (!emojis) {
    return;
  }
  await putCustomEmojiData({ emojis, clear: true });
  return emojis;
}

export async function importLegacyShortcodes() {
  const { default: shortcodesPath } =
    await import('emojibase-data/en/shortcodes/iamcal.json?url');
  const shortcodesData = await fetchAndCheckEtag<ShortcodesDataset>(
    'shortcodes',
    shortcodesPath,
  );
  if (!shortcodesData) {
    return;
  }
  await putLegacyShortcodes(shortcodesData);
  return Object.keys(shortcodesData);
}

const emojiModules = new Map(
  Object.entries(
    import.meta.glob<string>(
      '../../../../../node_modules/emojibase-data/**/compact.json',
      {
        query: '?url',
        import: 'default',
      },
    ),
  ).map(([key, loader]) => {
    const match = /emojibase-data\/([^/]+)\/compact\.json$/.exec(key);
    return [match?.at(1) ?? key, loader];
  }),
);

export function localeToEmojiPath(locale: Locale) {
  const path = emojiModules.get(locale);
  if (!path) {
    throw new Error(`Unsupported locale: ${locale}`);
  }
  return path();
}

const shortcodesModules = new Map(
  Object.entries(
    import.meta.glob<string>(
      '../../../../../node_modules/emojibase-data/**/shortcodes/cldr.json',
      {
        query: '?url',
        import: 'default',
      },
    ),
  ).map(([key, loader]) => {
    const match = /emojibase-data\/([^/]+)\/shortcodes\/cldr\.json$/.exec(key);
    return [match?.at(1) ?? key, loader];
  }),
);

export function localeToShortcodesPath(locale: Locale) {
  const path = shortcodesModules.get(locale);
  if (!path) {
    throw new Error(`Unsupported locale for shortcodes: ${locale}`);
  }
  return path();
}

export async function fetchAndCheckEtag<ResultType extends object[] | object>(
  etagString: string,
  path: string,
  checkEtag = true,
): Promise<ResultType | null> {
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
    await putLatestEtag(etag, etagName);
  }

  return data;
}
