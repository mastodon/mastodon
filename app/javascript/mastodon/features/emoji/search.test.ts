import type { CompactEmoji } from 'emojibase';

import { unicodeEmojiFactory, customEmojiFactory } from '@/testing/factories';

import {
  putEmojiData,
  putCustomEmojiData,
  putLegacyShortcodes,
  testGet,
  testClear,
} from './database';
import { search } from './search';

function rawEmojiFactory(data: Partial<CompactEmoji> = {}): CompactEmoji {
  const factory = unicodeEmojiFactory();
  return {
    ...factory,
    ...data,
    tags: data.tags ?? factory.tokens,
  };
}

describe('search', () => {
  beforeEach(async () => {
    await testGet(); // Loads the database schema.
    await putEmojiData([], 'en');
  });

  afterEach(() => {
    testClear();
    indexedDB = new IDBFactory();
  });

  test('test no query tokens', async () => {
    await putEmojiData([rawEmojiFactory()], 'en');
    await expect(search({ query: '   ', locale: 'en' })).resolves.toEqual([]);
  });

  test('unicode results', async () => {
    await putEmojiData(
      [
        rawEmojiFactory({
          hexcode: 'unicode_hex',
          label: 'Party Popper',
          shortcodes: ['party_popper'],
          unicode: '🎉',
        }),
      ],
      'en',
    );

    await expect(
      search({ query: 'party', locale: 'en' }),
    ).resolves.toContainEqual(
      expect.objectContaining({
        hexcode: 'unicode_hex',
      }),
    );
  });

  test('custom results', async () => {
    await putCustomEmojiData({
      emojis: [customEmojiFactory({ shortcode: 'party_custom' })],
    });

    await expect(
      search({ query: 'party', locale: 'en' }),
    ).resolves.toContainEqual(
      expect.objectContaining({
        shortcode: 'party_custom',
      }),
    );
  });

  test('shortcode results', async () => {
    await putEmojiData([rawEmojiFactory()], 'en');
    await putLegacyShortcodes({
      test: ['legacy_smile'],
    });

    await expect(
      search({ query: 'legacy', locale: 'en' }),
    ).resolves.toContainEqual(
      expect.objectContaining({
        hexcode: 'test',
      }),
    );
  });

  test('full custom emoji search', async () => {
    await putCustomEmojiData({
      emojis: [
        customEmojiFactory({ shortcode: 'arrow' }),
        customEmojiFactory({ shortcode: 'party_parrot' }),
      ],
    });

    const result = await search({ query: 'arro', locale: 'en' });
    expect(result).toContainEqual(
      // Test for ordinary IDB search
      expect.objectContaining({
        shortcode: 'arrow',
      }),
    );
    expect(result).toContainEqual(
      // Test for manual iteration search
      expect.objectContaining({
        shortcode: 'party_parrot',
      }),
    );
  });

  test('limit test', async () => {
    await putCustomEmojiData({
      emojis: [
        customEmojiFactory({ shortcode: 'limit' }),
        customEmojiFactory({ shortcode: 'limit_extra' }),
      ],
    });

    await expect(
      search({ query: 'limit', locale: 'en', limit: 1 }),
    ).resolves.toEqual([
      expect.objectContaining({
        shortcode: 'limit',
      }),
    ]);
  });

  test('prefix matches', async () => {
    await putCustomEmojiData({
      emojis: [
        customEmojiFactory({ shortcode: 'sob_other' }),
        customEmojiFactory({ shortcode: 'meow_sob' }),
      ],
    });
    await putEmojiData(
      [
        rawEmojiFactory({
          label: 'loudly crying face',
          hexcode: '1F62D',
          shortcodes: ['loudly_crying_face'],
          tags: ['bawling', 'cry', 'sad', 'sob', 'tear', 'tears', 'unhappy'],
          emoticon: ":'o",
          unicode: '😭',
        }),
      ],
      'en',
    );

    const results = await search({ query: 'sob', locale: 'en' });

    expect(results).toHaveLength(3);
    expect(results).toEqual([
      expect.objectContaining({ shortcode: 'sob_other' }),
      expect.objectContaining({ shortcode: 'meow_sob' }),
      expect.objectContaining({ hexcode: '1F62D' }),
    ]);
  });

  test('shortcode matches', async () => {
    await putLegacyShortcodes({ '1F62D': 'sob' });
    await putEmojiData(
      [
        rawEmojiFactory({
          label: 'loudly crying face',
          hexcode: '1F62D',
          shortcodes: ['loudly_crying_face'],
          tags: ['bawling', 'cry', 'sad', 'sob', 'tear', 'tears', 'unhappy'],
          emoticon: ":'o",
          unicode: '😭',
        }),
      ],
      'en',
    );
    await putCustomEmojiData({
      emojis: [customEmojiFactory({ shortcode: 'sob_other' })],
    });

    const results = await search({ query: 'sob', locale: 'en' });

    expect(results).toHaveLength(2);
    expect(results).toEqual([
      expect.objectContaining({ hexcode: '1F62D' }),
      expect.objectContaining({ shortcode: 'sob_other' }),
    ]);
  });
});
