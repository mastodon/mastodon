import { SUPPORTED_LOCALES } from 'emojibase';
import type { CompactEmoji, Locale, ShortcodesDataset } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import { openEmojiDB } from './db-schema';
import type { Database } from './db-schema';
import { localeToSegmenter, toSupportedLocale } from './locale';
import {
  extractTokens,
  skinHexcodeToEmoji,
  transformCustomEmojiData,
  transformEmojiData,
} from './normalize';
import type { AnyEmojiData, CacheKey } from './types';
import { emojiLogger } from './utils';

const loadedLocales = new Set<Locale>();

const log = emojiLogger('database');

// Loads the database in a way that ensures it's only loaded once.
const loadDB = (() => {
  let dbPromise: Promise<Database> | null = null;

  // Actually load the DB.
  async function initDB() {
    const db = await openEmojiDB();
    await syncLocales(db);
    log('Loaded database version %d', db.version);
    return db;
  }

  // Loads the database, or returns the existing promise if it hasn't resolved yet.
  const loadPromise = async (): Promise<Database> => {
    if (dbPromise) {
      return dbPromise;
    }
    dbPromise = initDB();
    return dbPromise;
  };
  // Special way to reset the database, used for unit testing.
  loadPromise.reset = () => {
    dbPromise = null;
  };
  return loadPromise;
})();

export async function search({
  query,
  locale: localeString,
  limit = 0,
}: {
  query: string;
  locale: string;
  limit?: number;
}) {
  performance.mark('emoji-search-start');

  // Get the locale, and extract tokens from the query.
  const locale = await toLoadedLocale(localeString);
  const segmenter = localeToSegmenter(locale);
  const queryTokens = extractTokens(query, segmenter);

  if (queryTokens.length === 0) {
    log('no tokens extracted from query "%s"', query);
    return [];
  }
  const lastToken = queryTokens.at(-1);
  if (!lastToken) {
    throw new Error('Missing tokens from query');
  }

  log('searching for tokens %o in locale %s', queryTokens, locale);

  // Create an array of emoji results
  const db = await loadDB();
  const resultArrays: Map<string, AnyEmojiData>[] = [];
  for (let i = 0; i < queryTokens.length; i++) {
    const token = queryTokens[i];
    if (!token) continue;

    // Only query the range for the last token to allow partial matches.
    const range =
      i === queryTokens.length - 1
        ? IDBKeyRange.bound(token, token + '\uffff')
        : IDBKeyRange.only(token);

    const [unicodeResults, customResults] = await Promise.all([
      db.getAllFromIndex(locale, 'tokens', range),
      db.getAllFromIndex('custom', 'tokens', range),
    ]);
    const resultMap = new Map<string, AnyEmojiData>([
      ...unicodeResults.map(
        (emoji) => [emoji.hexcode, emoji] as [string, AnyEmojiData],
      ),
      ...customResults.map(
        (emoji) => [emoji.shortcode, emoji] as [string, AnyEmojiData],
      ),
    ]);
    log('found %d results for token "%s"', resultMap.size, token);
    resultArrays.push(resultMap);
  }

  // Utilize maps to find the intersection of all result sets.
  const results = Array.from(
    resultArrays
      .reduce((prev, curr) => {
        const intersection = new Map<string, AnyEmojiData>();
        for (const [code, emoji] of prev) {
          if (curr.has(code)) {
            intersection.set(code, emoji);
          }
        }
        return intersection;
      })
      .values(),
  );

  results.sort((a, b) => {
    // Checks if a or b has the last token exactly, or only a prefix.
    const aHasToken = a.tokens.includes(lastToken);
    const bHasToken = b.tokens.includes(lastToken);
    if (aHasToken && !bHasToken) {
      return -1;
    } else if (!aHasToken && bHasToken) {
      return 1;
    }

    // If one is a custom emoji, prioritize it over Unicode emojis.
    if ('category' in a) {
      return -1;
    } else if ('category' in b) {
      return 1;
    }

    // If both are Unicode emojis, prioritize by order.
    if ('order' in a && 'order' in b) {
      return (a.order ?? 0) - (b.order ?? 0); // If these are both Unicode emojis, sort by order.
    }

    // ¯\_(ツ)_/¯
    return 0;
  });

  const time = performance.measure('emoji-search-end', 'emoji-search-start');
  log(
    'search for "%s" in locale %s returned %d results and took %dms',
    query,
    locale,
    results.length,
    time.duration,
  );
  if (limit > 0) {
    return results.slice(0, limit);
  }
  return results;
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

export async function loadCustomEmojiByShortcode(shortcode: string) {
  const db = await loadDB();
  return db.get('custom', shortcode);
}

export async function searchCustomEmojisByShortcodes(shortcodes: string[]) {
  const db = await loadDB();
  const sortedCodes = shortcodes.toSorted();
  const results = await db.getAll(
    'custom',
    IDBKeyRange.bound(sortedCodes.at(0), sortedCodes.at(-1)),
  );
  return results.filter((emoji) => shortcodes.includes(emoji.shortcode));
}

export async function loadLegacyShortcodesByShortcode(shortcode: string) {
  const db = await loadDB();
  return db.getFromIndex(
    'shortcodes',
    'shortcodes',
    IDBKeyRange.only(shortcode),
  );
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
    const { importEmojiData } = await import('./loader');
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
