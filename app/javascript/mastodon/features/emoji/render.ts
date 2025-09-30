import { autoPlayGif } from '@/mastodon/initial_state';
import { createLimitedCache } from '@/mastodon/utils/cache';
import * as perf from '@/mastodon/utils/performance';

import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_TYPE_UNICODE,
  EMOJI_TYPE_CUSTOM,
} from './constants';
import {
  loadCustomEmojiByShortcode,
  loadEmojiByHexcode,
  LocaleNotLoadedError,
  searchCustomEmojisByShortcodes,
  searchEmojisByHexcodes,
} from './database';
import { importEmojiData } from './loader';
import { emojiToUnicodeHex, unicodeHexToUrl } from './normalize';
import type {
  EmojiAppState,
  EmojiLoadedState,
  EmojiMode,
  EmojiState,
  EmojiStateCustom,
  EmojiStateMap,
  EmojiStateUnicode,
  ExtraCustomEmojiMap,
  LocaleOrCustom,
} from './types';
import {
  anyEmojiRegex,
  emojiLogger,
  isCustomEmoji,
  isUnicodeEmoji,
  stringHasAnyEmoji,
  stringHasUnicodeFlags,
} from './utils';

const log = emojiLogger('render');

/**
 * Parses emoji string to extract emoji state.
 * @param code Hex code or custom shortcode.
 * @param customEmoji Extra custom emojis.
 */
export function stringToEmojiState(
  code: string,
  customEmoji: ExtraCustomEmojiMap = {},
): EmojiState | null {
  if (isUnicodeEmoji(code)) {
    return {
      type: EMOJI_TYPE_UNICODE,
      code: emojiToUnicodeHex(code),
    };
  }

  if (isCustomEmoji(code)) {
    const shortCode = code.slice(1, -1);
    return {
      type: EMOJI_TYPE_CUSTOM,
      code: shortCode,
      data: customEmoji[shortCode],
    };
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

  // First, try to load the data from IndexedDB.
  try {
    // This is duplicative, but that's because TS can't distinguish the state type easily.
    if (state.type === EMOJI_TYPE_UNICODE) {
      const data = await loadEmojiByHexcode(state.code, locale);
      if (data) {
        return {
          ...state,
          data,
        };
      }
    } else {
      const data = await loadCustomEmojiByShortcode(state.code);
      if (data) {
        return {
          ...state,
          data,
        };
      }
    }
    // If not found, assume it's not an emoji and return null.
    log(
      'Could not find emoji %s of type %s for locale %s',
      state.code,
      state.type,
      locale,
    );
    return null;
  } catch (err: unknown) {
    // If the locale is not loaded, load it and retry once.
    if (!retry && err instanceof LocaleNotLoadedError) {
      log(
        'Error loading emoji %s for locale %s, loading locale and retrying.',
        state.code,
        locale,
      );
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
 * Emojifies an element. This modifies the element in place, replacing text nodes with emojified versions.
 */
export async function emojifyElement<Element extends HTMLElement>(
  element: Element,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): Promise<Element | null> {
  const cacheKey = createCacheKey(element, appState, extraEmojis);
  const cached = getCached(cacheKey);
  if (cached !== undefined) {
    log('Cache hit on %s', element.outerHTML);
    if (cached === null) {
      return null;
    }
    element.innerHTML = cached;
    return element;
  }
  if (!stringHasAnyEmoji(element.innerHTML)) {
    updateCache(cacheKey, null);
    return null;
  }
  perf.start('emojifyElement()');
  const queue: (HTMLElement | Text)[] = [element];
  while (queue.length > 0) {
    const current = queue.shift();
    if (
      !current ||
      current instanceof HTMLScriptElement ||
      current instanceof HTMLStyleElement
    ) {
      continue;
    }

    if (
      current.textContent &&
      (current instanceof Text || !current.hasChildNodes())
    ) {
      const renderedContent = await textToElementArray(
        current.textContent,
        appState,
        extraEmojis,
      );
      if (renderedContent) {
        if (!(current instanceof Text)) {
          current.textContent = null; // Clear the text content if it's not a Text node.
        }
        current.replaceWith(renderedToHTML(renderedContent));
      }
      continue;
    }

    for (const child of current.childNodes) {
      if (child instanceof HTMLElement || child instanceof Text) {
        queue.push(child);
      }
    }
  }
  updateCache(cacheKey, element.innerHTML);
  perf.stop('emojifyElement()');
  return element;
}

export async function emojifyText(
  text: string,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): Promise<string | null> {
  const cacheKey = createCacheKey(text, appState, extraEmojis);
  const cached = getCached(cacheKey);
  if (cached !== undefined) {
    log('Cache hit on %s', text);
    return cached ?? text;
  }
  if (!stringHasAnyEmoji(text)) {
    updateCache(cacheKey, null);
    return text;
  }
  const eleArray = await textToElementArray(text, appState, extraEmojis);
  if (!eleArray) {
    updateCache(cacheKey, null);
    return text;
  }
  const rendered = renderedToHTML(eleArray, document.createElement('div'));
  updateCache(cacheKey, rendered.innerHTML);
  return rendered.innerHTML;
}

// Private functions

const {
  set: updateCache,
  get: getCached,
  clear: cacheClear,
} = createLimitedCache<string | null>({ log: log.extend('cache') });

function createCacheKey(
  input: HTMLElement | string,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap,
) {
  return JSON.stringify([
    input instanceof HTMLElement ? input.outerHTML : input,
    appState,
    extraEmojis,
  ]);
}

type EmojifiedTextArray = (string | HTMLImageElement)[];

async function textToElementArray(
  text: string,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): Promise<EmojifiedTextArray | null> {
  // Exit if no text to convert.
  if (!text.trim()) {
    return null;
  }

  const tokens = tokenizeText(text);

  // If only one token and it's a string, exit early.
  if (tokens.length === 1 && typeof tokens[0] === 'string') {
    return null;
  }

  // Get all emoji from the state map, loading any missing ones.
  await loadMissingEmojiIntoCache(tokens, appState, extraEmojis);

  const renderedFragments: EmojifiedTextArray = [];
  for (const token of tokens) {
    if (typeof token !== 'string' && shouldRenderImage(token, appState.mode)) {
      let state: EmojiState | undefined;
      if (token.type === EMOJI_TYPE_CUSTOM) {
        const extraEmojiData = extraEmojis[token.code];
        if (extraEmojiData) {
          state = {
            type: EMOJI_TYPE_CUSTOM,
            data: extraEmojiData,
            code: token.code,
          };
        } else {
          state = emojiForLocale(token.code, EMOJI_TYPE_CUSTOM);
        }
      } else {
        state = emojiForLocale(
          emojiToUnicodeHex(token.code),
          appState.currentLocale,
        );
      }

      // If the state is valid, create an image element. Otherwise, just append as text.
      if (state && typeof state !== 'string' && isStateLoaded(state)) {
        const image = stateToImage(state, appState);
        renderedFragments.push(image);
        continue;
      }
    }
    const text = typeof token === 'string' ? token : token.code;
    renderedFragments.push(text);
  }

  return renderedFragments;
}

type TokenizedText = (string | EmojiState)[];

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

const localeCacheMap = new Map<LocaleOrCustom, EmojiStateMap>([
  [
    EMOJI_TYPE_CUSTOM,
    createLimitedCache<EmojiState>({ log: log.extend('custom') }),
  ],
]);

function cacheForLocale(locale: LocaleOrCustom): EmojiStateMap {
  return (
    localeCacheMap.get(locale) ??
    createLimitedCache<EmojiState>({ log: log.extend(locale) })
  );
}

function emojiForLocale(
  code: string,
  locale: LocaleOrCustom,
): EmojiState | undefined {
  const cache = cacheForLocale(locale);
  return cache.get(code);
}

async function loadMissingEmojiIntoCache(
  tokens: TokenizedText,
  { mode, currentLocale }: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap,
) {
  const missingUnicodeEmoji = new Set<string>();
  const missingCustomEmoji = new Set<string>();

  // Iterate over tokens and check if they are in the cache already.
  for (const token of tokens) {
    if (typeof token === 'string') {
      continue; // Skip plain strings.
    }

    // If this is a custom emoji, check it separately.
    if (token.type === EMOJI_TYPE_CUSTOM) {
      const code = token.code;
      if (code in extraEmojis) {
        continue; // We don't care about extra emoji.
      }
      const emojiState = emojiForLocale(code, EMOJI_TYPE_CUSTOM);
      if (!emojiState) {
        missingCustomEmoji.add(code);
      }
      // Otherwise this is a unicode emoji, so check it against all locales.
    } else if (shouldRenderImage(token, mode)) {
      const code = emojiToUnicodeHex(token.code);
      if (missingUnicodeEmoji.has(code)) {
        continue; // Already marked as missing.
      }
      const emojiState = emojiForLocale(code, currentLocale);
      if (!emojiState) {
        // If it's missing in one locale, we consider it missing for all.
        missingUnicodeEmoji.add(code);
      }
    }
  }

  if (missingUnicodeEmoji.size > 0) {
    const missingEmojis = Array.from(missingUnicodeEmoji).toSorted();
    const emojis = await searchEmojisByHexcodes(missingEmojis, currentLocale);
    const cache = cacheForLocale(currentLocale);
    for (const emoji of emojis) {
      cache.set(emoji.hexcode, {
        type: EMOJI_TYPE_UNICODE,
        data: emoji,
        code: emoji.hexcode,
      });
    }
    localeCacheMap.set(currentLocale, cache);
  }

  if (missingCustomEmoji.size > 0) {
    const missingEmojis = Array.from(missingCustomEmoji).toSorted();
    const emojis = await searchCustomEmojisByShortcodes(missingEmojis);
    const cache = cacheForLocale(EMOJI_TYPE_CUSTOM);
    for (const emoji of emojis) {
      cache.set(emoji.shortcode, {
        type: EMOJI_TYPE_CUSTOM,
        data: emoji,
        code: emoji.shortcode,
      });
    }
    localeCacheMap.set(EMOJI_TYPE_CUSTOM, cache);
  }
}

export function shouldRenderImage(token: EmojiState, mode: EmojiMode): boolean {
  if (token.type === EMOJI_TYPE_UNICODE) {
    // If the mode is native or native with flags for non-flag emoji
    // we can just append the text node directly.
    if (
      mode === EMOJI_MODE_NATIVE ||
      (mode === EMOJI_MODE_NATIVE_WITH_FLAGS &&
        !stringHasUnicodeFlags(token.code))
    ) {
      return false;
    }
  }

  return true;
}

function stateToImage(state: EmojiLoadedState, appState: EmojiAppState) {
  const image = document.createElement('img');
  image.draggable = false;
  image.classList.add('emojione');

  if (state.type === EMOJI_TYPE_UNICODE) {
    image.alt = state.data.unicode;
    image.title = state.data.label;
    image.src = unicodeHexToUrl(state.data.hexcode, appState.darkTheme);
  } else {
    // Custom emoji
    const shortCode = `:${state.data.shortcode}:`;
    image.classList.add('custom-emoji');
    image.alt = shortCode;
    image.title = shortCode;
    image.src = autoPlayGif ? state.data.url : state.data.static_url;
    image.dataset.original = state.data.url;
    image.dataset.static = state.data.static_url;
  }

  return image;
}

function renderedToHTML(renderedArray: EmojifiedTextArray): DocumentFragment;
function renderedToHTML<ParentType extends ParentNode>(
  renderedArray: EmojifiedTextArray,
  parent: ParentType,
): ParentType;
function renderedToHTML(
  renderedArray: EmojifiedTextArray,
  parent: ParentNode | null = null,
) {
  const fragment = parent ?? document.createDocumentFragment();
  for (const fragmentItem of renderedArray) {
    if (typeof fragmentItem === 'string') {
      fragment.appendChild(document.createTextNode(fragmentItem));
    } else if (fragmentItem instanceof HTMLImageElement) {
      fragment.appendChild(fragmentItem);
    }
  }
  return fragment;
}

// Testing helpers
export const testCacheClear = () => {
  cacheClear();
  localeCacheMap.clear();
};
