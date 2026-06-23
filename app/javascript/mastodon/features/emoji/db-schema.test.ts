import { IDBFactory } from 'fake-indexeddb';

import { EMOJI_DB_RELOAD_EVENT } from './constants';
import { openEmojiDB } from './db-schema';

describe('openEmojiDB', () => {
  afterEach(() => {
    indexedDB = new IDBFactory();
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  describe('versionchange handler', () => {
    test('dispatches reload event in main thread context', async () => {
      const dispatchSpy = vi.fn();
      window.addEventListener(EMOJI_DB_RELOAD_EVENT, dispatchSpy);

      await openEmojiDB();

      // Opening a higher version on the same IDBFactory triggers versionchange
      // on all existing connections to that database.
      indexedDB.open('mastodon-emoji', 9999);

      await vi.waitFor(() => {
        expect(dispatchSpy).toHaveBeenCalledOnce();
      });

      window.removeEventListener(EMOJI_DB_RELOAD_EVENT, dispatchSpy);
    });

    test('posts db-blocked message in worker context', async () => {
      const postMessageSpy = vi.fn();
      vi.stubGlobal('window', undefined);
      vi.stubGlobal('self', { postMessage: postMessageSpy });

      await openEmojiDB();

      indexedDB.open('mastodon-emoji', 9999);

      await vi.waitFor(() => {
        expect(postMessageSpy).toHaveBeenCalledWith({ type: 'db-blocked' });
      });
    });

    test('closes all open connections when versionchange fires', async () => {
      const dispatchSpy = vi.fn();
      window.addEventListener(EMOJI_DB_RELOAD_EVENT, dispatchSpy);

      const db1 = await openEmojiDB();
      const db2 = await openEmojiDB();

      // Opening a higher version on the same IDBFactory triggers versionchange
      // on all existing connections to that database.
      indexedDB.open('mastodon-emoji', 9999);

      await vi.waitFor(() => {
        expect(dispatchSpy).toHaveBeenCalledTimes(2);
      });

      window.removeEventListener(EMOJI_DB_RELOAD_EVENT, dispatchSpy);

      // Both connections should now be closed.
      expect(() => db1.transaction('etags', 'readonly')).toThrow();
      expect(() => db2.transaction('etags', 'readonly')).toThrow();
    });
  });
});
