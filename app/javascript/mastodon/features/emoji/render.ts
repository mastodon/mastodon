import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_TYPE_UNICODE,
  EMOJI_TYPE_CUSTOM,
} from './constants';
import { emojiToInversionClassName, unicodeHexToUrl } from './normalize';
import type {
  EmojiAppState,
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
        code,
        type: EMOJI_TYPE_CUSTOM,
      } satisfies EmojiStateCustom);
    } else {
      // Unicode emoji
      tokens.push({
        code,
        type: EMOJI_TYPE_UNICODE,
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
      code: emojiToUnicodeHex(code),
      type: EMOJI_TYPE_UNICODE,
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
 * Takes an element and emojifies all native emoji.
 */
export async function updateHtmlWithEmoji({
  assetHost,
  darkTheme,
  element,
  mode,
  locale,
}: {
  element: Element;
  locale: string;
} & Omit<EmojiAppState, 'currentLocale' | 'locales'>) {
  if (mode === EMOJI_MODE_NATIVE) {
    return;
  }

  const tokens = tokenizeText(element.innerHTML);
  const newChildren: (string | Element)[] = [];
  for (const token of tokens) {
    if (typeof token === 'string') {
      newChildren.push(token);
      continue;
    }

    const state = await loadEmojiDataToState(token, locale);
    // Ignore custom emoji if we encounter them.
    if (!state || state.type === EMOJI_TYPE_CUSTOM) {
      newChildren.push(token.code);
      continue;
    }

    if (!shouldRenderImage(state, mode)) {
      newChildren.push(state.data.unicode);
      continue;
    }

    const img = document.createElement('img');
    img.src = unicodeHexToUrl({
      assetHost,
      darkTheme,
      unicodeHex: state.data.hexcode,
    });
    img.alt = state.data.unicode;
    img.title = state.data.label;
    img.classList.add('emojione');

    const inversionClass = emojiToInversionClassName(state.data.unicode);
    if (inversionClass) {
      img.classList.add(inversionClass);
    }

    newChildren.push(img);
  }

  element.innerHTML = newChildren.reduce<string>(
    (prev, curr) =>
      typeof curr === 'string' ? prev + curr : prev + curr.outerHTML,
    '',
  );
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

  const code = isUnicodeEmoji(state.code)
    ? emojiToUnicodeHex(state.code)
    : state.code;

  // First, try to load the data from IndexedDB.
  try {
    const legacyCode = await loadLegacyShortcodesByShortcode(code);
    // This is duplicative, but that's because TS can't distinguish the state type easily.
    const data = await loadEmojiByHexcode(legacyCode?.hexcode ?? code, locale);
    if (data) {
      return {
        ...state,
        code,
        type: EMOJI_TYPE_UNICODE,
        data,
        // TODO: Use CLDR shortcodes when the picker supports them.
        shortcode: legacyCode?.shortcodes.at(0),
      };
    }

    // If not found, assume it's not an emoji and return null.
    log('Could not find emoji %s for locale %s', code, locale);
    return null;
  } catch (err: unknown) {
    // If the locale is not loaded, load it and retry once.
    if (!retry && err instanceof LocaleNotLoadedError) {
      log(
        'Error loading emoji %s for locale %s, loading locale and retrying.',
        code,
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
