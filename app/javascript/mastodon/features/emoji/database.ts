import { SUPPORTED_LOCALES } from 'emojibase';
import type { CompactEmoji, Locale, ShortcodesDataset } from 'emojibase';
import type { ArrayValues, KeysOfUnion } from 'type-fest';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { onceAsync } from '@/mastodon/utils/promises';

import { openEmojiDB } from './db-schema';
import type { Database } from './db-schema';
import { importEmojiData } from './loader';
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

const scoreRanking = [
  'label',
  'shortcode',
  'emoticons',
  'shortcodes',
  'tokens',
] as const satisfies KeysOfUnion<AnyEmojiData>[];
type ScoreRankingKeys = ArrayValues<typeof scoreRanking>;
type ScoreRanking = Record<ScoreRankingKeys, number>;

// Identifier fields hold a match against a complete, canonical string (a
// shortcode, label, emoticon, or legacy shortcode). Token fields only hold
// matches against derived word fragments (e.g. one half of an
// underscore-split shortcode, or a single tag word) — a much weaker
// signal. Identifier matches should always outrank token matches, no
// matter how good the token match's own score is.
const identifierFields = new Set<ScoreRankingKeys>([
  'label',
  'shortcode',
  'emoticons',
  'shortcodes',
]);

interface BestRank {
  categoryWeight: number;
  score: number;
  fieldWeight: number;
}
type ScoredEmoji = AnyEmojiData & { scores: ScoreRanking };
type ScoreMap = Map<string, ScoredEmoji>;

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
    const checkedSet = new Set<string>();

    // Score unicode results.
    for (const emoji of unicodeResults) {
      if (checkedSet.has(emoji.hexcode)) {
        continue;
      }
      checkedSet.add(emoji.hexcode);
      const scores = getScoreForEmoji(emoji, token);
      if (scores) {
        resultMap.set(emoji.hexcode, { ...emoji, scores });
      }
    }

    // Score custom emojis.
    for (const emoji of customResults) {
      if (checkedSet.has(emoji.shortcode)) {
        continue;
      }
      checkedSet.add(emoji.shortcode);
      const scores = getScoreForEmoji(emoji, token);
      if (scores) {
        existingCustomShortcodes.add(emoji.shortcode);
        resultMap.set(emoji.shortcode, { ...emoji, scores });
      }
    }

    // Score based on legacy shortcodes, using the higher score if there's a match.
    for (const shortcodeResult of shortcodeResults) {
      const emoji =
        resultMap.get(shortcodeResult.hexcode) ??
        (await db.get(locale, shortcodeResult.hexcode));
      if (!emoji || !('hexcode' in emoji)) {
        continue;
      }

      const newScores = getScoreForEmoji(
        {
          ...emoji,
          shortcodes: shortcodeResult.shortcodes,
        },
        token,
      );
      if (!newScores) {
        continue;
      }
      const oldScores = resultMap.get(emoji.hexcode)?.scores;
      let scores = newScores;
      if (oldScores) {
        scores = Object.fromEntries(
          scoreRanking.map((key) => [
            key,
            newScores[key] !== -1 && oldScores[key] !== -1
              ? Math.min(newScores[key], oldScores[key])
              : Math.max(newScores[key], oldScores[key]),
          ]),
        ) as ScoreRanking;
      }
      resultMap.set(emoji.hexcode, { ...emoji, scores });
    }

    log('found %d results for token "%s"', resultMap.size, token);
    resultArrays.push(resultMap);
  }

  const mixedResults = Array.from(
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
  if (mixedResults.length === 0 || mixedResults.length < limit) {
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
      mixedResults.push(...customEmojisFound);
    }
  }

  const results: ScoredEmoji[] = [];
  const resultEmojis = new Set<string>();
  for (const result of mixedResults.toSorted(compareRankedEmoji)) {
    const id = 'shortcode' in result ? result.shortcode : result.hexcode;
    if (resultEmojis.has(id)) {
      continue;
    }
    results.push(result);
    resultEmojis.add(id);
    if (limit > 0 && results.length > limit) {
      break;
    }
  }

  const time = performance.measure('emoji-search-end', 'emoji-search-start');
  log(
    'search for "%s" in locale %s returned %d results and took %dms',
    query,
    locale,
    mixedResults.length,
    time.duration,
  );
  if (limit > 0) {
    return results.slice(0, limit);
  }
  return results;
}

function hasField(
  emoji: AnyEmojiData,
  field: string,
): field is keyof typeof emoji {
  return Object.hasOwn(emoji, field);
}

// Creates ranked scores for a given emoji.
function getScoreForEmoji(emoji: AnyEmojiData, query: string) {
  const scores = Object.fromEntries(
    scoreRanking.map((field) => [field, -1]),
  ) as ScoreRanking;
  let hasScore = false;

  for (const field of scoreRanking) {
    if (hasField(emoji, field)) {
      const value = emoji[field] as string | string[] | undefined;
      if (value === undefined) {
        continue;
      }
      const tokens = Array.isArray(value) ? value : [value];
      const score = getScoreForEmojiTokens(tokens, query);

      if (score >= 0) {
        scores[field] = score;
        hasScore = true;
      }
    }
  }

  if (!hasScore) {
    return null;
  }

  return scores;
}

// Compares two scored emojis by getting the best rank.
function compareRankedEmoji(a: ScoredEmoji, b: ScoredEmoji): number {
  const rankA = getBestRank(a.scores);
  const rankB = getBestRank(b.scores);

  // Identifier matches always outrank token matches, regardless of score.
  if (rankA.categoryWeight !== rankB.categoryWeight) {
    return rankA.categoryWeight - rankB.categoryWeight;
  }
  // Within the same category, compare the scores directly.
  if (rankA.score !== rankB.score) {
    return rankA.score - rankB.score;
  }
  // If equal, compare field weights.
  if (rankA.fieldWeight !== rankB.fieldWeight) {
    return rankA.fieldWeight - rankB.fieldWeight;
  }

  // Lastly prioritize Unicode emojis.
  const aIsCustom = hasField(a, 'shortcode');
  const bIsCustom = hasField(b, 'shortcode');
  if (aIsCustom !== bIsCustom) {
    return aIsCustom ? -1 : 1;
  }

  return 0;
}

// Extracts the best rank for a score ranking.
function getBestRank(scores: ScoreRanking): BestRank {
  let best: BestRank | null = null;

  // Use the index to determine field weight.
  for (const [fieldWeight, field] of scoreRanking.entries()) {
    const score = scores[field];
    if (score < 0) {
      continue;
    }
    // Also weight identifier fields over other fields.
    const categoryWeight = identifierFields.has(field) ? 0 : 1;
    if (
      !best ||
      categoryWeight < best.categoryWeight ||
      (categoryWeight === best.categoryWeight &&
        (score < best.score ||
          (score === best.score && fieldWeight < best.fieldWeight)))
    ) {
      best = { categoryWeight, score, fieldWeight };
    }
  }

  return (
    best ?? {
      categoryWeight: 2,
      score: Infinity,
      fieldWeight: scoreRanking.length,
    }
  );
}

function getScoreForEmojiTokens(tokens: string[], query: string) {
  let lowestScore = -1;

  for (const token of tokens) {
    let score = -1;
    // Priority: exact match, prefix match, substring,
    if (token === query) {
      score = 0;
    } else if (token.startsWith(query)) {
      score = 1 + query.length / token.length;
    } else if (token.includes(query)) {
      score = 2 + query.length / token.length;
    } // TODO: Add fuzzy search if needed

    if (score >= 0 && (score < lowestScore || lowestScore < 0)) {
      lowestScore = score;
    }
  }

  return lowestScore;
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
  const results: (CustomEmojiData & { scores: ScoreRanking })[] = [];
  for (const emoji of emojis) {
    if (emoji) {
      const scores = getScoreForEmoji(emoji, query);
      if (scores) {
        results.push({
          scores,
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
