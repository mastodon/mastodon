import { SUPPORTED_LOCALES } from 'emojibase';
import type {
  CompactEmoji,
  Locale,
  ShortcodesDataset,
  SkinTone,
} from 'emojibase';

import { EMOJI_DB_SHORTCODE_TEST } from './constants';
import { openEmojiDB } from './db-schema';
import type { Database } from './db-schema';
import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';
import { extractTokens } from './normalize';
import type { CustomEmojiData, UnicodeEmojiData, EtagTypes } from './types';
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

export async function putEmojiData(emojis: CompactEmoji[], locale: Locale) {
  loadedLocales.add(locale);
  const db = await loadDB();
  const trx = db.transaction(locale, 'readwrite');
  await Promise.all(
    emojis.map((emoji) => trx.store.put(transformEmojiData(emoji, locale))),
  );
  await trx.done;
}

export async function putCustomEmojiData({
  emojis,
  clear = false,
}: {
  emojis: CustomEmojiData[];
  clear?: boolean;
}) {
  const db = await loadDB();
  const trx = db.transaction('custom', 'readwrite');

  // When importing from the API, clear everything first.
  if (clear) {
    await trx.store.clear();
    log('Cleared existing custom emojis in database');
  }

  await Promise.all(emojis.map((emoji) => trx.store.put(emoji)));
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

export async function putLatestEtag(etag: string, name: EtagTypes) {
  const db = await loadDB();
  await db.put('etags', etag, name);
}

export async function clearEtag(localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const db = await loadDB();
  await db.delete('etags', locale);
  log('Cleared etag for %s', locale);
}

export async function loadEmojiByHexcode(
  hexcode: string,
  localeString: string,
) {
  const db = await loadDB();
  const locale = toLoadedLocale(localeString);
  const result = await db.get(locale, hexcode);
  if (result) {
    return result;
  }
  return db.getFromIndex(locale, 'skinHexcodes', IDBKeyRange.only(hexcode));
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

export async function loadLatestEtag(localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const db = await loadDB();
  const rowCount = await db.count(locale);
  if (!rowCount) {
    return null; // No data for this locale, return null even if there is an etag.
  }

  // Check if shortcodes exist for the given Unicode locale.
  if (locale !== 'custom') {
    const result = await db.get(locale, EMOJI_DB_SHORTCODE_TEST);
    if (!result?.shortcodes) {
      return null;
    }
  }

  const etag = await db.get('etags', locale);
  return etag ?? null;
}

// Private functions

const SKIN_TONE_MAP: Record<number, SkinTone> = {
  0x1f3fb: 1, // Light skin tone
  0x1f3fc: 2, // Medium-light skin tone
  0x1f3fd: 3, // Medium skin tone
  0x1f3fe: 4, // Medium-dark skin tone
  0x1f3ff: 5, // Dark skin tone
};

function transformEmojiData(
  emoji: CompactEmoji,
  locale: Locale,
): UnicodeEmojiData {
  const { shortcodes = [], tags = [], label, emoticon, ...rest } = emoji;
  const extract = (str: string) => extractTokens(str, locale);

  let normalizedEmoticons: string[] | undefined = undefined;
  if (Array.isArray(emoticon)) {
    normalizedEmoticons = emoticon;
  } else if (emoticon) {
    normalizedEmoticons = [emoticon];
  }

  const tokens = [
    ...new Set([
      ...shortcodes.map(extract).flat(),
      ...tags.map(extract).flat(),
      ...extract(label),
      ...(normalizedEmoticons ?? []),
    ]),
  ].sort();

  const res: UnicodeEmojiData = {
    tokens,
    shortcodes,
    tags,
    label,
    emoticons: normalizedEmoticons,
    ...rest,
  };

  for (const skin of emoji.skins ?? []) {
    res.skinHexcodes ??= [];
    res.skinHexcodes.push(skin.hexcode);

    res.skinTones ??= [];
    for (const codePoint of skin.unicode) {
      const tone = SKIN_TONE_MAP[codePoint.codePointAt(0) ?? 0];
      if (tone) {
        res.skinTones.push(tone);
        break;
      }
    }
  }

  return res;
}

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

function toLoadedLocale(localeString: string) {
  const locale = toSupportedLocale(localeString);
  if (localeString !== locale) {
    log(`Locale ${locale} is different from provided ${localeString}`);
  }
  if (!loadedLocales.has(locale)) {
    throw new LocaleNotLoadedError(locale);
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
