import type { Locale } from 'emojibase';

import initialState from '@/mastodon/initial_state';

import { toSupportedLocale } from './locale';

const worker =
  'Worker' in window
    ? new Worker(new URL('./worker', import.meta.url), {
        type: 'module',
      })
    : null;

export function initializeEmoji() {
  const serverLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

  // If the worker is available, we can use it to load emoji data
  if (worker) {
    worker.postMessage(serverLocale);
    worker.postMessage('custom');
  } else {
    void importEmojiData(serverLocale);
  }
}

async function importEmojiData(locale: Locale) {
  const { importEmojiData, importCustomEmojiData } = await import('./loader');
  await Promise.all([importEmojiData(locale), importCustomEmojiData()]);
}
