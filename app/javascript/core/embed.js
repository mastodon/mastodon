//  This file will be loaded on embed pages, regardless of theme.

import 'packs/public-path';

window.addEventListener('message', e => {
  const data = e.data || {};

  if (!window.parent || data.type !== 'setHeight') {
    return;
  }

  function setEmbedHeight () {
    window.parent.postMessage({
      type: 'setHeight',
      id: data.id,
      height: document.getElementsByTagName('html')[0].scrollHeight,
    }, '*');
  };

  if (['interactive', 'complete'].includes(document.readyState)) {
    setEmbedHeight();
  } else {
    document.addEventListener('DOMContentLoaded', setEmbedHeight);
  }
});
