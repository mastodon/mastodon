import { importEmojiData, importCustomEmojiData } from './loader';

addEventListener('message', handleMessage);

function handleMessage(event: MessageEvent<string>) {
  const { data: target } = event;
  if (target !== 'custom') {
    void importEmojiData(target);
  } else {
    void importCustomEmojiData();
  }
}
