import initialState from '@/mastodon/initial_state';

import { toSupportedLocale } from './locale';

const serverLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

const worker =
  'Worker' in window
    ? new Worker(new URL('./worker', import.meta.url), {
        type: 'module',
      })
    : null;

export async function initializeEmoji() {
  if (worker) {
    worker.addEventListener('message', (event: MessageEvent<string>) => {
      const { data: message } = event;
      if (message === 'ready') {
        worker.postMessage(serverLocale);
        worker.postMessage('custom');
      }
    });
  } else {
    const { importCustomEmojiData, importEmojiData } = await import('./loader');
    await Promise.all([importCustomEmojiData(), importEmojiData(serverLocale)]);
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
