import initialState from '@/mastodon/initial_state';

// import { searchEmojiByTag } from './database';
import { toSupportedLocale } from './locale';

const worker = new Worker(new URL('./worker', import.meta.url), {
  type: 'module',
});

export function initializeEmoji() {
  const serverLocale = toSupportedLocale(initialState?.meta.locale ?? 'en');

  worker.postMessage(serverLocale);
  worker.postMessage('custom');
}

// window.testEmojiSearch = searchEmojiByTag;
// window.loadEmojiLocale = (locale: string) => {
//   worker.postMessage(locale);
// };
