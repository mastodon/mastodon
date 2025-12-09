import { IDBFactory } from 'fake-indexeddb';

import { customEmojiFactory, unicodeEmojiFactory } from '@/testing/factories';

import { EMOJI_DB_SHORTCODE_TEST } from './constants';
import {
  putEmojiData,
  loadEmojiByHexcode,
  searchEmojisByHexcodes,
  searchEmojisByTag,
  testClear,
  testGet,
  putCustomEmojiData,
  putLegacyShortcodes,
  loadLegacyShortcodesByShortcode,
  loadLatestEtag,
  putLatestEtag,
} from './database';

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
      await putEmojiData([unicodeEmojiFactory()], 'en');
      const { db } = await testGet();
      await expect(db.get('en', 'test')).resolves.toEqual(
        unicodeEmojiFactory(),
      );
    });
  });

  describe('putCustomEmojiData', () => {
    test('loads custom emoji into indexedDB', async () => {
      const { db } = await testGet();
      await putCustomEmojiData([customEmojiFactory()]);
      await expect(db.get('custom', 'custom')).resolves.toEqual(
        customEmojiFactory(),
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
    test('throws if the locale is not loaded', async () => {
      await expect(loadEmojiByHexcode('en', 'test')).rejects.toThrowError(
        'Locale en',
      );
    });

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

  describe('searchEmojisByHexcodes', () => {
    const data = [
      unicodeEmojiFactory({ hexcode: 'not a number' }),
      unicodeEmojiFactory({ hexcode: '1' }),
      unicodeEmojiFactory({ hexcode: '2' }),
      unicodeEmojiFactory({ hexcode: '3' }),
      unicodeEmojiFactory({ hexcode: 'another not a number' }),
    ];
    beforeEach(async () => {
      await putEmojiData(data, 'en');
    });
    test('finds emoji in consecutive range', async () => {
      const actual = await searchEmojisByHexcodes(['1', '2', '3'], 'en');
      expect(actual).toHaveLength(3);
    });

    test('finds emoji in split range', async () => {
      const actual = await searchEmojisByHexcodes(['1', '3'], 'en');
      expect(actual).toHaveLength(2);
      expect(actual).toContainEqual(data.at(1));
      expect(actual).toContainEqual(data.at(3));
    });

    test('finds emoji with non-numeric range', async () => {
      const actual = await searchEmojisByHexcodes(
        ['3', 'not a number', '1'],
        'en',
      );
      expect(actual).toHaveLength(3);
      expect(actual).toContainEqual(data.at(0));
      expect(actual).toContainEqual(data.at(1));
      expect(actual).toContainEqual(data.at(3));
    });

    test('not found emoji are not returned', async () => {
      const actual = await searchEmojisByHexcodes(['not found'], 'en');
      expect(actual).toHaveLength(0);
    });

    test('only found emojis are returned', async () => {
      const actual = await searchEmojisByHexcodes(
        ['another not a number', 'not found'],
        'en',
      );
      expect(actual).toHaveLength(1);
      expect(actual).toContainEqual(data.at(4));
    });
  });

  describe('searchEmojisByTag', () => {
    const data = [
      unicodeEmojiFactory({ hexcode: 'test1', tags: ['test 1'] }),
      unicodeEmojiFactory({
        hexcode: 'test2',
        tags: ['test 2', 'something else'],
      }),
      unicodeEmojiFactory({ hexcode: 'test3', tags: ['completely different'] }),
    ];
    beforeEach(async () => {
      await putEmojiData(data, 'en');
    });
    test('finds emojis with tag', async () => {
      const actual = await searchEmojisByTag('test 1', 'en');
      expect(actual).toHaveLength(1);
      expect(actual).toContainEqual(data.at(0));
    });

    test('finds emojis starting with tag', async () => {
      const actual = await searchEmojisByTag('test', 'en');
      expect(actual).toHaveLength(2);
      expect(actual).not.toContainEqual(data.at(2));
    });

    test('does not find emojis ending with tag', async () => {
      const actual = await searchEmojisByTag('else', 'en');
      expect(actual).toHaveLength(0);
    });

    test('finds nothing with invalid tag', async () => {
      const actual = await searchEmojisByTag('not found', 'en');
      expect(actual).toHaveLength(0);
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
