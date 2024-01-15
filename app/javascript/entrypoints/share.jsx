import { createRoot } from 'react-dom/client';

import { start } from '../mastodon/common';
import { loadPolyfills } from '../mastodon/polyfills';
import ready from '../mastodon/ready';

start();

async function loaded() {
  const { ComposeContainer } = await import('../mastodon/containers/compose_container');
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
