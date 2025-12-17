import type { Locale } from 'emojibase';

import { initialState } from '@/mastodon/initial_state';

import type { EMOJI_DB_NAME_SHORTCODES, EMOJI_TYPE_CUSTOM } from './constants';
import { toSupportedLocale } from './locale';
import type { LocaleOrCustom } from './types';
import { emojiLogger } from './utils';

const userLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

let worker: Worker | null = null;

const log = emojiLogger('index');

// This is too short, but better to fallback quickly than wait.
const WORKER_TIMEOUT = 1_000;

export async function initializeEmoji() {
  log('initializing emojis');

  // Create a temp worker, and assign it to the module-level worker once we know it's ready.
  let tempWorker: Worker | null = null;
  if (!worker && 'Worker' in window) {
    try {
      const { default: EmojiWorker } = await import('./worker?worker&inline');
      tempWorker = new EmojiWorker();
    } catch (err) {
      console.warn('Error creating web worker:', err);
    }
  }

  if (!tempWorker) {
    void fallbackLoad();
    return;
  }

  const timeoutId = setTimeout(() => {
    log('worker is not ready after timeout');
    void fallbackLoad();
  }, WORKER_TIMEOUT);

  tempWorker.addEventListener('message', (event: MessageEvent<string>) => {
    const { data: message } = event;

    worker ??= tempWorker;

    if (message === 'ready') {
      log('worker ready, loading data');
      clearTimeout(timeoutId);
      messageWorker('shortcodes');
      void loadCustomEmoji();
      void loadEmojiLocale(userLocale);
    } else {
      log('got worker message: %s', message);
    }
  });
}

async function fallbackLoad() {
  log('falling back to main thread for loading');

  await loadCustomEmoji();
  const { importLegacyShortcodes } = await import('./loader');
  const shortcodes = await importLegacyShortcodes();
  if (shortcodes?.length) {
    log('loaded %d legacy shortcodes', shortcodes.length);
  }
  await loadEmojiLocale(userLocale);
}

async function loadEmojiLocale(localeString: string) {
  const locale = toSupportedLocale(localeString);
  const { importEmojiData, localeToEmojiPath, localeToShortcodesPath } =
    await import('./loader');

  if (worker) {
    const path = await localeToEmojiPath(locale);
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

export async function loadCustomEmoji() {
  if (worker) {
    messageWorker('custom');
  } else {
    const { importCustomEmojiData } = await import('./loader');
    const emojis = await importCustomEmojiData();
    if (emojis && emojis.length > 0) {
      log('loaded %d custom emojis', emojis.length);
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
