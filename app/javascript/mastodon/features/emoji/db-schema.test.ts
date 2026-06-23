import { IDBFactory } from 'fake-indexeddb';

import { openEmojiDB } from './db-schema';

// resetDatabase is called fire-and-forget in the upgrade handler. Mocking it
// prevents it from operating on a closed connection when a higher-version open
// triggers its own upgrade, which would cause an InvalidStateError.
vi.mock('./database', () => ({
  resetDatabase: vi.fn().mockResolvedValue(undefined),
}));

describe('openEmojiDB', () => {
  afterEach(() => {
    indexedDB = new IDBFactory();
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  describe('versionchange handler', () => {
    test('reloads window in main thread context', async () => {
      const reloadSpy = vi.fn();
      vi.stubGlobal('location', { reload: reloadSpy });

      await openEmojiDB();

      // Opening a higher version on the same IDBFactory triggers versionchange
      // on all existing connections to that database.
      indexedDB.open('mastodon-emoji', 9999);

      await vi.waitFor(() => {
        expect(reloadSpy).toHaveBeenCalledOnce();
      });
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
      const reloadSpy = vi.fn();
      vi.stubGlobal('location', { reload: reloadSpy });

      const db1 = await openEmojiDB();
      const db2 = await openEmojiDB();

      // Opening a higher version on the same IDBFactory triggers versionchange
      // on all existing connections to that database.
      indexedDB.open('mastodon-emoji', 9999);

      await vi.waitFor(() => {
        expect(reloadSpy).toHaveBeenCalledTimes(2);
      });

      // Both connections should now be closed.
      expect(() => db1.transaction('etags', 'readonly')).toThrow();
      expect(() => db2.transaction('etags', 'readonly')).toThrow();
    });
  });
});
