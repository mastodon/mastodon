import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_TYPE_UNICODE,
  EMOJI_TYPE_CUSTOM,
} from './constants';
import type {
  EmojiLoadedState,
  EmojiMode,
  EmojiState,
  EmojiStateCustom,
  EmojiStateUnicode,
  ExtraCustomEmojiMap,
} from './types';
import {
  anyEmojiRegex,
  emojiLogger,
  emojiToUnicodeHex,
  isCustomEmoji,
  isUnicodeEmoji,
  stringHasUnicodeFlags,
} from './utils';

const log = emojiLogger('render');

type TokenizedText = (string | EmojiState)[];

/**
 * Tokenizes text into strings and emoji states.
 * @param text Text to tokenize.
 * @returns Array of strings and emoji states.
 */
export function tokenizeText(text: string): TokenizedText {
  if (!text.trim()) {
    return [text];
  }

  const tokens = [];
  let lastIndex = 0;
  for (const match of text.matchAll(anyEmojiRegex())) {
    if (match.index > lastIndex) {
      tokens.push(text.slice(lastIndex, match.index));
    }

    const code = match[0];

    if (code.startsWith(':') && code.endsWith(':')) {
      // Custom emoji
      tokens.push({
        type: EMOJI_TYPE_CUSTOM,
        code,
      } satisfies EmojiStateCustom);
    } else {
      // Unicode emoji
      tokens.push({
        type: EMOJI_TYPE_UNICODE,
        code: code,
      } satisfies EmojiStateUnicode);
    }
    lastIndex = match.index + code.length;
  }
  if (lastIndex < text.length) {
    tokens.push(text.slice(lastIndex));
  }
  return tokens;
}

/**
 * Parses emoji string to extract emoji state.
 * @param code Hex code or custom shortcode.
 * @param customEmoji Extra custom emojis.
 */
export function stringToEmojiState(
  code: string,
  customEmoji: ExtraCustomEmojiMap = {},
): EmojiStateUnicode | Required<EmojiStateCustom> | null {
  if (isUnicodeEmoji(code)) {
    return {
      type: EMOJI_TYPE_UNICODE,
      code: emojiToUnicodeHex(code),
    };
  }

  if (isCustomEmoji(code)) {
    const shortCode = code.slice(1, -1);
    if (customEmoji[shortCode]) {
      return {
        type: EMOJI_TYPE_CUSTOM,
        code: shortCode,
        data: customEmoji[shortCode],
      };
    }
  }

  return null;
}

/**
 * Loads emoji data into the given state if not already loaded.
 * @param state Emoji state to load data for.
 * @param locale Locale to load data for. Only for Unicode emoji.
 * @param retry Internal. Whether this is a retry after loading the locale.
 */
export async function loadEmojiDataToState(
  state: EmojiState,
  locale: string,
  retry = false,
): Promise<EmojiLoadedState | null> {
  if (isStateLoaded(state)) {
    return state;
  }

  // Don't try to load data for custom emoji.
  if (state.type === EMOJI_TYPE_CUSTOM) {
    return null;
  }

  const {
    loadLegacyShortcodesByShortcode,
    loadEmojiByHexcode,
    LocaleNotLoadedError,
  } = await import('./database');

  // First, try to load the data from IndexedDB.
  try {
    const legacyCode = await loadLegacyShortcodesByShortcode(state.code);
    // This is duplicative, but that's because TS can't distinguish the state type easily.
    const data = await loadEmojiByHexcode(
      legacyCode?.hexcode ?? state.code,
      locale,
    );
    if (data) {
      return {
        ...state,
        type: EMOJI_TYPE_UNICODE,
        data,
        // TODO: Use CLDR shortcodes when the picker supports them.
        shortcode: legacyCode?.shortcodes.at(0),
      };
    }

    // If not found, assume it's not an emoji and return null.
    log('Could not find emoji %s for locale %s', state.code, locale);
    return null;
  } catch (err: unknown) {
    // If the locale is not loaded, load it and retry once.
    if (!retry && err instanceof LocaleNotLoadedError) {
      log(
        'Error loading emoji %s for locale %s, loading locale and retrying.',
        state.code,
        locale,
      );
      const { importEmojiData } = await import('./loader');
      await importEmojiData(locale); // Use this from the loader file as it can be awaited.
      return loadEmojiDataToState(state, locale, true);
    }

    console.warn('Error loading emoji data, not retrying:', state, locale, err);
    return null;
  }
}

export function isStateLoaded(state: EmojiState): state is EmojiLoadedState {
  return !!state.data;
}

/**
 * Determines if the given token should be rendered as an image based on the emoji mode.
 * @param state Emoji state to parse.
 * @param mode Rendering mode.
 * @returns Whether to render as an image.
 */
export function shouldRenderImage(state: EmojiState, mode: EmojiMode): boolean {
  if (state.type === EMOJI_TYPE_UNICODE) {
    // If the mode is native or native with flags for non-flag emoji
    // we can just append the text node directly.
    if (
      mode === EMOJI_MODE_NATIVE ||
      (mode === EMOJI_MODE_NATIVE_WITH_FLAGS &&
        !stringHasUnicodeFlags(state.code))
    ) {
      return false;
    }
  }

  return true;
}
