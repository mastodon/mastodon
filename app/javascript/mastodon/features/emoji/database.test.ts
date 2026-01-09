import type { CompactEmoji } from 'emojibase';
import { IDBFactory } from 'fake-indexeddb';

import { customEmojiFactory, unicodeEmojiFactory } from '@/testing/factories';

import { EMOJI_DB_SHORTCODE_TEST } from './constants';
import {
  putEmojiData,
  loadEmojiByHexcode,
  testClear,
  testGet,
  putCustomEmojiData,
  putLegacyShortcodes,
  loadLegacyShortcodesByShortcode,
  loadLatestEtag,
  putLatestEtag,
} from './database';

function rawEmojiFactory(data: Partial<CompactEmoji> = {}): CompactEmoji {
  return {
    ...unicodeEmojiFactory(),
    tags: ['test', 'emoji'],
    ...data,
  };
}

describe('emoji database', () => {
  afterEach(() => {
    testClear();
    indexedDB = new IDBFactory();
  });

  describe('putEmojiData', () => {
    test('adds to loaded locales', async () => {
      const { loadedLocales } = await testGet();
      expect(loadedLocales).toHaveLength(0);
      await putEmojiData([], 'en');
      expect(loadedLocales).toContain('en');
    });

    test('loads emoji into indexedDB', async () => {
      await putEmojiData([rawEmojiFactory()], 'en');
      const { db } = await testGet();
      await expect(db.get('en', 'test')).resolves.toEqual(
        unicodeEmojiFactory(),
      );
    });
  });

  describe('putCustomEmojiData', () => {
    test('loads custom emoji into indexedDB', async () => {
      const { db } = await testGet();
      await putCustomEmojiData({ emojis: [customEmojiFactory()] });
      await expect(db.get('custom', 'custom')).resolves.toEqual(
        customEmojiFactory(),
      );
    });

    test('clears existing custom emoji if specified', async () => {
      const { db } = await testGet();
      await putCustomEmojiData({
        emojis: [customEmojiFactory({ shortcode: 'emoji1' })],
      });
      await putCustomEmojiData({
        emojis: [customEmojiFactory({ shortcode: 'emoji2' })],
        clear: true,
      });
      await expect(db.get('custom', 'emoji1')).resolves.toBeUndefined();
      await expect(db.get('custom', 'emoji2')).resolves.toEqual(
        customEmojiFactory({ shortcode: 'emoji2', tokens: ['emoji2'] }),
      );
    });
  });

  describe('putLegacyShortcodes', () => {
    test('loads shortcodes into indexedDB', async () => {
      const { db } = await testGet();
      await putLegacyShortcodes({
        test_hexcode: ['shortcode1', 'shortcode2'],
      });
      await expect(db.get('shortcodes', 'test_hexcode')).resolves.toEqual({
        hexcode: 'test_hexcode',
        shortcodes: ['shortcode1', 'shortcode2'],
      });
    });
  });

  describe('loadEmojiByHexcode', () => {
    test('retrieves the emoji', async () => {
      await putEmojiData([unicodeEmojiFactory()], 'en');
      await expect(loadEmojiByHexcode('test', 'en')).resolves.toEqual(
        unicodeEmojiFactory(),
      );
    });

    test('returns undefined if not found', async () => {
      await putEmojiData([], 'en');
      await expect(loadEmojiByHexcode('test', 'en')).resolves.toBeUndefined();
    });
  });

  describe('loadLegacyShortcodesByShortcode', () => {
    const data = {
      hexcode: 'test_hexcode',
      shortcodes: ['shortcode1', 'shortcode2'],
    };

    beforeEach(async () => {
      await putLegacyShortcodes({
        [data.hexcode]: data.shortcodes,
      });
    });

    test('retrieves the shortcodes', async () => {
      await expect(
        loadLegacyShortcodesByShortcode('shortcode1'),
      ).resolves.toEqual(data);
      await expect(
        loadLegacyShortcodesByShortcode('shortcode2'),
      ).resolves.toEqual(data);
    });
  });

  describe('loadLatestEtag', () => {
    beforeEach(async () => {
      await putLatestEtag('etag', 'en');
      await putEmojiData([unicodeEmojiFactory()], 'en');
      await putLatestEtag('fr-etag', 'fr');
    });

    test('retrieves the etag for loaded locale', async () => {
      await putEmojiData(
        [unicodeEmojiFactory({ hexcode: EMOJI_DB_SHORTCODE_TEST })],
        'en',
      );
      const etag = await loadLatestEtag('en');
      expect(etag).toBe('etag');
    });

    test('returns null if locale has no shortcodes', async () => {
      const etag = await loadLatestEtag('en');
      expect(etag).toBeNull();
    });

    test('returns null if locale not loaded', async () => {
      const etag = await loadLatestEtag('de');
      expect(etag).toBeNull();
    });

    test('returns null if locale has no data', async () => {
      const etag = await loadLatestEtag('fr');
      expect(etag).toBeNull();
    });
  });
});
