import { customEmojiFactory, unicodeEmojiFactory } from '@/testing/factories';

import { EMOJI_MODE_TWEMOJI } from './constants';
import * as db from './database';
import * as loader from './loader';
import {
  loadEmojiDataToState,
  stringToEmojiState,
  tokenizeText,
  updateHtmlWithEmoji,
} from './render';
import type { EmojiStateCustom, EmojiStateUnicode } from './types';

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

describe('stringToEmojiState', () => {
  test('returns unicode emoji state for valid unicode emoji', () => {
    expect(stringToEmojiState('😊')).toEqual({
      type: 'unicode',
      code: '1F60A',
    });
  });

  test('returns null for custom emoji without data', () => {
    expect(stringToEmojiState(':smile:')).toBeNull();
  });

  test('returns custom emoji state with data when provided', () => {
    const customEmoji = {
      smile: customEmojiFactory({
        shortcode: 'smile',
        url: 'https://example.com/smile.png',
        static_url: 'https://example.com/smile_static.png',
      }),
    };
    expect(stringToEmojiState(':smile:', customEmoji)).toEqual({
      type: 'custom',
      code: 'smile',
      data: customEmoji.smile,
    });
  });

  test('returns null for invalid emoji strings', () => {
    expect(stringToEmojiState('notanemoji')).toBeNull();
  });
});

describe('updateHtmlWithEmoji', () => {
  const defaultOptions = {
    assetHost: '',
    darkTheme: false,
    mode: EMOJI_MODE_TWEMOJI,
    locale: 'en',
  } as const;

  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('updates element text with emojis', async () => {
    const element = document.createElement('div');
    element.textContent = '😊';

    vi.spyOn(db, 'loadLegacyShortcodesByShortcode').mockResolvedValueOnce(
      undefined,
    );
    vi.spyOn(db, 'loadEmojiByHexcode').mockResolvedValueOnce(
      unicodeEmojiFactory(),
    );

    await updateHtmlWithEmoji({
      ...defaultOptions,
      element,
    });

    const img = element.querySelector('img');
    expect(img).toBeDefined();
  });

  test('does not update element text when mode is native', async () => {
    const element = document.createElement('div');
    element.textContent = '😊';

    const dbShortcodeCall = vi.spyOn(db, 'loadLegacyShortcodesByShortcode');
    const dbEmojiCall = vi.spyOn(db, 'loadEmojiByHexcode');

    await updateHtmlWithEmoji({
      ...defaultOptions,
      mode: 'native',
      element,
    });

    expect(dbShortcodeCall).not.toHaveBeenCalled();
    expect(dbEmojiCall).not.toHaveBeenCalled();
    expect(element.textContent).toBe('😊');
  });

  test('does not try to load custom emojis', async () => {
    const element = document.createElement('div');
    element.textContent = ':smile:';

    const dbShortcodeCall = vi.spyOn(db, 'loadLegacyShortcodesByShortcode');
    const dbEmojiCall = vi.spyOn(db, 'loadEmojiByHexcode');

    await updateHtmlWithEmoji({
      ...defaultOptions,
      element,
    });

    expect(dbShortcodeCall).not.toHaveBeenCalled();
    expect(dbEmojiCall).not.toHaveBeenCalled();
    expect(element.textContent).toBe(':smile:');
  });
});

describe('loadEmojiDataToState', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  test('loads unicode data into state', async () => {
    const dbCall = vi
      .spyOn(db, 'loadEmojiByHexcode')
      .mockResolvedValue(unicodeEmojiFactory());
    const dbLegacyCall = vi
      .spyOn(db, 'loadLegacyShortcodesByShortcode')
      .mockResolvedValueOnce({
        shortcodes: ['legacy_code'],
        hexcode: '1F60A',
      });
    const unicodeState = {
      type: 'unicode',
      code: '1F60A',
    } as const satisfies EmojiStateUnicode;
    const result = await loadEmojiDataToState(unicodeState, 'en');
    expect(dbCall).toHaveBeenCalledWith('1F60A', 'en');
    expect(dbLegacyCall).toHaveBeenCalledWith('1F60A');
    expect(result).toEqual({
      type: 'unicode',
      code: '1F60A',
      data: unicodeEmojiFactory(),
      shortcode: 'legacy_code',
    });
  });

  test('converts unicode emoji code to hexcode when loading data', async () => {
    const dbCall = vi
      .spyOn(db, 'loadEmojiByHexcode')
      .mockResolvedValue(unicodeEmojiFactory());
    const unicodeState = {
      type: 'unicode',
      code: '😊',
    } as const satisfies EmojiStateUnicode;
    await loadEmojiDataToState(unicodeState, 'en');
    expect(dbCall).toHaveBeenCalledWith('1F60A', 'en');
  });

  test('returns null for custom emoji without data', async () => {
    const customState = {
      type: 'custom',
      code: 'smile',
    } as const satisfies EmojiStateCustom;
    const result = await loadEmojiDataToState(customState, 'en');
    expect(result).toBeNull();
  });

  test('loads unicode data using legacy shortcode', async () => {
    const dbLegacyCall = vi
      .spyOn(db, 'loadLegacyShortcodesByShortcode')
      .mockResolvedValueOnce({
        shortcodes: ['test'],
        hexcode: 'test',
      });
    const dbUnicodeCall = vi
      .spyOn(db, 'loadEmojiByHexcode')
      .mockResolvedValue(unicodeEmojiFactory());
    const unicodeState = {
      type: 'unicode',
      code: 'test',
    } as const satisfies EmojiStateUnicode;
    const result = await loadEmojiDataToState(unicodeState, 'en');
    expect(dbLegacyCall).toHaveBeenCalledWith('test');
    expect(dbUnicodeCall).toHaveBeenCalledWith('test', 'en');
    expect(result).toEqual({
      type: 'unicode',
      code: 'test',
      data: unicodeEmojiFactory(),
      shortcode: 'test',
    });
  });

  test('returns null if unicode emoji not found in database', async () => {
    vi.spyOn(db, 'loadEmojiByHexcode').mockResolvedValueOnce(undefined);
    const unicodeState = {
      type: 'unicode',
      code: '1F60A',
    } as const satisfies EmojiStateUnicode;
    const result = await loadEmojiDataToState(unicodeState, 'en');
    expect(result).toBeNull();
  });

  test('retries loading emoji data once if initial load fails', async () => {
    const dbCall = vi
      .spyOn(db, 'loadEmojiByHexcode')
      .mockRejectedValue(new db.LocaleNotLoadedError('en'));
    vi.spyOn(loader, 'importEmojiData').mockResolvedValueOnce(undefined);
    const consoleCall = vi
      .spyOn(console, 'warn')
      .mockImplementationOnce(() => null);

    const unicodeState = {
      type: 'unicode',
      code: '1F60A',
    } as const satisfies EmojiStateUnicode;
    const result = await loadEmojiDataToState(unicodeState, 'en');

    expect(dbCall).toHaveBeenCalledTimes(2);
    expect(loader.importEmojiData).toHaveBeenCalledWith('en');
    expect(consoleCall).toHaveBeenCalled();
    expect(result).toBeNull();
  });
});
