import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
} from './constants';
import { emojifyElement, tokenizeText } from './render';
import type { CustomEmojiData, UnicodeEmojiData } from './types';

vitest.mock('./database', () => ({
  searchCustomEmojisByShortcodes: vitest.fn(
    () =>
      [
        {
          shortcode: 'custom',
          static_url: 'emoji/static',
          url: 'emoji/custom',
          category: 'test',
          visible_in_picker: true,
        },
      ] satisfies CustomEmojiData[],
  ),
  searchEmojisByHexcodes: vitest.fn(
    () =>
      [
        {
          hexcode: '1F60A',
          group: 0,
          label: 'smiling face with smiling eyes',
          order: 0,
          tags: ['smile', 'happy'],
          unicode: '😊',
        },
        {
          hexcode: '1F1EA-1F1FA',
          group: 0,
          label: 'flag-eu',
          order: 0,
          tags: ['flag', 'european union'],
          unicode: '🇪🇺',
        },
      ] satisfies UnicodeEmojiData[],
  ),
  findMissingLocales: vitest.fn(() => []),
}));

describe('emojifyElement', () => {
  const testElement = document.createElement('div');
  testElement.innerHTML = '<p>Hello 😊🇪🇺!</p><p>:custom:</p>';

  const expectedSmileImage =
    '<img draggable="false" class="emojione" alt="😊" title="smiling face with smiling eyes" src="/emoji/1f60a.svg">';
  const expectedFlagImage =
    '<img draggable="false" class="emojione" alt="🇪🇺" title="flag-eu" src="/emoji/1f1ea-1f1fa.svg">';
  const expectedCustomEmojiImage =
    '<img draggable="false" class="emojione custom-emoji" alt=":custom:" title=":custom:" src="emoji/static" data-original="emoji/custom" data-static="emoji/static">';

  function cloneTestElement() {
    return testElement.cloneNode(true) as HTMLElement;
  }

  test('emojifies custom emoji in native mode', async () => {
    const emojifiedElement = await emojifyElement(cloneTestElement(), {
      locales: ['en'],
      mode: EMOJI_MODE_NATIVE,
      currentLocale: 'en',
    });
    expect(emojifiedElement.innerHTML).toBe(
      `<p>Hello 😊🇪🇺!</p><p>${expectedCustomEmojiImage}</p>`,
    );
  });

  test('emojifies flag emoji in native-with-flags mode', async () => {
    const emojifiedElement = await emojifyElement(cloneTestElement(), {
      locales: ['en'],
      mode: EMOJI_MODE_NATIVE_WITH_FLAGS,
      currentLocale: 'en',
    });
    expect(emojifiedElement.innerHTML).toBe(
      `<p>Hello 😊${expectedFlagImage}!</p><p>${expectedCustomEmojiImage}</p>`,
    );
  });

  test('emojifies everything in twemoji mode', async () => {
    const emojifiedElement = await emojifyElement(cloneTestElement(), {
      locales: ['en'],
      mode: EMOJI_MODE_TWEMOJI,
      currentLocale: 'en',
    });
    expect(emojifiedElement.innerHTML).toBe(
      `<p>Hello ${expectedSmileImage}${expectedFlagImage}!</p><p>${expectedCustomEmojiImage}</p>`,
    );
  });
});

describe('tokenizeText', () => {
  test('returns empty array for string with only whitespace', () => {
    expect(tokenizeText('   \n')).toEqual([]);
  });

  test('returns an array of text to be a single token', () => {
    expect(tokenizeText('Hello')).toEqual(['Hello']);
  });

  test('returns tokens for text with emoji', () => {
    expect(tokenizeText('Hello 😊 🇿🇼!!')).toEqual([
      'Hello ',
      {
        type: 'unicode',
        code: '😊',
      },
      ' ',
      {
        type: 'unicode',
        code: '🇿🇼',
      },
      '!!',
    ]);
  });

  test('returns tokens for text with custom emoji', () => {
    expect(tokenizeText('Hello :smile:!!')).toEqual([
      'Hello ',
      {
        type: 'custom',
        code: 'smile',
      },
      '!!',
    ]);
  });

  test('handles custom emoji with underscores and numbers', () => {
    expect(tokenizeText('Hello :smile_123:!!')).toEqual([
      'Hello ',
      {
        type: 'custom',
        code: 'smile_123',
      },
      '!!',
    ]);
  });

  test('returns tokens for text with mixed emoji', () => {
    expect(tokenizeText('Hello 😊 :smile:!!')).toEqual([
      'Hello ',
      {
        type: 'unicode',
        code: '😊',
      },
      ' ',
      {
        type: 'custom',
        code: 'smile',
      },
      '!!',
    ]);
  });

  test('does not capture custom emoji with invalid characters', () => {
    expect(tokenizeText('Hello :smile-123:!!')).toEqual([
      'Hello :smile-123:!!',
    ]);
  });
});
