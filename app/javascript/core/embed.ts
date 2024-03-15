//  This file will be loaded on embed pages, regardless of theme.

import 'packs/public-path';
import ready from '../mastodon/ready';

interface SetHeightMessage {
  type: 'setHeight';
  id: string;
  height: number;
}

function isSetHeightMessage(data: unknown): data is SetHeightMessage {
  if (
    data &&
    typeof data === 'object' &&
    'type' in data &&
    data.type === 'setHeight'
  )
    return true;
  else return false;
}

window.addEventListener('message', (e) => {
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- typings are not correct, it can be null in very rare cases
  if (!e.data || !isSetHeightMessage(e.data) || !window.parent) return;

  const data = e.data;

  ready(() => {
    window.parent.postMessage(
      {
        type: 'setHeight',
        id: data.id,
        height: document.getElementsByTagName('html')[0].scrollHeight,
      },
      '*',
    );
  }).catch((e) => {
    console.error('Error in setHeightMessage postMessage', e);
  });
});
