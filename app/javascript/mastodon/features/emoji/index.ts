import type { Locale } from 'emojibase';

import { initialState } from '@/mastodon/initial_state';

import type { EMOJI_DB_NAME_SHORTCODES, EMOJI_TYPE_CUSTOM } from './constants';
import { importLegacyShortcodes, localeToShortcodesPath } from './loader';
import { toSupportedLocale } from './locale';
import type { LocaleOrCustom } from './types';
import { emojiLogger } from './utils';
// eslint-disable-next-line import/default -- Importing via worker loader.
import EmojiWorker from './worker?worker&inline';

const userLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

let worker: Worker | null = null;

const log = emojiLogger('index');

const WORKER_TIMEOUT = 1_000; // 1 second

export function initializeEmoji() {
  log('initializing emojis');
  if (!worker && 'Worker' in window) {
    try {
      worker = new EmojiWorker();
    } catch (err) {
      console.warn('Error creating web worker:', err);
    }
  }

  if (worker) {
    const timeoutId = setTimeout(() => {
      log('worker is not ready after timeout');
      worker = null;
      void fallbackLoad();
    }, WORKER_TIMEOUT);
    worker.addEventListener('message', (event: MessageEvent<string>) => {
      const { data: message } = event;
      if (message === 'ready') {
        log('worker ready, loading data');
        clearTimeout(timeoutId);
        messageWorker('custom');
        messageWorker('shortcodes');
        void loadEmojiLocale(userLocale);
      } else {
        log('got worker message: %s', message);
      }
    });
  } else {
    void fallbackLoad();
  }
}

async function fallbackLoad() {
  log('falling back to main thread for loading');
  const { importCustomEmojiData } = await import('./loader');
  const emojis = await importCustomEmojiData();
  if (emojis) {
    log('loaded %d custom emojis', emojis.length);
  }
  const shortcodes = await importLegacyShortcodes();
  if (shortcodes.length) {
    log('loaded %d legacy shortcodes', shortcodes.length);
  }
  await loadEmojiLocale(userLocale);
}

async function loadEmojiLocale(localeString: string) {
  const locale = toSupportedLocale(localeString);
  const { importEmojiData, localeToEmojiPath: localeToPath } =
    await import('./loader');

  if (worker) {
    const path = await localeToPath(locale);
    const shortcodesPath = await localeToShortcodesPath(locale);
    log('asking worker to load locale %s from %s', locale, path);
    messageWorker(locale, path, shortcodesPath);
  } else {
    const emojis = await importEmojiData(locale);
    if (emojis) {
      log('loaded %d emojis to locale %s', emojis.length, locale);
    }
  }
}

function messageWorker(
  locale: typeof EMOJI_TYPE_CUSTOM | typeof EMOJI_DB_NAME_SHORTCODES,
): void;
function messageWorker(locale: Locale, path: string, shortcodes?: string): void;
function messageWorker(
  locale: LocaleOrCustom | typeof EMOJI_DB_NAME_SHORTCODES,
  path?: string,
  shortcodes?: string,
) {
  if (!worker) {
    return;
  }
  worker.postMessage({ locale, path, shortcodes });
}
