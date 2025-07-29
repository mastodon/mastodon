import initialState from '@/mastodon/initial_state';
import { loadWorker } from '@/mastodon/utils/workers';

import { toSupportedLocale } from './locale';
import { emojiLogger } from './utils';

const userLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

let worker: Worker | null = null;

const log = emojiLogger('index');

export async function initializeEmoji() {
  if (!worker && 'Worker' in window) {
    try {
      worker = loadWorker(new URL('./worker', import.meta.url), {
        type: 'module',
      });
    } catch (err) {
      console.warn('Error creating web worker:', err);
    }
  }

  if (worker) {
    // Assign worker to const to make TS happy inside the event listener.
    const thisWorker = worker;
    thisWorker.addEventListener('message', (event: MessageEvent<string>) => {
      const { data: message } = event;
      if (message === 'ready') {
        log('worker is ready');
        thisWorker.postMessage('custom');
        void loadEmojiLocale(userLocale);
        // Load English locale as well, because people are still used to
        // using it from before we supported other locales.
        if (userLocale !== 'en') {
          void loadEmojiLocale('en');
        }
      }
    });
  } else {
    log('falling back to main thread');
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
