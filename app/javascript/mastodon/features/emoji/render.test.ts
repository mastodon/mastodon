import { customEmojiFactory, unicodeEmojiFactory } from '@/testing/factories';

import { EMOJI_MODE_TWEMOJI } from './constants';
import * as db from './database';
import {
  emojifyElement,
  emojifyText,
  testCacheClear,
  tokenizeText,
} from './render';
import type { EmojiAppState } from './types';

function mockDatabase() {
  return {
    searchCustomEmojisByShortcodes: vi
      .spyOn(db, 'searchCustomEmojisByShortcodes')
      .mockResolvedValue([customEmojiFactory()]),
    searchEmojisByHexcodes: vi
      .spyOn(db, 'searchEmojisByHexcodes')
      .mockResolvedValue([
        unicodeEmojiFactory({
          hexcode: '1F60A',
          label: 'smiling face with smiling eyes',
          unicode: '😊',
        }),
        unicodeEmojiFactory({
          hexcode: '1F1EA-1F1FA',
          label: 'flag-eu',
          unicode: '🇪🇺',
        }),
      ]),
  };
}

const expectedSmileImage =
  '<img draggable="false" class="emojione" alt="😊" title="smiling face with smiling eyes" src="/emoji/1f60a.svg">';
const expectedFlagImage =
  '<img draggable="false" class="emojione" alt="🇪🇺" title="flag-eu" src="/emoji/1f1ea-1f1fa.svg">';

function testAppState(state: Partial<EmojiAppState> = {}) {
  return {
    locales: ['en'],
    mode: EMOJI_MODE_TWEMOJI,
    currentLocale: 'en',
    darkTheme: false,
    ...state,
  } satisfies EmojiAppState;
}

describe('emojifyElement', () => {
  function testElement(text = '<p>Hello 😊🇪🇺!</p><p>:custom:</p>') {
    const testElement = document.createElement('div');
    testElement.innerHTML = text;
    return testElement;
  }

  afterEach(() => {
    testCacheClear();
    vi.restoreAllMocks();
  });

  test('caches element rendering results', async () => {
    const { searchCustomEmojisByShortcodes, searchEmojisByHexcodes } =
      mockDatabase();
    await emojifyElement(testElement(), testAppState());
    await emojifyElement(testElement(), testAppState());
    await emojifyElement(testElement(), testAppState());
    expect(searchEmojisByHexcodes).toHaveBeenCalledExactlyOnceWith(
      ['1F1EA-1F1FA', '1F60A'],
      'en',
    );
    expect(searchCustomEmojisByShortcodes).toHaveBeenCalledExactlyOnceWith([
      ':custom:',
    ]);
  });

  test('returns null when no emoji are found', async () => {
    mockDatabase();
    const actual = await emojifyElement(
      testElement('<p>here is just text :)</p>'),
      testAppState(),
    );
    expect(actual).toBeNull();
  });
});

describe('emojifyText', () => {
  test('returns original input when no emoji are in string', async () => {
    const actual = await emojifyText('nothing here', testAppState());
    expect(actual).toBe('nothing here');
  });

  test('renders Unicode emojis to twemojis', async () => {
    mockDatabase();
    const actual = await emojifyText('Hello 😊🇪🇺!', testAppState());
    expect(actual).toBe(`Hello ${expectedSmileImage}${expectedFlagImage}!`);
  });
});

describe('tokenizeText', () => {
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
        code: ':smile:',
      },
      '!!',
    ]);
  });

  test('handles custom emoji with underscores and numbers', () => {
    expect(tokenizeText('Hello :smile_123:!!')).toEqual([
      'Hello ',
      {
        type: 'custom',
        code: ':smile_123:',
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
        code: ':smile:',
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
