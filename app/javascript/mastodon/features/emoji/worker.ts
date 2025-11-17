import { importCustomEmojiData, importEmojiData } from './loader';

addEventListener('message', handleMessage);
self.postMessage('ready'); // After the worker is ready, notify the main thread

function handleMessage(event: MessageEvent<{ locale: string; path?: string }>) {
  const {
    data: { locale, path },
  } = event;
  void loadData(locale, path);
}

async function loadData(locale: string, path?: string) {
  let importCount: number | undefined;
  if (locale === 'custom') {
    importCount = (await importCustomEmojiData())?.length;
  } else if (path) {
    importCount = (await importEmojiData(locale, path))?.length;
  } else {
    throw new Error('Path is required for loading locale emoji data');
  }
  if (importCount) {
    self.postMessage(`loaded ${importCount} emojis into ${locale}`);
  }
}
