import 'packs/public-path';
import { loadPolyfills } from 'flavours/glitch/polyfills';
import ready from 'flavours/glitch/ready';
import ComposeContainer from 'flavours/glitch/containers/compose_container';
import React from 'react';
import { createRoot } from 'react-dom/client';

function loaded() {
  const mountNode = document.getElementById('mastodon-compose');

  if (mountNode) {
    const attr = mountNode.getAttribute('data-props');
    if(!attr) return;

    const props = JSON.parse(attr);
    const root = createRoot(mountNode);
    root.render(<ComposeContainer {...props} />);
  }
}

function main() {
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
