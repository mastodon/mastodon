import { SUPPORTED_LOCALES } from 'emojibase';
import type { FlatCompactEmoji, Locale } from 'emojibase';
import type { DBSchema } from 'idb';
import { openDB } from 'idb';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import type { LocaleOrCustom } from './locale';
import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';

interface EmojiDB extends LocaleTables, DBSchema {
  custom: {
    key: string;
    value: ApiCustomEmojiJSON;
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
  value: FlatCompactEmoji;
  indexes: {
    group: number;
    label: string;
    order: number;
    tags: string[];
  };
}
type LocaleTables = Record<Locale, LocaleTable>;

const SCHEMA_VERSION = 1;

const db = await openDB<EmojiDB>('mastodon-emoji', SCHEMA_VERSION, {
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

export async function putEmojiData(emojis: FlatCompactEmoji[], locale: Locale) {
  const trx = db.transaction(locale, 'readwrite');
  await Promise.all(emojis.map((emoji) => trx.store.put(emoji)));
  await trx.done;
}

export async function putCustomEmojiData(emojis: ApiCustomEmojiJSON[]) {
  const trx = db.transaction('custom', 'readwrite');
  await Promise.all(emojis.map((emoji) => trx.store.put(emoji)));
  await trx.done;
}

export function putLatestEtag(etag: string, localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  return db.put('etags', etag, locale);
}

export function searchEmojiByHexcode(hexcode: string, localeString: string) {
  const locale = toSupportedLocale(localeString);
  return db.get(locale, hexcode);
}

export function searchEmojiByTag(tag: string, localeString: string) {
  const locale = toSupportedLocale(localeString);
  const range = IDBKeyRange.only(tag.toLowerCase());
  return db.getAllFromIndex(locale, 'tags', range);
}

export function searchCustomEmojiByShortcode(shortcode: string) {
  return db.get('custom', shortcode);
}

export async function loadLatestEtag(localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const rowCount = await db.count(locale);
  if (!rowCount) {
    return null; // No data for this locale, return null even if there is an etag.
  }
  const etag = await db.get('etags', locale);
  return etag ?? null;
}
