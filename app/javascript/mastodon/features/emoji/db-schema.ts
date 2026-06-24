import { SUPPORTED_LOCALES } from 'emojibase';
import type { Locale } from 'emojibase';
import { deleteDB, openDB } from 'idb';
import type {
  DBSchema,
  IDBPDatabase,
  IDBPObjectStore,
  IDBPTransaction,
  IndexNames,
  StoreNames,
} from 'idb';

import { EMOJI_DB_RELOAD_EVENT } from './constants';
import type {
  CustomEmojiData,
  CacheKey,
  UnicodeEmojiData,
  EmojiWorkerMessage,
} from './types';
import { emojiLogger } from './utils';

const log = emojiLogger('database');

interface EmojiDB extends LocaleTables, DBSchema {
  custom: {
    key: string;
    value: CustomEmojiData;
    indexes: {
      tokens: string[];
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
    key: CacheKey;
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

const DATABASE_NAME = 'mastodon-emoji';
const SCHEMA_VERSION = 4;

export async function openEmojiDB() {
  try {
    const db = await openDB<EmojiDB>(DATABASE_NAME, SCHEMA_VERSION, {
      upgrade(database, oldVersion, newVersion, trx) {
        if (!database.objectStoreNames.contains('custom')) {
          database.createObjectStore('custom', {
            keyPath: 'shortcode',
            autoIncrement: false,
          });
        }
        maybeAddIndex({ trx, storeName: 'custom', indexName: 'category' });
        maybeAddIndex({
          trx,
          storeName: 'custom',
          indexName: 'tokens',
          options: { multiEntry: true },
        });

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

        // Reset all database stores.
        for (const storeName of database.objectStoreNames) {
          void trx.objectStore(storeName).clear();
        }

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
          'Emoji database upgrade from version %d is blocking upgrade to %d, closing connection',
          currentVersion,
          blockedVersion,
        );
        // Close the database connection immediately.
        db.close();

        if (typeof window !== 'undefined') {
          window.dispatchEvent(new Event(EMOJI_DB_RELOAD_EVENT));
        } else {
          self.postMessage({ type: 'db-blocked' } satisfies EmojiWorkerMessage);
        }
      },
    });

    return db;
  } catch (error) {
    if (error instanceof DOMException && error.name === 'VersionError') {
      log(
        'Emoji database version is newer than expected, deleting and recreating',
      );
      await deleteDB(DATABASE_NAME);
      return openEmojiDB();
    }
    throw error;
  }
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
  if (!database.objectStoreNames.contains(locale)) {
    database.createObjectStore(locale, {
      keyPath: 'hexcode',
      autoIncrement: false,
    });
  }

  maybeAddIndex({
    trx,
    storeName: locale,
    indexName: 'shortcodes',
    options: { multiEntry: true },
  });
  maybeAddIndex({
    trx,
    storeName: locale,
    indexName: 'groupOrder',
    keys: ['group', 'order'],
  });
  maybeAddIndex({
    trx,
    storeName: locale,
    indexName: 'tokens',
    keys: 'tokens',
    options: { multiEntry: true },
  });
  maybeAddIndex({
    trx,
    storeName: locale,
    indexName: 'skinHexcodes',
    keys: 'skinHexcodes',
    options: { multiEntry: true },
  });

  const oldIndexes = ['group', 'order', 'tag', 'label'] as const;
  deleteOldIndexes(trx.objectStore(locale), oldIndexes);
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
