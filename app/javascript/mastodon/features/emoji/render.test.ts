import { customEmojiFactory, unicodeEmojiFactory } from '@/testing/factories';

import * as db from './database';
import * as loader from './loader';
import {
  loadEmojiDataToState,
  stringToEmojiState,
  tokenizeText,
} from './render';

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

  test('returns custom emoji state for valid custom emoji', () => {
    expect(stringToEmojiState(':smile:')).toEqual({
      type: 'custom',
      code: 'smile',
      data: undefined,
    });
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
    expect(stringToEmojiState(':invalid-emoji:')).toBeNull();
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
    const unicodeState = { type: 'unicode', code: '1F60A' } as const;
    const result = await loadEmojiDataToState(unicodeState, 'en');
    expect(dbCall).toHaveBeenCalledWith('1F60A', 'en');
    expect(result).toEqual({
      type: 'unicode',
      code: '1F60A',
      data: unicodeEmojiFactory(),
    });
  });

  test('loads custom emoji data into state', async () => {
    const dbCall = vi
      .spyOn(db, 'loadCustomEmojiByShortcode')
      .mockResolvedValueOnce(customEmojiFactory());
    const customState = { type: 'custom', code: 'smile' } as const;
    const result = await loadEmojiDataToState(customState, 'en');
    expect(dbCall).toHaveBeenCalledWith('smile');
    expect(result).toEqual({
      type: 'custom',
      code: 'smile',
      data: customEmojiFactory(),
    });
  });

  test('returns null if unicode emoji not found in database', async () => {
    vi.spyOn(db, 'loadEmojiByHexcode').mockResolvedValueOnce(undefined);
    const unicodeState = { type: 'unicode', code: '1F60A' } as const;
    const result = await loadEmojiDataToState(unicodeState, 'en');
    expect(result).toBeNull();
  });

  test('returns null if custom emoji not found in database', async () => {
    vi.spyOn(db, 'loadCustomEmojiByShortcode').mockResolvedValueOnce(undefined);
    const customState = { type: 'custom', code: 'smile' } as const;
    const result = await loadEmojiDataToState(customState, 'en');
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

    const unicodeState = { type: 'unicode', code: '1F60A' } as const;
    const result = await loadEmojiDataToState(unicodeState, 'en');

    expect(dbCall).toHaveBeenCalledTimes(2);
    expect(loader.importEmojiData).toHaveBeenCalledWith('en');
    expect(consoleCall).toHaveBeenCalled();
    expect(result).toBeNull();
  });
});
