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
import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';
import type { CustomEmojiData } from './types';

export async function importEmojiData(
  localeString: string,
  path?: string,
  shortcodes: boolean | string = true,
) {
  const locale = toSupportedLocale(localeString);

  // Validate the provided path.
  if (path && !/^[/a-z]*\/packs\/assets\/compact-\w+\.json$/.test(path)) {
    throw new Error('Invalid path for emoji data');
  } else {
    // Otherwise get the path if not provided.
    path ??= await localeToEmojiPath(locale);
  }

  const emojis = await fetchAndCheckEtag<CompactEmoji[]>(locale, path);
  if (!emojis) {
    return;
  }

  const shortcodesData: ShortcodesDataset[] = [];
  if (shortcodes) {
    if (
      typeof shortcodes === 'string' &&
      !/^[/a-z]*\/packs\/assets\/shortcodes\/cldr\.json$/.test(shortcodes)
    ) {
      throw new Error('Invalid path for shortcodes data');
    }
    const shortcodesPath =
      typeof shortcodes === 'string'
        ? shortcodes
        : await localeToShortcodesPath(locale);
    const shortcodesResponse = await fetchAndCheckEtag<ShortcodesDataset>(
      locale,
      shortcodesPath,
      false,
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
  await putCustomEmojiData(emojis);
  return emojis;
}

export async function importLegacyShortcodes() {
  const { default: shortcodesPath } =
    await import('emojibase-data/en/shortcodes/iamcal.json?url');
  const response = await fetch(shortcodesPath);
  if (!response.ok) {
    throw new Error(
      `Failed to fetch legacy shortcodes data: ${response.statusText}`,
    );
  }
  const shortcodesData = (await response.json()) as ShortcodesDataset;
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
  localeString: string,
  path: string,
  checkEtag = true,
): Promise<ResultType | null> {
  const locale = toSupportedLocaleOrCustom(localeString);

  // Use location.origin as this script may be loaded from a CDN domain.
  const url = new URL(path, location.origin);

  const oldEtag = checkEtag ? await loadLatestEtag(locale) : null;
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

  // Store the ETag for future requests
  const etag = response.headers.get('ETag');
  if (etag && checkEtag) {
    await putLatestEtag(etag, localeString);
  }

  return data;
}
