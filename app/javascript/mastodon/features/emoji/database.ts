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

let db: IDBPDatabase<EmojiDB> | null = null;

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
  return db;
}

export async function putEmojiData(emojis: UnicodeEmojiData[], locale: Locale) {
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

export async function searchEmojiByHexcode(
  hexcode: string,
  localeString: string,
) {
  const locale = toSupportedLocale(localeString);
  const db = await loadDB();
  return db.get(locale, hexcode);
}

export async function searchEmojisByHexcodes(
  hexcodes: string[],
  localeString: string,
) {
  const locale = toSupportedLocale(localeString);
  const db = await loadDB();
  return db.getAll(
    locale,
    IDBKeyRange.bound(hexcodes[0], hexcodes[hexcodes.length - 1]),
  );
}

export async function searchEmojiByTag(tag: string, localeString: string) {
  const locale = toSupportedLocale(localeString);
  const range = IDBKeyRange.only(tag.toLowerCase());
  const db = await loadDB();
  return db.getAllFromIndex(locale, 'tags', range);
}

export async function searchCustomEmojiByShortcode(shortcode: string) {
  const db = await loadDB();
  return db.get('custom', shortcode);
}

export async function searchCustomEmojisByShortcodes(shortcodes: string[]) {
  const db = await loadDB();
  return db.getAll(
    'custom',
    IDBKeyRange.bound(shortcodes[0], shortcodes[shortcodes.length - 1]),
  );
}

export async function findMissingLocales(localeStrings: string[]) {
  const locales = new Set(localeStrings.map(toSupportedLocale));
  const missingLocales: Locale[] = [];
  const db = await loadDB();
  for (const locale of locales) {
    const rowCount = await db.count(locale);
    if (!rowCount) {
      missingLocales.push(locale);
    }
  }
  return missingLocales;
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
