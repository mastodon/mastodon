import { autoPlayGif } from '@/mastodon/initial_state';
import { createLimitedCache } from '@/mastodon/utils/cache';
import { assetHost } from '@/mastodon/utils/config';

import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_TYPE_UNICODE,
  EMOJI_TYPE_CUSTOM,
  EMOJI_STATE_MISSING,
} from './constants';
import { loadCustomEmojiByShortcode, loadEmojiByHexcode } from './database';
import { emojiToUnicodeHex, unicodeToTwemojiFilename } from './normalize';
import type {
  AnyEmojiData,
  EmojiAppState,
  EmojiLoadedState,
  EmojiMode,
  EmojiState,
  EmojiStateCustom,
  EmojiStateMissing,
  EmojiStateToken,
  EmojiStateUnicode,
  EmojiType,
  ExtraCustomEmojiMap,
} from './types';
import {
  anyEmojiRegex,
  emojiLogger,
  stringHasAnyEmoji,
  stringHasUnicodeFlags,
} from './utils';

const log = emojiLogger('render');

/**
 * Emojifies an element. This modifies the element in place, replacing text nodes with emojified versions.
 */
export function emojifyElement<Element extends HTMLElement>(
  element: Element,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): Element | null {
  const finish = timingMeasurementHelper('emojifyElement');
  // Check the cache and return it if we get a hit.
  const cacheKey = createTextCacheKey(element, appState, extraEmojis);
  const cached = textCache.get(cacheKey);
  if (cached !== undefined) {
    log('Cache hit on %s', element.outerHTML);
    if (cached === null) {
      // return null;
    }
    // element.innerHTML = cached;
    // return element;
  }

  // Exit if there are no emoji in the string.
  if (!stringHasAnyEmoji(element.innerHTML)) {
    textCache.set(cacheKey, null);
    return null;
  }

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
      const tokens = tokenizeText(current.textContent, appState.mode);
      const renderedContent = tokensToElementArray(
        tokens,
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
  textCache.set(cacheKey, element.innerHTML);
  finish();
  return element;
}

export function emojifyText(
  text: string,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): string | null {
  const cacheKey = createTextCacheKey(text, appState, extraEmojis);
  const cached = textCache.get(cacheKey);
  if (cached !== undefined) {
    log('Cache hit on %s', text);
    return cached ?? text;
  }
  if (!stringHasAnyEmoji(text)) {
    textCache.set(cacheKey, null);
    return text;
  }
  const tokens = tokenizeText(text, appState.mode);
  const eleArray = tokensToElementArray(tokens, appState, extraEmojis);
  if (!eleArray) {
    textCache.set(cacheKey, null);
    return text;
  }
  const rendered = renderedToHTML(eleArray, document.createElement('div'));
  textCache.set(cacheKey, rendered.innerHTML);
  return rendered.innerHTML;
}

// Private functions

// This is the text cache. It contains full HTML strings or null to indicate there is no emoji here.
const textCache = createLimitedCache<string | null>({
  log: log.extend('text'),
});

function createTextCacheKey(
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

// These are the unicode/custom emoji data caches.
const unicodeEmojiCache = createLimitedCache<
  Required<EmojiStateUnicode> | EmojiStateMissing
>({ log: log.extend(EMOJI_TYPE_UNICODE) });

const customEmojiCache = createLimitedCache<
  Required<EmojiStateCustom> | EmojiStateMissing
>({ log: log.extend(EMOJI_TYPE_CUSTOM) });

function cacheForType(type: EmojiType) {
  return type === EMOJI_TYPE_UNICODE ? unicodeEmojiCache : customEmojiCache;
}

// Tokenization. This takes the HTML string and converts it into an array of emoji types that are cached.

type TokenizedText = (string | Exclude<EmojiState, EmojiStateMissing>)[];

const tokenCache = createLimitedCache<TokenizedText>({
  log: log.extend('tokens'),
});

/**
 * Accepts incoming text strings and breaks them into an array of state tokens.
 */
export function tokenizeText(text: string, mode: EmojiMode): TokenizedText {
  if (!text.trim()) {
    return [];
  }

  const finish = timingMeasurementHelper('tokenizeText');

  const cached = tokenCache.get(text);
  if (cached) {
    // return cached;
  }

  const tokens = [];
  let lastIndex = 0;
  for (const match of text.matchAll(anyEmojiRegex())) {
    if (match.index > lastIndex) {
      tokens.push(text.slice(lastIndex, match.index));
    }

    // Determine the emoji type.
    let code = match[0];
    let type: EmojiType = EMOJI_TYPE_UNICODE;
    if (code.startsWith(':') && code.endsWith(':')) {
      code = code.slice(1, -1); // Remove the colons
      type = EMOJI_TYPE_CUSTOM;
    } else if (!shouldRenderUnicodeImage(code, mode)) {
      // If it's not custom, check if we should render this based on mode.
      continue;
    } else {
      // If we are rendering it, convert it to a hex code.
      code = emojiToUnicodeHex(code);
    }

    // Get the cached data.
    const cache = cacheForType(type);
    const cachedData = cache.get(code);

    if (cachedData === EMOJI_STATE_MISSING) {
      continue; // Exit if we know this is missing.
    } else {
      // This is possibly an emoji!
      // We are not saving the data in here to keep cache sizes small.
      tokens.push({
        type,
        code,
      } satisfies EmojiStateToken);
    }

    // Move the last index to after the emoji text.
    lastIndex = match.index + match[0].length;
  }

  // Append any remaining text.
  if (lastIndex < text.length) {
    tokens.push(text.slice(lastIndex));
  }
  finish();
  return tokens;
}

function shouldRenderUnicodeImage(code: string, mode: EmojiMode): boolean {
  // If the mode is native or native with flags for non-flag emoji
  // we can just append the text node directly.
  if (mode === EMOJI_MODE_NATIVE) {
    return false;
  } else if (
    mode === EMOJI_MODE_NATIVE_WITH_FLAGS &&
    !stringHasUnicodeFlags(code)
  ) {
    return false;
  }
  return true;
}

type EmojifiedTextArray = (string | HTMLImageElement)[];

function tokensToElementArray(
  tokens: TokenizedText,
  appState: EmojiAppState,
  extraEmojis: ExtraCustomEmojiMap = {},
): EmojifiedTextArray | null {
  // If only one token and it's a string, exit early.
  if (tokens.length === 1 && typeof tokens[0] === 'string') {
    return null;
  }

  const finish = timingMeasurementHelper('tokensToElementArray');

  const renderedFragments: EmojifiedTextArray = [];
  for (const token of tokens) {
    // Plain text does not need to be converted.
    if (typeof token === 'string') {
      renderedFragments.push(token);
      continue;
    }

    // Check if this is a provided custom emoji and use that if so.
    if (token.type === EMOJI_TYPE_CUSTOM) {
      const extraEmojiData = extraEmojis[token.code];
      if (extraEmojiData) {
        token.data = extraEmojiData;
      }
    }
    // Otherwise, load the data from the cache if it exists.
    if (!token.data) {
      const cache = cacheForType(token.type);
      const cached = cache.get(token.code);
      if (cached !== EMOJI_STATE_MISSING && cached?.data) {
        token.data = cached.data;
      }
    }

    // Create an image element from the token and add it to the the fragments.
    const image = stateToImage(token, appState);
    renderedFragments.push(image);
  }

  finish();
  return renderedFragments;
}

const EMOJI_SIZE = 16;

function stateToImage(state: EmojiStateToken, appState: EmojiAppState) {
  const finish = timingMeasurementHelper('stateToImage');
  const image = document.createElement('img');
  image.draggable = false;
  image.classList.add('emojione');
  image.loading = 'lazy';
  image.width = EMOJI_SIZE;
  image.height = EMOJI_SIZE;

  // If we don't have the emoji data yet, show a loading animation and start an async task.
  if (!isStateLoaded(state)) {
    image.classList.add('loading');
    image.src =
      "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'%3E%3C/svg%3E"; // An empty SVG.
    // Loads the image data, adding attributes after the load is complete.
    void lazyLoadImageData(image, state, appState);
  } else {
    // Otherwise add the correct attributes.
    imageAttributesFromState(image, state, appState.darkTheme);
  }

  finish();
  return image;
}

function imageAttributesFromState(
  image: HTMLImageElement,
  state: EmojiLoadedState,
  darkTheme: boolean,
) {
  image.classList.remove('loading');

  if (state.type === EMOJI_TYPE_UNICODE) {
    // From the unicode hex, normalize for Twemoji. This handles the border as well.
    const fileName = unicodeToTwemojiFilename(state.code, darkTheme);

    image.alt = state.data.unicode;
    image.title = state.data.label;
    image.src = `${assetHost}/emoji/${fileName}.svg`;
  } else {
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

const loadingPromises = new Map<string, Promise<AnyEmojiData | undefined>>();
async function lazyLoadImageData(
  image: HTMLImageElement,
  state: EmojiStateToken,
  appState: EmojiAppState,
) {
  let promise = loadingPromises.get(state.code);
  const isCustom = state.type === EMOJI_TYPE_CUSTOM;
  if (!promise) {
    promise = isCustom
      ? loadEmojiByHexcode(state.code, appState.currentLocale)
      : loadCustomEmojiByShortcode(state.code);
    loadingPromises.set(state.code, promise);
  }

  // Await the data promise.
  const data = await promise;
  log('Loaded data for emoji %s', state.code);
  loadingPromises.delete(state.code);

  // If there is no data, replace the image with text.
  if (!data) {
    const text = isCustom ? `:${state.code}:` : state.code;
    image.replaceWith(new Text(text));

    // Save this to the cache so we know it's not a real emoji.
    const cache = isCustom ? customEmojiCache : unicodeEmojiCache;
    cache.set(state.code, EMOJI_STATE_MISSING);

    return;
  }

  state.data = data;
  // This check is not technically needed, but it makes TS happy.
  if (isStateLoaded(state)) {
    imageAttributesFromState(image, state, appState.darkTheme);

    // Cache the state. This cannot be the cache const above as that causes TS to complain.
    if (isCustom) {
      customEmojiCache.set(state.code, state);
    } else {
      unicodeEmojiCache.set(state.code, state);
    }
  }
}

function isStateLoaded(state: EmojiStateToken): state is EmojiLoadedState {
  return !!state.data;
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

function timingMeasurementHelper(name: string) {
  const start = performance.now();
  return () => {
    const duration = performance.now() - start;
    log.extend('timing')('timing for %s: %d', name, duration);
  };
}

// Testing helpers
export const testCacheClear = () => {
  textCache.clear();
  unicodeEmojiCache.clear();
  customEmojiCache.clear();
};
