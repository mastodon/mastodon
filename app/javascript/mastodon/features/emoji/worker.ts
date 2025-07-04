import { importEmojiData, importCustomEmojiData } from './loader';

addEventListener('message', handleMessage);
self.postMessage('ready'); // After the worker is ready, notify the main thread

function handleMessage(event: MessageEvent<string>) {
  const { data: locale } = event;
  if (locale !== 'custom') {
    void importEmojiData(locale);
  } else {
    void importCustomEmojiData();
  }
}
