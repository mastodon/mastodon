import Dexie from 'dexie';
import type { Table } from 'dexie';
import { SUPPORTED_LOCALES } from 'emojibase';
import type { FlatCompactEmoji, Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

type LocaleEmojiTables = Record<Locale, Table<FlatCompactEmoji, string>>;

const db = new Dexie('mastodon-emoji') as Dexie &
  LocaleEmojiTables & {
    custom: Table<ApiCustomEmojiJSON, string>;
  };

export async function loadEmojiData(
  emojis: FlatCompactEmoji[],
  locale: Locale,
) {
  const table = tableLocale(locale);
  await table.bulkPut(emojis);
}

export async function loadCustomEmojiData(emojis: ApiCustomEmojiJSON[]) {
  const table = tableCustom();
  await table.bulkPut(emojis);
}

export function searchEmojiByHexcode(hexcode: string, locale: Locale) {
  const table = tableLocale(locale);
  return table.get(hexcode);
}

export function searchCustomEmojiByShortcode(shortcode: string) {
  const table = tableCustom();
  return table.get(shortcode);
}

function tableLocale(locale: Locale) {
  initEmojiDB();
  return db.table<FlatCompactEmoji, string>(locale);
}

function tableCustom() {
  initEmojiDB();
  return db.table<ApiCustomEmojiJSON, string>('custom');
}

let isDBInitialized = false;
function initEmojiDB() {
  if (isDBInitialized) {
    return;
  }
  const tableSchema = '&hexcode group label *tags';
  const emojiTables: Record<string, string> = SUPPORTED_LOCALES.reduce(
    (acc, locale) => ({
      ...acc,
      [locale]: tableSchema,
    }),
    {},
  );
  emojiTables.custom = '&shortcode category visible_in_picker';
  db.version(1).stores(emojiTables);
  isDBInitialized = true;
}
