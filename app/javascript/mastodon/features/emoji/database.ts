import { SUPPORTED_LOCALES } from 'emojibase';
import type { CompactEmoji, Locale, ShortcodesDataset } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { onceAsync } from '@/mastodon/utils/promises';

import { openEmojiDB } from './db-schema';
import type { Database } from './db-schema';
import { importEmojiData } from './loader';
import { localeToSegmenter, toSupportedLocale } from './locale';
import {
  skinHexcodeToEmoji,
  transformCustomEmojiData,
  transformEmojiData,
} from './normalize';
import type { CacheKey } from './types';
import { emojiLogger } from './utils';

const loadedLocales = new Set<Locale>();

const log = emojiLogger('database');

// Loads the database in a way that ensures it's only loaded once.
const loadDB = (() => {
  // Actually load the DB.
  async function initDB() {
    const db = await openEmojiDB();
    await syncLocales(db);
    log('Loaded database version %d', db.version);
    return db;
  }

  let dbPromise = onceAsync(initDB);

  // Loads the database, or returns the existing promise if it hasn't resolved yet.
  const loadPromise = () => dbPromise();

  // Special way to reset the database, used for unit testing.
  loadPromise.reset = () => {
    dbPromise = onceAsync(initDB);
  };
  return loadPromise;
})();

export async function rawSearch(query: string, locale: Locale, prefix = true) {
  await toLoadedLocale(locale);
  const db = await loadDB();
  const range = prefix
    ? IDBKeyRange.lowerBound(query)
    : IDBKeyRange.only(query);
  const [unicodeResults, customResults, shortcodeResults] = await Promise.all([
    db.getAllFromIndex(locale, 'tokens', range),
    db.getAllFromIndex('custom', 'tokens', range),
    db.getAllFromIndex('shortcodes', 'shortcodes', range),
  ]);
  return {
    unicodeResults,
    customResults,
    shortcodeResults,
  };
}

export async function putEmojiData(emojis: CompactEmoji[], locale: Locale) {
  loadedLocales.add(locale);
  const db = await loadDB();
  const trx = db.transaction(locale, 'readwrite');
  await trx.store.clear();
  const segmenter = localeToSegmenter(locale);
  await Promise.all(
    emojis
      .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
      .map((emoji) => trx.store.put(transformEmojiData(emoji, segmenter))),
  );
  await trx.done;
}

export async function putCustomEmojiData({
  emojis,
  clear = false,
}: {
  emojis: ApiCustomEmojiJSON[];
  clear?: boolean;
}) {
  const db = await loadDB();
  const trx = db.transaction('custom', 'readwrite');

  // When importing from the API, clear everything first.
  if (clear) {
    await trx.store.clear();
    log('Cleared existing custom emojis in database');
  }

  await Promise.all(
    emojis.map((emoji) => trx.store.put(transformCustomEmojiData(emoji))),
  );
  await trx.done;

  log('Imported %d custom emojis into database', emojis.length);
}

export async function putLegacyShortcodes(shortcodes: ShortcodesDataset) {
  const db = await loadDB();
  const trx = db.transaction('shortcodes', 'readwrite');
  await Promise.all(
    Object.entries(shortcodes).map(([hexcode, codes]) =>
      trx.store.put({
        hexcode,
        shortcodes: Array.isArray(codes) ? codes : [codes],
      }),
    ),
  );
  await trx.done;
}

export async function loadCacheValue(key: CacheKey) {
  const db = await loadDB();
  const value = await db.get('etags', key);
  return value;
}

export async function putCacheValue(key: CacheKey, value: string) {
  const db = await loadDB();
  await db.put('etags', value, key);
}

export async function clearCache(key: CacheKey) {
  const db = await loadDB();
  await db.delete('etags', key);
  log('Cleared cache for %s', key);
}

export async function loadEmojiByHexcode(
  hexcode: string,
  localeString: string,
) {
  const db = await loadDB();
  const locale = await toLoadedLocale(localeString);
  const result = await db.get(locale, hexcode);
  if (result) {
    return result;
  }

  // If the emoji wasn't found, check if it's a skin tone variant.
  const skinResult = await db.getFromIndex(
    locale,
    'skinHexcodes',
    IDBKeyRange.only(hexcode),
  );

  if (!skinResult) {
    return skinResult;
  }

  // Reconstruct the full unicode string from the skin tone hexcode.
  return skinHexcodeToEmoji(hexcode, skinResult);
}

export async function loadAllUnicodeEmojis(localeString: string) {
  const locale = await toLoadedLocale(localeString);
  const db = await loadDB();
  return db.getAll(locale);
}

export async function loadCustomEmojiByShortcode(shortcode: string) {
  const db = await loadDB();
  return db.get('custom', shortcode);
}

export async function searchCustomEmojisByShortcodes(shortcodes: string[]) {
  if (shortcodes.length === 0) {
    return [];
  }
  const db = await loadDB();
  const sortedCodes = shortcodes.toSorted();
  const results = await db.getAll(
    'custom',
    IDBKeyRange.bound(sortedCodes.at(0), sortedCodes.at(-1)),
  );
  return results.filter((emoji) => shortcodes.includes(emoji.shortcode));
}

export async function loadCustomEmojiKeys(
  query?: string | null,
  chunkSize = 1_000,
) {
  const db = await loadDB();
  const keyRange = query ? IDBKeyRange.lowerBound(query, true) : null;
  return db.getAllKeys('custom', keyRange, chunkSize);
}

export async function loadAllCustomEmoji() {
  const db = await loadDB();
  const cacheValue = await db.get('etags', 'custom');
  if (!cacheValue) {
    return null;
  }
  return db.getAll('custom');
}

export async function loadLegacyShortcodesByShortcode(shortcode: string) {
  const db = await loadDB();
  return db.getFromIndex(
    'shortcodes',
    'shortcodes',
    IDBKeyRange.only(shortcode),
  );
}

export async function loadAllShortcodes() {
  const db = await loadDB();
  return db.getAll('shortcodes');
}

// Private functions

async function syncLocales(db: Database) {
  const locales = await Promise.all(
    SUPPORTED_LOCALES.map(
      async (locale) =>
        [locale, await hasLocale(locale, db)] satisfies [Locale, boolean],
    ),
  );
  for (const [locale, loaded] of locales) {
    if (loaded) {
      loadedLocales.add(locale);
    } else {
      loadedLocales.delete(locale);
    }
  }
  log('Loaded %d locales: %o', loadedLocales.size, loadedLocales);
}

async function toLoadedLocale(localeString: string) {
  const locale = toSupportedLocale(localeString);
  if (localeString !== locale) {
    log(`Locale ${locale} is different from provided ${localeString}`);
  }
  if (!loadedLocales.has(locale)) {
    log('Locale %s not loaded, importing...', locale);
    await importEmojiData(locale);
    return locale;
  }
  return locale;
}

export class LocaleNotLoadedError extends Error {
  constructor(locale: Locale) {
    super(`Locale ${locale} is not loaded in emoji database`);
    this.name = 'LocaleNotLoadedError';
  }
}

async function hasLocale(locale: Locale, db: Database): Promise<boolean> {
  if (loadedLocales.has(locale)) {
    return true;
  }
  const rowCount = await db.count(locale);
  return !!rowCount;
}

// Testing helpers
export async function testGet() {
  const db = await loadDB();
  return { db, loadedLocales };
}
export function testClear() {
  loadedLocales.clear();
  loadDB.reset();
}
