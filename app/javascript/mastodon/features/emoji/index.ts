import initialState from '@/mastodon/initial_state';

import { toSupportedLocale } from './locale';

const userLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

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
        worker.postMessage('custom');
        void loadEmojiLocale(userLocale);
        // Load English locale as well, because people are still used to
        // using it from before we supported other locales.
        if (userLocale !== 'en') {
          void loadEmojiLocale('en');
        }
      }
    });
  } else {
    const { importCustomEmojiData } = await import('./loader');
    await importCustomEmojiData();
    await loadEmojiLocale(userLocale);
    if (userLocale !== 'en') {
      await loadEmojiLocale('en');
    }
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
