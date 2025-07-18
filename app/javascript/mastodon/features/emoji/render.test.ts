import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
} from './constants';
import { emojifyElement, tokenizeText } from './render';

describe('emojifyElement', () => {
  const testElement = document.createElement('div');
  testElement.innerHTML = '<p>Hello 😊🇪🇺!</p><p>:custom:</p>';

  test('emojifies custom emoji in native mode', async () => {
    const emojifiedElement = await emojifyElement(testElement, {
      locales: ['en'],
      mode: EMOJI_MODE_NATIVE,
      currentLocale: 'en',
    });
    expect(emojifiedElement.innerHTML).toBe(
      '<p>Hello 😊🇪🇺!</p>' +
        '<p><img draggable="false" class="emojione custom-emoji" alt=":custom:" title=":custom:"></p>',
    );
  });

  test('emojifies flag emoji in native-with-flags mode', async () => {
    const emojifiedElement = await emojifyElement(testElement, {
      locales: ['en'],
      mode: EMOJI_MODE_NATIVE_WITH_FLAGS,
      currentLocale: 'en',
    });
    expect(emojifiedElement.innerHTML).toBe(
      '<p>Hello 😊<img draggable="false" class="emojione" alt="🇪🇺" data-code="1F1EA-1F1FA">!</p>' +
        '<p><img draggable="false" class="emojione custom-emoji" alt=":custom:" title=":custom:"></p>',
    );
  });

  test('emojifies everything in twemoji mode', async () => {
    const emojifiedElement = await emojifyElement(testElement, {
      locales: ['en'],
      mode: EMOJI_MODE_TWEMOJI,
      currentLocale: 'en',
    });
    expect(emojifiedElement.innerHTML).toBe(
      '<p>Hello <img draggable="false" class="emojione" alt="😊" data-code="1F60A">' +
        '<img draggable="false" class="emojione" alt="🇪🇺" data-code="1F1EA-1F1FA">!</p>' +
        '<p><img draggable="false" class="emojione custom-emoji" alt=":custom:" title=":custom:"></p>',
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
