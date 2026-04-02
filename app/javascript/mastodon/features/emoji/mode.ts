// Credit to Nolan Lawson for the original implementation.
// See: https://github.com/nolanlawson/emoji-picker-element/blob/master/src/picker/utils/testColorEmojiSupported.js

import { createAppSelector, useAppSelector } from '@/mastodon/store';
import { assetHost } from '@/mastodon/utils/config';
import { isDevelopment } from '@/mastodon/utils/environment';
import { isDarkMode } from '@/mastodon/utils/theme';

import {
  EMOJI_MODE_NATIVE,
  EMOJI_MODE_NATIVE_WITH_FLAGS,
  EMOJI_MODE_TWEMOJI,
} from './constants';
import { toSupportedLocale } from './locale';
import type { EmojiAppState, EmojiMode } from './types';

const modeSelector = createAppSelector(
  [(state) => state.meta.get('emoji_style') as string],
  (emoji_style) => determineEmojiMode(emoji_style),
);

export function useEmojiAppState(): EmojiAppState {
  const locale = useAppSelector((state) =>
    toSupportedLocale(state.meta.get('locale') as string),
  );
  const mode = useAppSelector(modeSelector);

  return {
    currentLocale: locale,
    locales: [locale],
    mode,
    darkTheme: isDarkMode(),
    assetHost,
  };
}

type Feature = Uint8ClampedArray;

// See: https://github.com/nolanlawson/emoji-picker-element/blob/master/src/picker/constants.js
const FONT_FAMILY =
  '"Twemoji Mozilla","Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol",' +
  '"Noto Color Emoji","EmojiOne Color","Android Emoji",sans-serif';

function getTextFeature(text: string, color: string) {
  const canvas = document.createElement('canvas');
  canvas.width = canvas.height = 1;

  const ctx = canvas.getContext('2d', {
    // Improves the performance of `getImageData()`
    // https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/getContextAttributes#willreadfrequently
    willReadFrequently: true,
  });
  if (!ctx) {
    throw new Error('Canvas context not available');
  }
  ctx.textBaseline = 'top';
  ctx.font = `100px ${FONT_FAMILY}`;
  ctx.fillStyle = color;
  ctx.scale(0.01, 0.01);
  ctx.fillText(text, 0, 0);

  return ctx.getImageData(0, 0, 1, 1).data satisfies Feature;
}

function compareFeatures(feature1: Feature, feature2: Feature) {
  const feature1Str = [...feature1].join(',');
  const feature2Str = [...feature2].join(',');
  // This is RGBA, so for 0,0,0, we are checking that the first RGB is not all zeroes.
  // Most of the time when unsupported this is 0,0,0,0, but on Chrome on Mac it is
  // 0,0,0,61 - there is a transparency here.
  return feature1Str === feature2Str && !feature1Str.startsWith('0,0,0,');
}

function testEmojiSupport(text: string) {
  // Render white and black and then compare them to each other and ensure they're the same
  // color, and neither one is black. This shows that the emoji was rendered in color.
  const feature1 = getTextFeature(text, '#000');
  const feature2 = getTextFeature(text, '#fff');
  return compareFeatures(feature1, feature2);
}

const EMOJI_VERSION_TEST_EMOJI = '🫩'; // face with bags under eyes, from Unicode 16.0.
const EMOJI_FLAG_TEST_EMOJI = '🇨🇭';

export function determineEmojiMode(style: string): EmojiMode {
  if (style === EMOJI_MODE_NATIVE) {
    // If flags are not supported, we replace them with Twemoji.
    if (shouldReplaceFlags()) {
      return EMOJI_MODE_NATIVE_WITH_FLAGS;
    }
    return EMOJI_MODE_NATIVE;
  }
  if (style === EMOJI_MODE_TWEMOJI) {
    return EMOJI_MODE_TWEMOJI;
  }

  // Auto style so determine based on browser capabilities.
  if (shouldUseTwemoji()) {
    return EMOJI_MODE_TWEMOJI;
  } else if (shouldReplaceFlags()) {
    return EMOJI_MODE_NATIVE_WITH_FLAGS;
  }
  return EMOJI_MODE_NATIVE;
}

export function shouldUseTwemoji(): boolean {
  if (typeof window === 'undefined') {
    return false;
  }
  try {
    // Test a known color emoji to see if 15.1 is supported.
    return !testEmojiSupport(EMOJI_VERSION_TEST_EMOJI);
  } catch (err: unknown) {
    // If an error occurs, fall back to Twemoji to be safe.
    if (isDevelopment()) {
      console.warn(
        'Emoji rendering test failed, defaulting to Twemoji. Error:',
        err,
      );
    }
    return true;
  }
}

// Based on https://github.com/talkjs/country-flag-emoji-polyfill/blob/master/src/index.ts#L19
export function shouldReplaceFlags(): boolean {
  if (typeof window === 'undefined') {
    return false;
  }
  try {
    // Test a known flag emoji to see if it is rendered in color.
    return !testEmojiSupport(EMOJI_FLAG_TEST_EMOJI);
  } catch (err: unknown) {
    // If an error occurs, assume flags should be replaced.
    if (isDevelopment()) {
      console.warn(
        'Flag emoji rendering test failed, defaulting to replacement. Error:',
        err,
      );
    }
    return true;
  }
}
