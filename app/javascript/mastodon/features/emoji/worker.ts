import { EMOJI_DB_NAME_SHORTCODES, EMOJI_TYPE_CUSTOM } from './constants';
import {
  importCustomEmojiData,
  importEmojiData,
  importLegacyShortcodes,
} from './loader';

addEventListener('message', handleMessage);
self.postMessage('ready'); // After the worker is ready, notify the main thread

function handleMessage(event: MessageEvent<{ locale: string }>) {
  const {
    data: { locale },
  } = event;
  void loadData(locale);
}

async function loadData(locale: string) {
  let importCount: number | undefined;
  if (locale === EMOJI_TYPE_CUSTOM) {
    importCount = (await importCustomEmojiData())?.length;
  } else if (locale === EMOJI_DB_NAME_SHORTCODES) {
    importCount = (await importLegacyShortcodes())?.length;
  } else {
    importCount = (await importEmojiData(locale))?.length;
  }

  if (importCount) {
    self.postMessage(`loaded ${importCount} emojis into ${locale}`);
  }
}
