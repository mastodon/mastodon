import EMOJI_REGEX from 'emojibase-regex/emoji-loose';

import { EMOJI_MODE_NATIVE, EMOJI_MODE_NATIVE_WITH_FLAGS } from './constants';
import {
  emojiToUnicodeHex,
  twemojiHasBorder,
  unicodeToTwemojiHex,
} from './normalize';
import type {
  CustomEmojiToken,
  EmojiMode,
  EmojiToken,
  UnicodeEmojiToken,
} from './types';
import { stringHasUnicodeFlags } from './utils';

// Emojifies an element. This modifies the element in place, replacing text nodes with emojified versions.
export function emojifyElement<Element extends HTMLElement>(
  element: Element,
  mode: EmojiMode,
): Element {
  const elementCopy = element.cloneNode(true) as Element;
  const queue: (HTMLElement | Text)[] = [elementCopy];
  while (queue.length > 0) {
    const current = queue.shift();
    if (
      !current ||
      current instanceof HTMLScriptElement ||
      current instanceof HTMLStyleElement
    ) {
      continue;
    }

    if (current instanceof Text && current.textContent) {
      const emojifiedNode = emojifyText(current.textContent, mode);
      if (emojifiedNode) {
        current.replaceWith(emojifiedNode);
      }
      continue; // Text nodes cannot have children.
    } else if (current.textContent && !current.hasChildNodes()) {
      const emojifiedText = emojifyText(current.textContent, mode);
      if (emojifiedText) {
        current.textContent = null;
        current.appendChild(emojifiedText);
      }
      continue;
    }

    for (const child of current.childNodes) {
      if (child instanceof HTMLElement || child instanceof Text) {
        queue.push(child);
      }
    }
  }
  return elementCopy;
}

const CUSTOM_EMOJI_REGEX = /:([a-z0-9_]+):/i;
const TOKENIZE_REGEX = new RegExp(
  `(${EMOJI_REGEX.source}|${CUSTOM_EMOJI_REGEX.source})`,
  'g',
);

type TokenizedText = (string | CustomEmojiToken | UnicodeEmojiToken)[];

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

    if (match[0].startsWith(':') && match[0].endsWith(':')) {
      // Custom emoji
      tokens.push({
        type: 'custom',
        code: match[0].slice(1, -1),
      } satisfies CustomEmojiToken);
    } else {
      // Unicode emoji
      tokens.push({
        type: 'unicode',
        code: match[0],
      } satisfies UnicodeEmojiToken);
    }
    lastIndex = match.index + match[0].length;
  }
  if (lastIndex < text.length) {
    tokens.push(text.slice(lastIndex));
  }
  return tokens;
}

export function tokenToElement(
  token: EmojiToken,
  mode: EmojiMode,
): HTMLImageElement | null {
  const image = document.createElement('img');
  image.draggable = false;
  image.classList.add('emojione');
  image.alt = token.code;
  if (token.type === 'unicode') {
    // If the mode is native or native with flags for non-flag emoji
    // we can just append the text node directly.
    if (
      mode === EMOJI_MODE_NATIVE ||
      (mode === EMOJI_MODE_NATIVE_WITH_FLAGS &&
        !stringHasUnicodeFlags(token.code))
    ) {
      return null; // No need to create an image for native emoji.
    }
    const emojiInfo = twemojiHasBorder(
      unicodeToTwemojiHex(emojiToUnicodeHex(token.code)),
    );
    image.dataset.code = emojiInfo.hexCode;
    if (emojiInfo.hasLightBorder) {
      image.dataset.lightCode = `${emojiInfo.hexCode}_BORDER`;
    } else if (emojiInfo.hasDarkBorder) {
      image.dataset.darkCode = `${emojiInfo.hexCode}_BORDER`;
    }
  } else {
    // Custom emoji
    const shortCode = `:${token.code}:`;
    image.classList.add('custom-emoji');
    image.alt = shortCode;
    image.title = shortCode;
  }

  return image;
}

function emojifyText(text: string, mode: EmojiMode) {
  // Exit if no text to convert.
  if (!text.trim()) {
    return null;
  }

  const tokens = tokenizeText(text);

  // If only one token and it's a string, exit early.
  if (tokens.length === 1 && typeof tokens[0] === 'string') {
    return null;
  }
  const fragment = document.createDocumentFragment();
  for (const token of tokens) {
    if (typeof token === 'string') {
      fragment.appendChild(document.createTextNode(token));
      continue;
    }

    const image = tokenToElement(token, mode);
    if (image) {
      fragment.appendChild(image);
    } else {
      // If there is no image, it means we should just use native rendering.
      fragment.appendChild(document.createTextNode(token.code));
    }
  }

  return fragment;
}
