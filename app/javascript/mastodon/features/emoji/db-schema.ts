import { SUPPORTED_LOCALES } from 'emojibase';
import type { Locale } from 'emojibase';
import { openDB } from 'idb';
import type {
  DBSchema,
  IDBPDatabase,
  IDBPObjectStore,
  IDBPTransaction,
  IndexNames,
  StoreNames,
} from 'idb';

import type { CustomEmojiData, EtagTypes, UnicodeEmojiData } from './types';
import { emojiLogger } from './utils';

const log = emojiLogger('database');

interface EmojiDB extends LocaleTables, DBSchema {
  custom: {
    key: string;
    value: CustomEmojiData;
    indexes: {
      category: string;
    };
  };
  shortcodes: {
    key: string;
    value: {
      hexcode: string;
      shortcodes: string[];
    };
    indexes: {
      shortcodes: string[];
    };
  };
  etags: {
    key: EtagTypes;
    value: string;
  };
}

interface LocaleTable {
  key: string;
  value: UnicodeEmojiData;
  indexes: {
    shortcodes: string[];
    groupOrder: [number, number];
    tokens: string[];
    skinHexcodes: string[];
  };
}
type LocaleTables = Record<Locale, LocaleTable>;

type Transaction<Mode extends IDBTransactionMode = 'versionchange'> =
  IDBPTransaction<EmojiDB, StoreNames<EmojiDB>[], Mode>;

export type Database = IDBPDatabase<EmojiDB>;

const SCHEMA_VERSION = 2;

export async function openEmojiDB() {
  const db = await openDB<EmojiDB>('mastodon-emoji', SCHEMA_VERSION, {
    upgrade(database, oldVersion, newVersion, trx) {
      if (!database.objectStoreNames.contains('custom')) {
        database.createObjectStore('custom', {
          keyPath: 'shortcode',
          autoIncrement: false,
        });
      }
      maybeAddIndex({ trx, storeName: 'custom', indexName: 'category' });

      if (!database.objectStoreNames.contains('etags')) {
        database.createObjectStore('etags');
      }

      SUPPORTED_LOCALES.forEach((locale) => {
        createLocaleTable(locale, database, trx);
      });

      const shortcodeTable = database.objectStoreNames.contains('shortcodes')
        ? trx.objectStore('shortcodes')
        : database.createObjectStore('shortcodes', {
            keyPath: 'hexcode',
            autoIncrement: false,
          });
      maybeAddIndex({
        trx,
        storeName: 'shortcodes',
        indexName: 'shortcodes',
        options: { multiEntry: true },
      });
      deleteOldIndexes(shortcodeTable, ['hexcode']);

      log(
        'Upgraded emoji database from version %d to %d',
        oldVersion,
        newVersion,
      );
    },
    blocked(currentVersion, blockedVersion) {
      log(
        'Emoji database upgrade from version %d to %d is blocked',
        currentVersion,
        blockedVersion,
      );
    },
    blocking(currentVersion, blockedVersion) {
      log(
        'Emoji database upgrade from version %d is blocking upgrade to %d',
        currentVersion,
        blockedVersion,
      );
    },
  });

  return db;
}

function maybeAddIndex<StoreName extends StoreNames<EmojiDB>>({
  trx,
  storeName,
  indexName,
  keys,
  options,
}: {
  trx: Transaction;
  storeName: StoreName;
  indexName: IndexNames<EmojiDB, StoreName>;
  keys?: string | string[];
  options?: IDBIndexParameters;
}) {
  const store = trx.objectStore(storeName);
  if (!store.indexNames.contains(indexName)) {
    store.createIndex(indexName, keys ?? indexName, options);
  }
}

function createLocaleTable(
  locale: Locale,
  database: Database,
  trx: Transaction,
) {
  const localeTable = database.objectStoreNames.contains(locale)
    ? trx.objectStore(locale)
    : database.createObjectStore(locale, {
        keyPath: 'hexcode',
        autoIncrement: false,
      });

  // Added in version 2.
  if (!localeTable.indexNames.contains('shortcodes')) {
    localeTable.createIndex('shortcodes', 'shortcodes', {
      multiEntry: true,
    });
  }

  // Changed in version 3.
  const oldIndexes = ['group', 'order', 'tag', 'label'] as const;
  deleteOldIndexes(localeTable, oldIndexes);

  localeTable.createIndex('groupOrder', ['group', 'order']);
  localeTable.createIndex('tokens', 'tokens', { multiEntry: true });
  localeTable.createIndex('skinHexcodes', 'skinHexcodes', {
    multiEntry: true,
  });
}

function deleteOldIndexes(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any -- Type is too complex, so only any works here.
  table: IDBPObjectStore<any, any, any, 'versionchange'>,
  indexes: readonly string[],
) {
  for (const index of indexes) {
    if (table.indexNames.contains(index)) {
      table.deleteIndex(index);
    }
  }
}
