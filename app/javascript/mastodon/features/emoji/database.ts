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
import type { AnyEmojiData, CacheKey, CustomEmojiData } from './types';
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

type ScoreMap = Map<string, AnyEmojiData & { score: number }>;

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
  const resultArrays: ScoreMap[] = [];
  const existingCustomShortcodes = new Set<string>();

  for (let i = 0; i < queryTokens.length; i++) {
    const token = queryTokens[i];
    if (!token) continue;

    // Only query the range for the last token to allow partial matches.
    const range =
      i === queryTokens.length - 1
        ? IDBKeyRange.lowerBound(token)
        : IDBKeyRange.only(token);

    const [unicodeResults, customResults, shortcodeResults] = await Promise.all(
      [
        db.getAllFromIndex(locale, 'tokens', range),
        db.getAllFromIndex('custom', 'tokens', range),
        db.getAllFromIndex('shortcodes', 'shortcodes', range),
      ],
    );
    const resultMap: ScoreMap = new Map();

    for (const emoji of unicodeResults) {
      const score = getScoreForEmoji(emoji, token);
      if (score === null) {
        continue;
      }
      resultMap.set(emoji.hexcode, { ...emoji, score });
    }

    for (const emoji of customResults) {
      const score = getScoreForEmoji(emoji, token);
      if (score === null) {
        continue;
      }
      existingCustomShortcodes.add(emoji.shortcode);
      resultMap.set(emoji.shortcode, { ...emoji, score });
    }

    for (const shortcodeResult of shortcodeResults) {
      if (resultMap.has(shortcodeResult.hexcode)) {
        continue;
      }
      const emoji = await db.get(locale, shortcodeResult.hexcode);
      if (!emoji) {
        continue;
      }
      // Score the emoji with the legacy shortcode, even though it's not part of the emoji.
      const score = getScoreForEmoji(
        {
          ...emoji,
          shortcodes: [...shortcodeResult.shortcodes, ...emoji.shortcodes],
        },
        token,
      );
      if (score === null) {
        continue;
      }
      resultMap.set(emoji.hexcode, { ...emoji, score });
    }

    log('found %d results for token "%s"', resultMap.size, token);
    resultArrays.push(resultMap);
  }

  // Utilize maps to find the intersection of all result sets.
  const results = Array.from(
    resultArrays
      .reduce((prev, curr) => {
        const intersection: ScoreMap = new Map();
        for (const [code, emoji] of prev) {
          if (curr.has(code)) {
            intersection.set(code, emoji);
          }
        }
        return intersection;
      })
      .values(),
  );

  // If there are no results, try a cursor-based custom emoji search instead.
  if (results.length === 0 || results.length < limit) {
    const customEmojisFound = await fullCustomSearch(
      query,
      existingCustomShortcodes,
    );
    if (customEmojisFound.length > 0) {
      log(
        'cursor search found %d results for "%s"',
        customEmojisFound.length,
        query,
      );
      results.push(...customEmojisFound);
    }
  }

  // Sort by score, descending.
  results.sort((a, b) => a.score - b.score);

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

function getScoreForEmoji(
  emoji: AnyEmojiData,
  query: string,
  checkTokens = true,
) {
  const id = 'shortcode' in emoji ? emoji.shortcode : emoji.label;
  if (id === query) {
    return 0;
  }

  let index = 1;
  const searchTokens = [id];
  if (checkTokens) {
    // Check shortcodes before tokens as they are more important.
    if ('shortcodes' in emoji) {
      searchTokens.push(...emoji.shortcodes);
    }
    searchTokens.push(...emoji.tokens);
  }
  for (const token of searchTokens) {
    const tokenIndex = token.indexOf(query);
    if (tokenIndex !== -1) {
      return index + tokenIndex / token.length;
    }
    index++;
  }

  return null;
}

async function fullCustomSearch(query: string, existing = new Set<string>()) {
  const db = await loadDB();
  const trx = db.transaction('custom', 'readonly');
  const foundEmojis = new Set<string>();

  // First iterate over chunks of 1,000 custom emoji keys and find any matches.
  const chunkSize = 1_000;
  let lastKey: string | null = null;
  let keys: string[] = [];
  do {
    const keyRange = lastKey ? IDBKeyRange.lowerBound(lastKey, true) : null;
    keys = await trx.store.getAllKeys(keyRange, chunkSize);

    if (keys.length === 0) {
      break;
    }
    log('cursor search got batch of %d emojis', keys.length);
    lastKey = keys.at(-1) ?? null;

    for (const key of keys) {
      if (!foundEmojis.has(key) && !existing.has(key) && key.includes(query)) {
        foundEmojis.add(key);
      }
    }
  } while (keys.length === chunkSize);

  // Next get the full emojis for all matches.
  const emojis = await Promise.all(
    foundEmojis.keys().map((key) => trx.store.get(key)),
  );
  const results: (CustomEmojiData & { score: number })[] = [];
  for (const emoji of emojis) {
    if (emoji) {
      const score = getScoreForEmoji(emoji, query, false);
      if (score && score > 0) {
        results.push({
          score,
          ...emoji,
        });
      }
    }
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

export async function resetDatabase() {
  const db = await loadDB();
  const storeNames = [...db.objectStoreNames];
  await Promise.all(storeNames.map((storeName) => db.clear(storeName)));
  log(storeNames, 'Reset emoji database stores:');
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
  const db = await loadDB();
  const sortedCodes = shortcodes.toSorted();
  const results = await db.getAll(
    'custom',
    IDBKeyRange.bound(sortedCodes.at(0), sortedCodes.at(-1)),
  );
  return results.filter((emoji) => shortcodes.includes(emoji.shortcode));
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
    // Ignore the INEFFECTIVE_DYNAMIC_IMPORT Vite warning, since the static import location is inside an inlined web worker.
    const { importEmojiData } = await import(/* @vite-ignore */ './loader');
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
