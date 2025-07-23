import type { Locale } from 'emojibase';
import EMOJI_REGEX from 'emojibase-regex/emoji-loose';

import { autoPlayGif } from '@/mastodon/initial_state';
import { assetHost } from '@/mastodon/utils/config';

import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_TYPE_UNICODE,
  EMOJI_TYPE_CUSTOM,
  EMOJI_STATE_MISSING,
} from './constants';
import {
  findMissingLocales,
  searchCustomEmojisByShortcodes,
  searchEmojisByHexcodes,
} from './database';
import { loadEmojiLocale } from './index';
import {
  emojiToUnicodeHex,
  twemojiHasBorder,
  unicodeToTwemojiHex,
} from './normalize';
import type {
  CustomEmojiToken,
  EmojiAppState,
  EmojiLoadedState,
  EmojiMode,
  EmojiState,
  EmojiStateMap,
  EmojiToken,
  ExtraCustomEmojiMap,
  LocaleOrCustom,
  UnicodeEmojiToken,
} from './types';
import { stringHasUnicodeFlags } from './utils';

const localeCacheMap = new Map<LocaleOrCustom, EmojiStateMap>([
  [EMOJI_TYPE_CUSTOM, new Map()],
]);

// Emojifies an element. This modifies the element in place, replacing text nodes with emojified versions.
export async function emojifyElement<Element extends HTMLElement>(
  element: Element,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): Promise<Element> {
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
      const renderedContent = await emojifyText(
        current.textContent,
        appState,
        extraEmojis,
      );
      if (renderedContent) {
        if (!(current instanceof Text)) {
          current.textContent = null; // Clear the text content if it's not a Text node.
        }
        current.replaceWith(renderedToHTMLFragment(renderedContent));
      }
      continue;
    }

    for (const child of current.childNodes) {
      if (child instanceof HTMLElement || child instanceof Text) {
        queue.push(child);
      }
    }
  }
  return element;
}

export async function emojifyText(
  text: string,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
) {
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
  await ensureLocalesAreLoaded(appState.locales);
  await loadMissingEmojiIntoCache(tokens, appState.locales);

  const renderedFragments: (string | HTMLImageElement)[] = [];
  for (const token of tokens) {
    if (typeof token !== 'string' && shouldRenderImage(token, appState.mode)) {
      let state: EmojiState | undefined;
      if (token.type === EMOJI_TYPE_CUSTOM) {
        const extraEmojiData = extraEmojis[token.code];
        if (extraEmojiData) {
          state = { type: EMOJI_TYPE_CUSTOM, data: extraEmojiData };
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
      if (state && typeof state !== 'string') {
        const image = stateToImage(state);
        renderedFragments.push(image);
        continue;
      }
    }
    const text = typeof token === 'string' ? token : token.code;
    renderedFragments.push(text);
  }

  return renderedFragments;
}

// Private functions

async function ensureLocalesAreLoaded(locales: Locale[]) {
  const missingLocales = await findMissingLocales(locales);
  for (const locale of missingLocales) {
    await loadEmojiLocale(locale);
  }
}

const CUSTOM_EMOJI_REGEX = /:([a-z0-9_]+):/i;
const TOKENIZE_REGEX = new RegExp(
  `(${EMOJI_REGEX.source}|${CUSTOM_EMOJI_REGEX.source})`,
  'g',
);

type TokenizedText = (string | EmojiToken)[];

export function tokenizeText(text: string): TokenizedText {
  if (!text.trim()) {
    return [];
  }

  const tokens = [];
  let lastIndex = 0;
  for (const match of text.matchAll(TOKENIZE_REGEX)) {
    if (match.index > lastIndex) {
      tokens.push(text.slice(lastIndex, match.index));
    }

    const code = match[0];

    if (code.startsWith(':') && code.endsWith(':')) {
      // Custom emoji
      tokens.push({
        type: EMOJI_TYPE_CUSTOM,
        code: code.slice(1, -1), // Remove the colons
      } satisfies CustomEmojiToken);
    } else {
      // Unicode emoji
      tokens.push({
        type: EMOJI_TYPE_UNICODE,
        code: code,
      } satisfies UnicodeEmojiToken);
    }
    lastIndex = match.index + code.length;
  }
  if (lastIndex < text.length) {
    tokens.push(text.slice(lastIndex));
  }
  return tokens;
}

function cacheForLocale(locale: LocaleOrCustom): EmojiStateMap {
  return localeCacheMap.get(locale) ?? (new Map() as EmojiStateMap);
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
  locales: Locale[],
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
      const emojiState = emojiForLocale(code, EMOJI_TYPE_CUSTOM);
      if (!emojiState) {
        missingCustomEmoji.add(code);
      }
      // Otherwise this is a unicode emoji, so check it against all locales.
    } else {
      const code = emojiToUnicodeHex(token.code);
      if (missingUnicodeEmoji.has(code)) {
        continue; // Already marked as missing.
      }
      for (const locale of locales) {
        const emojiState = emojiForLocale(code, locale);
        if (!emojiState) {
          // If it's missing in one locale, we consider it missing for all.
          missingUnicodeEmoji.add(code);
        }
      }
    }
  }

  if (missingUnicodeEmoji.size > 0) {
    const missingEmojis = Array.from(missingUnicodeEmoji).toSorted();
    for (const locale of locales) {
      const emojis = await searchEmojisByHexcodes(missingEmojis, locale);
      const cache = cacheForLocale(locale);
      for (const emoji of emojis) {
        cache.set(emoji.hexcode, { type: EMOJI_TYPE_UNICODE, data: emoji });
      }
      const notFoundEmojis = missingEmojis.filter((code) =>
        emojis.every((emoji) => emoji.hexcode !== code),
      );
      for (const code of notFoundEmojis) {
        cache.set(code, EMOJI_STATE_MISSING); // Mark as missing if not found, as it's probably not a valid emoji.
      }
      localeCacheMap.set(locale, cache);
    }
  }

  if (missingCustomEmoji.size > 0) {
    const missingEmojis = Array.from(missingCustomEmoji).toSorted();
    const emojis = await searchCustomEmojisByShortcodes(missingEmojis);
    const cache = cacheForLocale(EMOJI_TYPE_CUSTOM);
    for (const emoji of emojis) {
      cache.set(emoji.shortcode, { type: EMOJI_TYPE_CUSTOM, data: emoji });
    }
    const notFoundEmojis = missingEmojis.filter((code) =>
      emojis.every((emoji) => emoji.shortcode !== code),
    );
    for (const code of notFoundEmojis) {
      cache.set(code, EMOJI_STATE_MISSING); // Mark as missing if not found, as it's probably not a valid emoji.
    }
    localeCacheMap.set(EMOJI_TYPE_CUSTOM, cache);
  }
}

function shouldRenderImage(token: EmojiToken, mode: EmojiMode): boolean {
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

function stateToImage(state: EmojiLoadedState) {
  const image = document.createElement('img');
  image.draggable = false;
  image.classList.add('emojione');

  if (state.type === EMOJI_TYPE_UNICODE) {
    const emojiInfo = twemojiHasBorder(unicodeToTwemojiHex(state.data.hexcode));
    if (emojiInfo.hasLightBorder) {
      image.dataset.lightCode = `${emojiInfo.hexCode}_BORDER`;
    } else if (emojiInfo.hasDarkBorder) {
      image.dataset.darkCode = `${emojiInfo.hexCode}_BORDER`;
    }

    image.alt = state.data.unicode;
    image.title = state.data.label;
    image.src = `${assetHost}/emoji/${emojiInfo.hexCode}.svg`;
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

function renderedToHTMLFragment(renderedArray: (string | HTMLImageElement)[]) {
  const fragment = document.createDocumentFragment();
  for (const fragmentItem of renderedArray) {
    if (typeof fragmentItem === 'string') {
      fragment.appendChild(document.createTextNode(fragmentItem));
    } else if (fragmentItem instanceof HTMLImageElement) {
      fragment.appendChild(fragmentItem);
    }
  }
  return fragment;
}
