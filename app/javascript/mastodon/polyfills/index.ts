// Convenience function to load polyfills and return a promise when it's done.
// If there are no polyfills, then this is just Promise.resolve() which means
// it will execute in the same tick of the event loop (i.e. near-instant).

import { loadIntlPolyfills } from './intl';

function importExtraPolyfills() {
  return import('./extra_polyfills');
}

export function loadPolyfills() {
  // Safari does not have requestIdleCallback.
  // This avoids shipping them all the polyfills.
  const needsExtraPolyfills = !window.requestIdleCallback;

  return Promise.all([
    loadVitePreloadPolyfill(),
    loadIntlPolyfills(),
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- those properties might not exist in old browsers, even if they are always here in types
    needsExtraPolyfills ? importExtraPolyfills() : Promise.resolve(),
    loadEmojiPolyfills(),
  ]);
}

// In the case of no /v support, rely on the emojibase data.
async function loadEmojiPolyfills() {
  if (!('unicodeSets' in RegExp.prototype)) {
    emojiRegexPolyfill = (await import('emojibase-regex/emoji')).default;
  }
}

// Loads Vite's module preload polyfill for older browsers, but not in a Worker context.
function loadVitePreloadPolyfill() {
  if (typeof document === 'undefined') return;
  // @ts-expect-error -- This is a virtual module provided by Vite.
  // eslint-disable-next-line import/extensions
  return import('vite/modulepreload-polyfill');
}

// Null unless polyfill is needed.
export let emojiRegexPolyfill: RegExp | null = null;
