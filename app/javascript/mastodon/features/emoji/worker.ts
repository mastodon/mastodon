import { importEmojiData, importCustomEmojiData } from './loader';

addEventListener('message', handleMessage);
self.postMessage('ready'); // After the worker is ready, notify the main thread

function handleMessage(event: MessageEvent<string>) {
  const { data: locale } = event;
  void loadData(locale);
}

async function loadData(locale: string) {
  if (locale !== 'custom') {
    await importEmojiData(locale);
  } else {
    await importCustomEmojiData();
  }
  self.postMessage(`loaded ${locale}`);
}
