import Dexie from 'dexie';
import type { Table } from 'dexie';
import { SUPPORTED_LOCALES } from 'emojibase';
import type { FlatCompactEmoji, Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import type { LocaleOrCustom } from './locale';
import { toSupportedLocale, toSupportedLocaleOrCustom } from './locale';

type LocaleEmojiTables = Record<Locale, Table<FlatCompactEmoji, string>>;
interface ETagTable {
  etag: string;
  locale: LocaleOrCustom;
}

const db = new Dexie('mastodon-emoji') as Dexie &
  LocaleEmojiTables & {
    custom: Table<ApiCustomEmojiJSON, string>;
    etags: Table<ETagTable, string>;
  };

const SCHEMA_VERSION = 1;

export function initEmojiDB() {
  const tableSchema = 'hexcode, group, order, *tags';
  const emojiTables: Record<string, string> = SUPPORTED_LOCALES.reduce(
    (acc, locale) => ({
      ...acc,
      [locale]: tableSchema,
    }),
    {},
  );
  emojiTables.custom = 'shortcode, category, visible_in_picker';
  emojiTables.etags = 'locale';
  db.version(SCHEMA_VERSION).stores(emojiTables);
}

export async function putEmojiData(emojis: FlatCompactEmoji[], locale: Locale) {
  const table = tableLocale(locale);
  await table.bulkPut(emojis);
}

export async function putCustomEmojiData(emojis: ApiCustomEmojiJSON[]) {
  const table = tableCustom();
  await table.bulkPut(emojis);
}

export async function putLatestEtag(etag: string, localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const table = tableEtag();
  await table.put({ etag, locale });
}

export function searchEmojiByHexcode(hexcode: string, locale: string) {
  const table = tableLocale(locale);
  return table.get(hexcode);
}

export function searchEmojiByTag(tag: string, locale: string) {
  const table = tableLocale(locale);
  return table
    .where('tags')
    .startsWithIgnoreCase(tag)
    .or('label')
    .startsWithIgnoreCase(tag)
    .sortBy('order');
}

export function searchCustomEmojiByShortcode(shortcode: string) {
  const table = tableCustom();
  return table.get(shortcode);
}

export async function loadLatestEtag(localeString: string) {
  const locale = toSupportedLocaleOrCustom(localeString);
  const table = tableEtag();
  return (await table.get(locale))?.etag ?? null;
}

function tableLocale(locale: string) {
  const supportedLocale = toSupportedLocale(locale);
  return db.table<FlatCompactEmoji, string>(supportedLocale);
}

function tableCustom() {
  return db.table<ApiCustomEmojiJSON, string>('custom');
}

function tableEtag() {
  return db.table<ETagTable, string>('etags');
}
