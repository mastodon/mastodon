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
import { emojiLogger } from './utils';

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
    groupOrder: [number, number];
    label: string;
    order?: number;
    tags: string[];
  };
}
type LocaleTables = Record<Locale, LocaleTable>;

type Database = IDBPDatabase<EmojiDB>;

const SCHEMA_VERSION = 2;

const loadedLocales = new Set<Locale>();

const log = emojiLogger('database');

// Loads the database in a way that ensures it's only loaded once.
const loadDB = (() => {
  let dbPromise: Promise<Database> | null = null;

  // Actually load the DB.
  async function initDB() {
    const db = await openDB<EmojiDB>('mastodon-emoji', SCHEMA_VERSION, {
      upgrade(database, oldVersion, _newVersion, transaction) {
        const storeNames = database.objectStoreNames;
        if (!storeNames.contains('custom')) {
          const customTable = database.createObjectStore('custom', {
            keyPath: 'shortcode',
            autoIncrement: false,
          });
          customTable.createIndex('category', 'category');
        }

        if (!storeNames.contains('etags')) {
          database.createObjectStore('etags');
        }

        for (const locale of SUPPORTED_LOCALES) {
          if (!storeNames.contains(locale)) {
            database.createObjectStore(locale, {
              keyPath: 'hexcode',
              autoIncrement: false,
            });
          }
          const localeTable = transaction.objectStore(locale);

          if (oldVersion < 1) {
            localeTable.createIndex('group', 'group');
            localeTable.createIndex('label', 'label');
            localeTable.createIndex('tags', 'tags', { multiEntry: true });
          }
          if (oldVersion < 2) {
            if (localeTable.indexNames.contains('order')) {
              localeTable.deleteIndex('order');
            }
            localeTable.createIndex('groupOrder', ['group', 'order'], {
              unique: false,
            });
          }
        }
      },
    });
    await syncLocales(db);
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
  await db.put('etags', etag, locale);
}

export async function loadEmojiByHexcode(
  hexcode: string,
  localeString: string,
) {
  const db = await loadDB();
  const locale = toLoadedLocale(localeString);
  return db.get(locale, hexcode);
}

export async function searchEmojisByHexcodes(
  hexcodes: string[],
  localeString: string,
) {
  const db = await loadDB();
  const locale = toLoadedLocale(localeString);
  const sortedCodes = hexcodes.toSorted();
  const results = await db.getAll(
    locale,
    IDBKeyRange.bound(sortedCodes.at(0), sortedCodes.at(-1)),
  );
  return results.filter((emoji) => hexcodes.includes(emoji.hexcode));
}

export async function searchEmojisByTag(tag: string, localeString: string) {
  const db = await loadDB();
  const locale = toLoadedLocale(localeString);
  const range = IDBKeyRange.bound(
    tag.toLowerCase(),
    `${tag.toLowerCase()}\uffff`,
  );
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

export async function loadUnicodeEmojiGroup(
  group: number,
  localeString: string,
) {
  const locale = toLoadedLocale(localeString);
  const db = await loadDB();
  const emojis = await db.getAllFromIndex(locale, 'group', group);
  return emojis.toSorted(({ order: a = 0 }, { order: b = 0 }) => a - b);
}

export async function loadUnicodeEmojiGroupIcon(
  group: number,
  localeString: string,
) {
  const locale = toLoadedLocale(localeString);
  const db = await loadDB();
  const trx = db.transaction(locale, 'readonly');
  const index = trx.store.index('groupOrder');
  const range = IDBKeyRange.bound([group, 0], [group, Number.MAX_SAFE_INTEGER]);
  const cursor = await index.openCursor(range);
  return cursor?.value ?? null;
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
