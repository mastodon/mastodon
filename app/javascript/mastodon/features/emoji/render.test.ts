import { customEmojiFactory, unicodeEmojiFactory } from '@/testing/factories';

import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
} from './constants';
import * as db from './database';
import {
  emojifyElement,
  emojifyText,
  testCacheClear,
  tokenizeText,
} from './render';
import type { EmojiAppState, ExtraCustomEmojiMap } from './types';

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
const expectedCustomEmojiImage =
  '<img draggable="false" class="emojione custom-emoji" alt=":custom:" title=":custom:" src="emoji/custom/static" data-original="emoji/custom" data-static="emoji/custom/static">';
const expectedRemoteCustomEmojiImage =
  '<img draggable="false" class="emojione custom-emoji" alt=":remote:" title=":remote:" src="remote.social/static" data-original="remote.social/custom" data-static="remote.social/static">';

const mockExtraCustom: ExtraCustomEmojiMap = {
  remote: {
    shortcode: 'remote',
    static_url: 'remote.social/static',
    url: 'remote.social/custom',
  },
};

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
      'custom',
    ]);
  });

  test('emojifies custom emoji in native mode', async () => {
    const { searchEmojisByHexcodes } = mockDatabase();
    const actual = await emojifyElement(
      testElement(),
      testAppState({ mode: EMOJI_MODE_NATIVE }),
    );
    assert(actual);
    expect(actual.innerHTML).toBe(
      `<p>Hello 😊🇪🇺!</p><p>${expectedCustomEmojiImage}</p>`,
    );
    expect(searchEmojisByHexcodes).not.toHaveBeenCalled();
  });

  test('emojifies flag emoji in native-with-flags mode', async () => {
    const { searchEmojisByHexcodes } = mockDatabase();
    const actual = await emojifyElement(
      testElement(),
      testAppState({ mode: EMOJI_MODE_NATIVE_WITH_FLAGS }),
    );
    assert(actual);
    expect(actual.innerHTML).toBe(
      `<p>Hello 😊${expectedFlagImage}!</p><p>${expectedCustomEmojiImage}</p>`,
    );
    expect(searchEmojisByHexcodes).toHaveBeenCalledOnce();
  });

  test('emojifies everything in twemoji mode', async () => {
    const { searchCustomEmojisByShortcodes, searchEmojisByHexcodes } =
      mockDatabase();
    const actual = await emojifyElement(testElement(), testAppState());
    assert(actual);
    expect(actual.innerHTML).toBe(
      `<p>Hello ${expectedSmileImage}${expectedFlagImage}!</p><p>${expectedCustomEmojiImage}</p>`,
    );
    expect(searchEmojisByHexcodes).toHaveBeenCalledOnce();
    expect(searchCustomEmojisByShortcodes).toHaveBeenCalledOnce();
  });

  test('emojifies with provided custom emoji', async () => {
    const { searchCustomEmojisByShortcodes, searchEmojisByHexcodes } =
      mockDatabase();
    const actual = await emojifyElement(
      testElement('<p>hi :remote:</p>'),
      testAppState(),
      mockExtraCustom,
    );
    assert(actual);
    expect(actual.innerHTML).toBe(
      `<p>hi ${expectedRemoteCustomEmojiImage}</p>`,
    );
    expect(searchEmojisByHexcodes).not.toHaveBeenCalled();
    expect(searchCustomEmojisByShortcodes).not.toHaveBeenCalled();
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

  test('renders custom emojis', async () => {
    mockDatabase();
    const actual = await emojifyText('Hello :custom:!', testAppState());
    expect(actual).toBe(`Hello ${expectedCustomEmojiImage}!`);
  });

  test('renders provided extra emojis', async () => {
    const actual = await emojifyText(
      'remote emoji :remote:',
      testAppState(),
      mockExtraCustom,
    );
    expect(actual).toBe(`remote emoji ${expectedRemoteCustomEmojiImage}`);
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
