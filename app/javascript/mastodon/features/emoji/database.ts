import debug from 'debug';
import { SUPPORTED_LOCALES } from 'emojibase';
import type { Locale } from 'emojibase';
import type { DBSchema, IDBPDatabase } from 'idb';
import { openDB } from 'idb';

import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';
import type {
  CustomEmojiData,
  UnicodeEmojiData,
  LocaleOrCustom,
} from './types';

interface EmojiDB extends LocaleTables, DBSchema {
  custom: {
    key: string;
    value: CustomEmojiData;
    indexes: {
      category: string;
    };
  };
  etags: {
    key: LocaleOrCustom;
    value: string;
  };
}

interface LocaleTable {
  key: string;
  value: UnicodeEmojiData;
  indexes: {
    group: number;
    label: string;
    order: number;
    tags: string[];
  };
}
type LocaleTables = Record<Locale, LocaleTable>;

const SCHEMA_VERSION = 1;

const loadedLocales = new Set<Locale>();

let db: IDBPDatabase<EmojiDB> | null = null;

const log = debug('emojis:database');

async function loadDB() {
  if (db) {
    return db;
  }
  db = await openDB<EmojiDB>('mastodon-emoji', SCHEMA_VERSION, {
    upgrade(database) {
      const customTable = database.createObjectStore('custom', {
        keyPath: 'shortcode',
        autoIncrement: false,
      });
      customTable.createIndex('category', 'category');

      database.createObjectStore('etags');

      for (const locale of SUPPORTED_LOCALES) {
        const localeTable = database.createObjectStore(locale, {
          keyPath: 'hexcode',
          autoIncrement: false,
        });
        localeTable.createIndex('group', 'group');
        localeTable.createIndex('label', 'label');
        localeTable.createIndex('order', 'order');
        localeTable.createIndex('tags', 'tags', { multiEntry: true });
      }
    },
  });
  await syncLocales();
  return db;
}

export async function putEmojiData(emojis: UnicodeEmojiData[], locale: Locale) {
  loadedLocales.add(locale);
  const db = await loadDB();
  const trx = db.transaction(locale, 'readwrite');
  await Promise.all(emojis.map((emoji) => trx.store.put(emoji)));
  await trx.done;
}

export async function putCustomEmojiData(emojis: CustomEmojiData[]) {
  const db = await loadDB();
  const trx = db.transaction('custom', 'readwrite');
  await Promise.all(emojis.map((emoji) => trx.store.put(emoji)));
  await trx.done;
}

export async function putLatestEtag(etag: string, localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const db = await loadDB();
  return db.put('etags', etag, locale);
}

export async function loadEmojiByHexcode(
  hexcode: string,
  localeString: string,
) {
  const locale = toLoadedLocale(localeString);
  const db = await loadDB();
  return db.get(locale, hexcode);
}

export async function searchEmojisByHexcodes(
  hexcodes: string[],
  localeString: string,
) {
  const locale = toLoadedLocale(localeString);
  const db = await loadDB();
  const sortedCodes = hexcodes.toSorted();
  const results = await db.getAll(
    locale,
    IDBKeyRange.bound(sortedCodes.at(0), sortedCodes.at(-1)),
  );
  return results.filter((emoji) => hexcodes.includes(emoji.hexcode));
}

export async function searchEmojisByTag(tag: string, localeString: string) {
  const locale = toLoadedLocale(localeString);
  const range = IDBKeyRange.bound(
    tag.toLowerCase(),
    `${tag.toLowerCase()}\uffff`,
  );
  const db = await loadDB();
  return db.getAllFromIndex(locale, 'tags', range);
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

export async function loadLatestEtag(localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const db = await loadDB();
  const rowCount = await db.count(locale);
  if (!rowCount) {
    return null; // No data for this locale, return null even if there is an etag.
  }
  const etag = await db.get('etags', locale);
  return etag ?? null;
}

// Private functions

async function syncLocales() {
  const locales = await Promise.all(
    SUPPORTED_LOCALES.map(
      async (locale) =>
        [locale, await hasLocale(locale)] satisfies [Locale, boolean],
    ),
  );
  for (const [locale, loaded] of locales) {
    if (loaded) {
      loadedLocales.add(locale);
    } else {
      loadedLocales.delete(locale);
    }
  }
}

function toLoadedLocale(localeString: string) {
  const locale = toSupportedLocale(localeString);
  if (localeString !== locale) {
    log(`Locale ${locale} is different from provided ${localeString}`);
  }
  if (!loadedLocales.has(locale)) {
    throw new Error(`Locale ${locale} is not loaded in emoji database`);
  }
  return locale;
}

async function hasLocale(locale: Locale): Promise<boolean> {
  if (loadedLocales.has(locale)) {
    return true;
  }
  const db = await loadDB();
  const rowCount = await db.count(locale);
  return !!rowCount;
}

// Testing helpers
export function testGet() {
  return { db, loadedLocales };
}
export function testClear() {
  db = null;
  loadedLocales.clear();
}
