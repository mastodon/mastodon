import './public-path';
import { createRoot } from 'react-dom/client';

import { start } from '../mastodon/common';
import ComposeContainer from '../mastodon/containers/compose_container';
import { loadPolyfills } from '../mastodon/polyfills';
import ready from '../mastodon/ready';

start();

function loaded() {
  const mountNode = document.getElementById('mastodon-compose');

  if (mountNode) {
    const attr = mountNode.getAttribute('data-props');

    if (!attr) return;

    const props = JSON.parse(attr) as object;
    const root = createRoot(mountNode);

    root.render(<ComposeContainer {...props} />);
  }
}

function main() {
  ready(loaded).catch((error: unknown) => {
    console.error(error);
  });
}

loadPolyfills()
  .then(main)
  .catch((error: unknown) => {
    console.error(error);
  });
