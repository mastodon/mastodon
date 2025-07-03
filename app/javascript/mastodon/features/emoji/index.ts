import initialState from '@/mastodon/initial_state';

import { initEmojiDB } from './database';
import { toSupportedLocale } from './locale';

const worker =
  'Worker' in window
    ? new Worker(new URL('./worker', import.meta.url), {
        type: 'module',
      })
    : null;

export async function initializeEmoji() {
  const serverLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

  initEmojiDB();
  await loadEmojiLocale(serverLocale);

  // Load custom emojis
  if (worker) {
    worker.postMessage('custom');
  } else {
    const { importCustomEmojiData } = await import('./loader');
    await importCustomEmojiData();
  }
}

export async function loadEmojiLocale(localeString: string) {
  const locale = toSupportedLocale(localeString);

  if (worker) {
    worker.postMessage(locale);
  } else {
    const { importEmojiData } = await import('./loader');
    await importEmojiData(locale);
  }
}
